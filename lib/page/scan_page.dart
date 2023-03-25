import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scan_stock/helper/HiveHelper.dart';
import 'package:scan_stock/model/m_scan.dart';
import 'package:scan_stock/service/scan_service.dart';


class ScanPage extends StatefulWidget {

  ScanPage({ Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ScanPage();
}

class _ScanPage extends State<ScanPage> {

  List<Map<String, dynamic>> _scanList = [];
  final ScanService _scanService = new ScanService();

  String _rack = "-";
  String _importText = "-";
  int _scaned = 0;
  int _total = 0;

  @override
  void initState() {

    setState(() {
      _scanList = HiverHelper.getScans();
    });

    calculate();

    super.initState();
  }

  void calculate() {
    print('calculate');
    setState((){
      print('calculate ${_scanList.length}');
      _total = _scanList.length;
      _scaned = _scanList.where((element) => element['scan'] > 0).length;
    });
  }

  Widget rack(Map<String, dynamic> map) {

    if (map['zone'] == "" || map['zone'] == null) {
      return const Text("Rack: -");
    }

    return Text("Rack: ${map['zone']} - ${map['area']} - ${map['bin']}");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Stock'),
      ),
      body:
      Column(
        children: [
          Row (
            children: [
              SizedBox(width: 10,),

              OutlinedButton(onPressed: () async {
                String result = await FlutterBarcodeScanner.scanBarcode(
                    '#ff6666',
                    'Batal',
                    false,
                    ScanMode.DEFAULT);
                setState(() {
                  result = result.replaceAll("]C1", "");
                  _rack = result;
                });

              }, child: Text('Scan Rack')),

              SizedBox(width: 10,),

              OutlinedButton(onPressed: () async {

                String barcode = await FlutterBarcodeScanner.scanBarcode(
                    '#ff6666',
                    'Batal',
                    false,
                    ScanMode.DEFAULT);
                barcode = barcode.replaceAll("]C1", "");

                DateTime now = DateTime.now();
                String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);

                // String barcode = "000000000003";
                final list = _scanList.where((element) => (element['sn'] == barcode || element['sn'] == barcode) );
                if (list.isNotEmpty) {

                  List<String> arr = _rack.split("-");
                  String loc = '';
                  String zone = arr[0];
                  String area = arr[1];
                  String rack = arr[2];
                  String bin = arr[3];

                  for (var element in list) {
                    HiverHelper.updateItem(element['key'], {
                      "sn": element['sn'],
                      "sn2": element['sn2'],
                      "scan": 1,
                      "upload": element['upload'],
                      "loc": loc,
                      "zone": zone,
                      "area": area,
                      "rack": rack,
                      "bin": bin,
                      "updated_at": formattedDate,
                    });

                    // HiverHelper.updateItem(element['key'], {
                    //   "scan": 1,
                    //   "updated_at": formattedDate,
                    // });
                  }

                } else {
                  print('Not found!');
                }

                setState((){
                  _scanList = HiverHelper.getScans();
                });

                calculate();

              }, child: Text('Scan')),

              SizedBox(width: 10,),

              OutlinedButton(onPressed: () async {

                if (_scanList.where((element) => element['scan'] == 1 && element['upload'] == 0).isNotEmpty) {
                  showAlertDialog(context, 'You have pending scan item!');
                } else {
                  HiverHelper.clear();

                  final String response = await rootBundle.loadString('assets/db.json');
                  final data = await jsonDecode(response);
                  var list = data['data'] as List;

                  List<ScanModel> listScan = list.map((data) => ScanModel.fromMap2(data) ).toList();
                  int count = listScan.length;
                  int index = 1;
                  listScan.forEach((value) {
                    HiverHelper.addItem({
                      "sn": value.sn,
                      "sn2": value.sn2,
                      "scan": value.scan,
                      "upload": value.upload,
                      "loc": value.loc,
                      "zone": value.zone,
                      "area": value.area,
                      "rack": value.rack,
                      "bin": value.bin,
                      "updated_at": value.updated_at,
                    });

                    setState(() {
                      _importText = "Import Data $index / $count";
                      print(_importText);
                    });

                    index++;
                  });
                  setState((){
                    _scanList = HiverHelper.getScans();
                  });

                  calculate();
                }


              }, child: Text('Import Data')),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Text('Rack: ${_rack}'),
              ),
              // Container(
              //   padding: EdgeInsets.only(left: 10),
              //   child: Text('${_importText}'),
              // ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: Text('${_scaned} / ${_total}'),
              ),
            ],
          ),

          _scanList.isEmpty ?
          Expanded(
            child: Center(
              child: Text('No Data\n${_importText}'),
            ),
          ) : Expanded(child:
                Column(
                  children: [
                    Expanded(child:
                      ListView.builder(itemCount: _scanList.length, itemBuilder: (context, index) {
                      final _item = _scanList[index];
                      return Card(
                        color: Colors.white,
                        elevation: 2.0,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("SN: ${_item['sn']}" ),
                                  Text("SN2: ${_item['sn2']}"),
                                  Text("Scan: ${_item['scan']}"),
                                  Text("Upload: ${_item['upload']}"),
                                  rack(_item),
                                  Text(""),
                                  Text(_item['updated_at'] ?? ""),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    })
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      child: ElevatedButton(onPressed: (){

                        List<String> arr = _rack.split("-");
                        String loc = '';
                        String zone = arr[0];
                        String area = arr[1];
                        String rack = arr[2];
                        String bin = arr[3];

                        if (arr.length == 4) {
                          final uploadList = _scanList.where((element) => element['scan'] == '1');
                          if (uploadList.isNotEmpty) {
                            _scanService.postItem(
                                _rack,
                                loc,
                                zone,
                                area,
                                rack,
                                bin,
                                uploadList.toList()
                            );
                          } else {
                            print('Scan not ready data.');
                          }
                        } else {
                          print('Format rack wrong!');
                        }


                      }, child: Text('Upload Data')),
                    )
                  ],
                )
          ),
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context, String msg) {

    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Message"),
      content: Text(msg),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showLoaderDialog(BuildContext context){
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(
            width: 10,
          ),
          Container(
            child:Text(" Loading..." ),
            padding: EdgeInsets.all(10),
          ),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

}