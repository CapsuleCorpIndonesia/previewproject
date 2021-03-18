class BIntegration {
  var method;
  var type;
  var configurations;

  BIntegration.fromJson(Map json)
      : method = json["method"],
        type = json["type"],
        configurations = json["configurations"];

  BIntegration.fromMap(Map map) {
    this.method = map["method"];
    this.type = map["type"];
    this.configurations = map["configurations"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map["method"] = this.method;
    map["type"] = this.type;
    map["configurations"] = this.configurations;
    return map;
  }
}
