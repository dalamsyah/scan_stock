

import 'package:hive/hive.dart';
import 'package:scan_stock/model/m_scan.dart';

class HiverHelper {

  static final _scanList = Hive.box("scan_list");

  static List<Map<String, dynamic>> getScans() {
    var list = _scanList.keys.map((e) {
      var value = _scanList.get(e);
      return {
        "key": e,
        "sn": value['sn'],
        "sn2": value['sn2'],
        "scan": value['scan'],
        "upload": value['upload'],
        "loc": value['loc'],
        "zone": value['zone'],
        "area": value['area'],
        "rack": value['rack'],
        "bin": value['bin'],
        "updated_at": value['updated_at'],
      };
    }).toList();

    return list;
  }

  static Future<void> addItem(Map<String, dynamic> newItem ) async {
    await _scanList.add(newItem);
  }

  static Future<void> updateItem(int itemKey, Map<String, dynamic> newItem ) async {
    await _scanList.put(itemKey, newItem);
  }

  static Future<void> deleteItem(int itemKey) async {
    await _scanList.delete(itemKey);
  }

}