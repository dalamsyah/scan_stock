import 'dart:convert';

import 'package:flutter/services.dart';
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

  @override
  void initState() {

    setState(() {
      _scanList = HiverHelper.getScans();
    });

    super.initState();
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

              OutlinedButton(onPressed: (){

              }, child: Text('Scan Rack: -')),

              SizedBox(width: 10,),

              OutlinedButton(onPressed: (){
                DateTime now = DateTime.now();
                String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);

                String barcode = "000000000003";
                final list = _scanList.where((element) => (element['sn'] == barcode || element['sn'] == barcode) );
                if (list.isNotEmpty) {

                  for (var element in list) {
                    // HiverHelper.updateItem(element['key'], {
                    //   "sn": element['sn'],
                    //   "sn2": element['sn2'],
                    //   "scan": 1,
                    //   "upload": element['upload'],
                    //   "loc": element['loc'],
                    //   "zone": element['zone'],
                    //   "area": element['area'],
                    //   "rack": element['rack'],
                    //   "bin": element['bin'],
                    //   "updated_at": formattedDate,
                    // });

                    HiverHelper.updateItem(element['key'], {
                      "scan": 1,
                      "updated_at": formattedDate,
                    });
                  }

                } else {
                  print('Not found!');
                }

                setState((){
                  _scanList = HiverHelper.getScans();
                });

              }, child: Text('Scan')),

              SizedBox(width: 10,),

              OutlinedButton(onPressed: () async {

                final String response = await rootBundle.loadString('assets/db.json');
                final data = await jsonDecode(response);
                var list = data['data'] as List;

                List<ScanModel> listScan = list.map((data) => ScanModel.fromMap2(data) ).toList();
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
                });
                setState((){
                  _scanList = HiverHelper.getScans();
                });


              }, child: Text('Import Data')),
            ],
          ),
          _scanList.isEmpty ?
          Center(
            child: Text('No Data.'),
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

                        final uploadList = _scanList.where((element) => element['scan'] == '1');
                        _scanService.postItem(
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            uploadList
                        );


                      }, child: Text('Upload Data')),
                    )
                  ],
                )
          ),
        ],
      ),
    );
  }

}