class BOwner {
  var id;
  var name;
  var img;
  var email;
  var phone;
  var status;
  var pin;
  var type;
  var v1_user_id;

  BOwner.fromJson(Map json)
      : id = json["id"],
        name = json["name"],
        img = json["img"],
        email = json["email"],
        phone = json["phone"],
        status = json["status"],
        pin = json["pin"],
        type = json["type"],
        v1_user_id = json["v1_user_id"];

  BOwner.fromMap(Map map) {
    if (map == null) return;
    id = map["id"];
    name = map["name"];
    img = map["img"];
    email = map["email"];
    phone = map["phone"];
    status = map["status"];
    pin = map["pin"];
    type = map["type"];
    v1_user_id = map["v1_user_id"];
  }

  Map toMap() {
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
    return map;
  }
}
