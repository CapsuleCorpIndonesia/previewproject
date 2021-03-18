import 'package:pawoon/Bean/BVariantData.dart';

class BVariant {
  var id;
  var name;
  List<BVariantData> variantdata = List();

  BVariant();

  BVariant.clone(BVariant mat) {
    this.id = mat.id;
    this.name = mat.name;

    this.variantdata.clear();
    for (BVariantData data in mat.variantdata) {
      variantdata.add(BVariantData.clone(data));
    }
  }

  BVariant.fromJson(Map json)
      : id = json["id"],
        name = json["name"] {
    if (json["matrix_details"] != null &&
        json["matrix_details"]["data"] != null) {
      variantdata.clear();
      for (var item in json["matrix_details"]["data"]) {
        variantdata.add(BVariantData.fromJson(item));
      }
    }
  }

/* -------------------------------------------------------------------------- */
/*                                     DB                                     */
/* -------------------------------------------------------------------------- */
  Map toMap() {
    Map map = Map();
    map['id'] = this.id;
    map['name'] = this.name;

    List<Map> arr = List();
    if (variantdata != null)
      for (BVariantData data in variantdata) {
        arr.add(data.toMap());
      }
    map['matrixdata'] = arr;

    return map;
  }

  BVariant.fromMap(Map map) {
    id = map["id"];
    name = map["name"];

    if (map["matrixdata"] != null) {
      var arr = map["matrixdata"];
      for (Map data in arr) {
        variantdata.add(BVariantData.fromMap(data));
      }
    }
  }
}
