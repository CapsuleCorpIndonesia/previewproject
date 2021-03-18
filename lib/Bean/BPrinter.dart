import 'dart:convert';

class BPrinter {
  var name;
  var address;
  bool enableCetakStruk = true;
  num cetakStruk = 1;
  bool enableCetakLabel = false;
  num cetakLabel = 0;
  bool enableCetakDapur = true;
  num cetakDapur = 1;
  String lebar = "";
  List<dynamic> selectionDapur = List();
  List<dynamic> selectionCategory = List();
  BPrinter();
  BPrinter.clone(BPrinter printer) {
    name = printer.name;
    address = printer.address;
    enableCetakStruk = printer.enableCetakStruk;
    cetakStruk = printer.cetakStruk;
    enableCetakLabel = printer.enableCetakLabel;
    cetakLabel = printer.cetakLabel;
    enableCetakDapur = printer.enableCetakDapur;
    cetakDapur = printer.cetakDapur;
    lebar = printer.lebar;
    selectionDapur = List.of(printer.selectionDapur);
    selectionCategory = List.of(printer.selectionCategory);
  }

  BPrinter.fromMap(Map map) {
    name = map["name"];
    address = map["address"];
    cetakStruk = map["cetakStruk"];
    enableCetakStruk = map["enableCetakStruk"] == 1;
    enableCetakLabel = map["enableCetakLabel"] == 1;
    enableCetakDapur = map["enableCetakDapur"] == 1;
    cetakLabel = map["cetakLabel"];
    cetakDapur = map["cetakDapur"];
    lebar = map["lebar"];
    // print(map["selectionDapur"]);
    if (map["selectionDapur"] != null && map["selectionDapur"] != "" && json.decode(map["selectionDapur"]).isNotEmpty)
      selectionDapur = json.decode(map["selectionDapur"]);

    if (map["selectionCategory"] != null && map["selectionCategory"] != "" && json.decode(map["selectionCategory"]).isNotEmpty)
      selectionCategory = json.decode(map["selectionCategory"]);
  }

  Map toMap() {
    Map<String, dynamic> map = Map();
    map["name"] = name;
    map["address"] = address;
    map["enableCetakStruk"] = enableCetakStruk ? 1 : 0;
    map["cetakStruk"] = cetakStruk;
    map["enableCetakLabel"] = enableCetakLabel ? 1 : 0;
    map["cetakLabel"] = cetakLabel;
    map["enableCetakDapur"] = enableCetakDapur ? 1 : 0;
    map["cetakDapur"] = cetakDapur;
    map["lebar"] = lebar;

    map["selectionDapur"] = json.encode(selectionDapur);
    map["selectionCategory"] = json.encode(selectionCategory);
    return map;
  }
}
