import 'dart:convert';

class BOperator {
  var id;
  var name;
  var img;
  var email;
  var phone;
  var status;
  var pin;
  var type;
  var v1_user_id;
  List<dynamic> permission = List();
  BOperator.fromJson(Map j) {
    if (j["user"] != null && j["user"]["data"] != null) {
      var data = j["user"]["data"];
      id = data["id"];
      name = data["name"];
      img = data["img"];
      email = data["email"];
      phone = data["phone"];
      status = data["status"];
      pin = data["pin"];
      type = data["type"];
      v1_user_id = data["v1_user_id"];
    }
    if (j["permissions_str"] != null) {
      permission.clear();
      if (j["permissions_str"].runtimeType == String)
        for (var item in json.decode(j["permissions_str"])) {
          permission.add(item);
        }
      else
        for (var item in (j["permissions_str"])) {
          permission.add(item);
        }
    }
  }
  BOperator.fromMap(Map data) {
    id = data["id"];
    name = data["name"];
    img = data["img"];
    email = data["email"];
    phone = data["phone"];
    status = data["status"];
    pin = data["pin"];
    type = data["type"];
    v1_user_id = data["v1_user_id"];
    {
      if (data["permissions_str"] != null) {
        permission.clear();
        if (data["permissions_str"].runtimeType == String)
          for (var item in json.decode(data["permissions_str"])) {
            permission.add(item);
          }
        else
          for (var item in (data["permissions_str"])) {
            permission.add(item);
          }
      }
    }
  }

  Map saveObject() {
    Map map = Map();
    map["id"] = id;
    map["name"] = name;
    map["img"] = img;
    map["email"] = email;
    map["phone"] = phone;
    map["status"] = status;
    map["pin"] = pin;
    map["type"] = type;
    map["v1_user_id"] = v1_user_id;
    map["permissions_str"] = json.encode(permission);
    return map;
  }

  Map<String, dynamic> saveObjectDB() {
    Map<String, dynamic> map = Map();
    map["id"] = id;
    map["name"] = name;
    map["img"] = img;
    map["email"] = email;
    map["phone"] = phone;
    map["status"] = status;
    map["pin"] = pin;
    map["type"] = type;
    map["v1_user_id"] = v1_user_id;
    map["permissions_str"] = json.encode(permission);
    return map;
  }

  BOperator.parseObject(Map map) {
    id = map["id"];
    name = map["name"];
    img = map["img"];
    email = map["email"];
    phone = map["phone"];
    status = map["status"];
    pin = map["pin"];
    type = map["type"];
    v1_user_id = map["v1_user_id"];
    if (map["permissions_str"] != null)
      permission = json.decode(map["permissions_str"]);
  }
}
