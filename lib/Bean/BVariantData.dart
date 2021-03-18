class BVariantData {
  var id;
  var name;

  BVariantData();

  BVariantData.clone(BVariantData data) {
    this.name = data.name;
    this.id = data.id;
  }

  BVariantData.fromJson(Map json)
      : name = json["name"],
        id = json["id"];
        
/* -------------------------------------------------------------------------- */
/*                                     DB                                     */
/* -------------------------------------------------------------------------- */
  Map toMap() {
    Map map = Map();
    map['name'] = this.name;
    map['id'] = this.id;
    return map;
  }

  BVariantData.fromMap(Map<dynamic, dynamic> map) {
    this.name = map['name'];
    this.id = map['id'];
  }
}
