

class ScanModel {
  String _idstokcount = "";
  String _item_code = "";
  String _sn = "";
  String _sn2 = "";
  String _loc = "";
  String _zone = "";
  String _area = "";
  String _rack = "";
  String _bin = "";
  int _scan = 0;
  int _upload = 0;
  String? _created_at = "";
  String? _updated_at = "";

  ScanModel(this._sn, this._sn2, this._scan);

  ScanModel.fromMap(Map<String, dynamic> map) {
    this._idstokcount = map['idstokcount'];
    this._item_code = map['item_code'];
    this._sn = map['sn'];
    this._sn2 = map['sn2'];
    this._loc = map['loc'];
    this._zone = map['zone'];
    this._area = map['area'];
    this._rack = map['rack'];
    this._bin = map['bin'];
    this._scan = map['scan'];
    this._upload = map['upload'];
    this._created_at = map['created_at'];
    this._updated_at = map['updated_at'];
  }

  ScanModel.fromMap2(Map<String, dynamic> map) {
    // this._idstokcount = map['idstokcount'];
    this._item_code = map['item_code'];
    this._sn = map['sn'];
    this._sn2 = map['sn2'];
    this._loc = map['loc'] ?? "";
    this._zone = map['zone'] ?? "";
    this._area = map['area'] ?? "";
    this._rack = map['rack'] ?? "";
    this._bin = map['bin'] ?? "";
    this._updated_at = map['scan_datetime'] ?? "";
  }


  // getter
  String get id => _idstokcount;
  String get item_code => _item_code;
  String get sn => _sn;
  String get sn2 => _sn2;
  String get loc => _loc;
  String get zone => _zone;
  String get area => _area;
  String get rack => _rack;
  String get bin => _bin;
  int get scan => _scan;
  int get upload => _upload;
  String get created_at => _created_at ?? '-';
  String get updated_at => _updated_at ?? '-';

  // setter
  set sn(String value) {
    sn = value;
  }

  set sn2(String value) {
    sn2 = value;
  }

  set loc(String value) {
    loc = value;
  }

  set created_at(String value) {
    created_at = value;
  }

  set updated_at(String value) {
    updated_at = value;
  }

  // konversi dari Scan ke Map
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['idstokcount'] = _idstokcount;
    map['item_code'] = _item_code;
    map['sn'] = _sn;
    map['sn2'] = _sn2;
    map['loc'] = _loc;
    map['zone'] = _zone;
    map['area'] = _area;
    map['rack'] = _rack;
    map['bin'] = _bin;
    map['scan'] = _scan;
    map['upload'] = _upload;
    map['created_at'] = _created_at;
    map['updated_at'] = _updated_at;
    return map;
  }

  List encondeToJson(List<ScanModel> list) {
    List jsonList = [];
    list.map((item) => jsonList.add(item.toMap())).toList();
    return jsonList;
  }

  ScanModel copyWith(String content) => ScanModel(id, content, 1);

}