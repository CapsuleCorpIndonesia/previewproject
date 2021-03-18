class BSalesType {
  var id = "";
  var name = "";
  var company_id = "";
  num deleted = 0;
  var mode = "";

  BSalesType();

  BSalesType.fromJson(Map json)
      : id = json["id"],
        name = json["name"],
        company_id = json["company_id"],
        deleted = json["deleted"] ? 1 : 0,
        mode = json["mode"];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map["id"] = id;
    map["name"] = name;
    map["company_id"] = company_id;
    map["deleted"] = deleted;
    map["mode"] = mode;
    return map;
  }

  BSalesType.fromMap(Map map) {
    id = map["id"];
    name = map["name"];
    company_id = map["company_id"];
    deleted = map["deleted"];
    mode = map["mode"];
  }
}
