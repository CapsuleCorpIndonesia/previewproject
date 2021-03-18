class BTax {
  var id;
  var outlet_id;
  var name;
  var percentage;
  var type;
  var amount;

  BTax.clone(BTax tax, {multiplier =1}) {
    if (tax == null) return;
    id = tax.id;
    outlet_id = tax.outlet_id;
    name = tax.name;
    percentage = tax.percentage;
    type = tax.type;
    amount = tax.amount * multiplier;
  }

  BTax.fromJson(Map json)
      : id = json["id"],
        name = json["name"],
        percentage = json["percentage"],
        type = json["type"],
        outlet_id = json["outlet_id"];

  Map saveObject() {
    Map map = Map();
    map["id"] = id;
    map["name"] = name;
    map["percentage"] = percentage;
    map["type"] = type;
    map["outlet_id"] = outlet_id;
    map["amount"] = amount;

    return map;
  }

  BTax.parseObject(Map map) {
    id = map["id"];
    name = map["name"];
    percentage = map["percentage"];
    type = map["type"];
    outlet_id = map["outlet_id"];
    amount = map["amount"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map["amount"] = amount;
    map["id"] = id;
    map["outlet_id"] = outlet_id;
    map["name"] = name;
    map["percentage"] = percentage;
    map["type"] = type;
    return map;
  }

  BTax.fromMap(Map map) {
    id = map["id"];
    outlet_id = map["outlet_id"];
    name = map["name"];
    percentage = map["percentage"];
    type = map["type"];
    amount = map["amount"];
  }

  Map objectToServer({multiplier = 1}) {
    Map map = Map();
    map["amount"] = amount * multiplier ?? 0;
    map["percentage"] = percentage;
    map["tax_and_service_id"] = id;
    map["title"] = name;
    map["type"] = type;
    return map;
  }
}
