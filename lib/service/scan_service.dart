
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scan_stock/helper/HiveHelper.dart';
import 'package:scan_stock/model/m_scan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanService {
  // String baseUrl = 'https://portal.tpi-mexico.com/scanbarcode/api.php';
  String baseUrl = 'http://192.168.56.1/scanbarcode/apiv3.php';
  // String url = 'http://172.20.10.11/scan_barcode_stok_api/public/scan';

  Future<String> postItem(
      String barcode,
      String loc,
      String zone,
      String area,
      String rack,
      String bin,
      List<Map<String, dynamic>> _scanList) async {

    SharedPreferences localStorage = await SharedPreferences.getInstance();

    String url = localStorage.getString("url") ?? baseUrl;
    final response = await http.post(Uri.parse(url), body: {
      'barcode': barcode,
      'loc': loc,
      'zone': zone,
      'area': area,
      'rack': rack,
      'bin': bin,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      var list = data['data'] as List;
      List<ScanModel> result = list.map((data) => ScanModel.fromMap2(data) ).toList();

      if (result.isNotEmpty) {
        for (ScanModel scanModel in result) {

          final list = _scanList.firstWhere((element) => (element['sn'] == scanModel.sn), orElse: () => {} );
          if (list.isNotEmpty) {
            HiverHelper.updateItem(list['key'], {
              "upload": 1,
            });
          }
        }
      }

      return 'Success update data';
    }
    else {
      throw Exception('Failed to post list.');
    }
  }

}