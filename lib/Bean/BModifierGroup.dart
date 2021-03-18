class BModifierGroup {
  var id;
  var product_uuid;
  var modifier_group_uuid;

  Map toMap() {
    Map map = Map();
    map["id"] = id;
    map["product_uuid"] = product_uuid;
    map["modifier_group_uuid"] = modifier_group_uuid;

    return map;
  }

  BModifierGroup.fromMap(Map map) {
    id = map["id"];
    product_uuid = map["product_uuid"];
    modifier_group_uuid = map["modifier_group_uuid"];
  }
}
