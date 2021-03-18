class BDevice {
  var id;
  var name;
  var type;
  var image;
  var price;
  var is_expired;
  var is_available;
  var v1_device_id;
  var created_at;
  var updated_at;
  var locked_down_at;
  BDevice.fromJson(Map json)
      : id = json["id"],
        name = json["name"],
        type = json["type"],
        image = json["image"],
        price = json["price"],
        is_expired = json["is_expired"],
        is_available = json["is_available"],
        v1_device_id = json["v1_device_id"],
        created_at = json["created_at"],
        updated_at = json["updated_at"],
        locked_down_at = json["locked_down_at"];

  Map saveObject() {
    Map map = Map();
    map["id"] = id;
    map["name"] = name;
    map["type"] = type;
    map["image"] = image;
    map["price"] = price;
    map["is_expired"] = is_expired;
    map["is_available"] = is_available;
    map["v1_device_id"] = v1_device_id;
    map["created_at"] = created_at;
    map["updated_at"] = updated_at;
    map["locked_down_at"] = locked_down_at;

    return map;
  }

  BDevice.parseObject(Map map) {
    id = map["id"];
    name = map["name"];
    type = map["type"];
    image = map["image"];
    price = map["price"];
    is_expired = map["is_expired"];
    is_available = map["is_available"];
    v1_device_id = map["v1_device_id"];
    created_at = map["created_at"];
    updated_at = map["updated_at"];
    locked_down_at = map["locked_down_at"];
  }
}
