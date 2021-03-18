class BGrabModifier {
  var created_at;
  var updated_at;
  var deleted_at;
  var cost;
  var id;
  var title;
  var transaction_item_id;
  var modifier_id;
  var qty;
  var amount;
  var price;
  BGrabModifier.fromJson(Map json)
      : created_at = json["created_at"],
        updated_at = json["updated_at"],
        deleted_at = json["deleted_at"],
        cost = json["cost"],
        id = json["id"],
        title = json["title"],
        transaction_item_id = json["transaction_item_id"],
        modifier_id = json["modifier_id"],
        qty = json["qty"],
        amount = json["amount"],
        price = json["price"];

  Map toMap() {
    Map<String, dynamic> map = Map();
    map["created_at"] = created_at;
    map["updated_at"] = updated_at;
    map["deleted_at"] = deleted_at;
    map["cost"] = cost;
    map["id"] = id;
    map["title"] = title;
    map["transaction_item_id"] = transaction_item_id;
    map["modifier_id"] = modifier_id;
    map["qty"] = qty;
    map["amount"] = amount;
    map["price"] = price;

    return map;
  }

  BGrabModifier.fromMap(Map map) {
    created_at = map["created_at"];
    updated_at = map["updated_at"];
    deleted_at = map["deleted_at"];
    cost = map["cost"];
    id = map["id"];
    title = map["title"];
    transaction_item_id = map["transaction_item_id"];
    modifier_id = map["modifier_id"];
    qty = map["qty"];
    amount = map["amount"];
    price = map["price"];
  }
}
