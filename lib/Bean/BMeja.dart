class BMeja {
  var id;
  var uuid;
  var name;
  bool selected = false;

  BMeja();

  BMeja.clone(BMeja meja) {
    if (meja == null) return;
    this.id = meja.id;
    this.uuid = meja.uuid;
    this.name = meja.name;
    this.selected = meja.selected;
  }

  BMeja.fromJson(Map json)
      : uuid = json["uuid"],
        name = json["name"];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    if (this.id != null) map["id"] = this.id;
    if (this.uuid != null) map["uuid"] = this.uuid;
    map["name"] = this.name;

    return map;
  }

  BMeja.fromMap(Map map) {
    this.id = map["id"];
    this.uuid = map["uuid"];
    this.name = map["name"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    if (this.uuid != null) map["uuid"] = this.uuid;
    map["name"] = this.name;

    return map;
  }
}
