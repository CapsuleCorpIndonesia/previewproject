import 'package:pawoon/Bean/BCompany.dart';

import 'BTax.dart';

class BOutlet {
  var id;
  var name;
  var note;
  var v1_outlet_id;
  var loyalty;
  var address;
  var phones;
  var city_id;
  var city_name;
  BCompany company;
  BTax tax;

  BOutlet.fromJson(Map json)
      : id = json["id"],
        name = json["name"],
        note = json["note"],
        v1_outlet_id = json["v1_outlet_id"],
        loyalty = json["loyalty"] {
    if (json["addresses"] != null && json["addresses"]["data"] != null) {
      address = json["addresses"]["data"]["address"];
      phones = json["addresses"]["data"]["phones"];
    }

    if (json["addresses"] != null &&
        json["addresses"]["data"] != null &&
        json["addresses"]["data"]["city"] != null &&
        json["addresses"]["data"]["city"]["data"] != null) {
      city_id = json["addresses"]["data"]["city"]["data"]["id"];
      city_name = json["addresses"]["data"]["city"]["data"]["name"];
    }

    if (json["company"] != null && json["company"]["data"] != null) {
      company = BCompany.fromJson(json["company"]["data"]);
    }

    if (json["tax_and_service"] != null &&
        json["tax_and_service"]["data"] != null) {
      tax = BTax.fromJson(json["tax_and_service"]["data"]);
    }
  }

  Map<String, dynamic> saveObject() {
    Map<String, dynamic> map = Map();
    map["id"] = id;
    map["name"] = name;
    map["note"] = note;
    map["v1_outlet_id"] = v1_outlet_id;
    map["loyalty"] = loyalty;
    map["address"] = address;
    map["phones"] = phones;
    map["city_id"] = city_id;
    map["city_name"] = city_name;
    if (company != null) map["company"] = company.saveObject();
    if (tax != null) map["tax"] = tax.saveObject();

    return map;
  }

  BOutlet.parseObject(Map map) {
    id = map["id"];
    name = map["name"];
    note = map["note"];
    v1_outlet_id = map["v1_outlet_id"];
    loyalty = map["loyalty"];
    address = map["address"];
    phones = map["phones"];
    city_id = map["city_id"];
    city_name = map["city_name"];
    if (map["company"] != null) company = BCompany.parseObject(map["company"]);
    if (map["tax"] != null) tax = BTax.parseObject(map["tax"]);
  }
}
