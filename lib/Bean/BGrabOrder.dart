import 'BGrabModifier.dart';

class BGrabOrder {
  var created_at;
  var updated_at;
  var deleted_at;
  var product_category_id;
  var modifiers_amount;
  var cost;
  var modifiers_cost;
  var id;
  var transaction_id;
  var note;
  var title;
  var product_id;
  var qty;
  var price;
  var amount;
  var subtotal;
  List<BGrabModifier> modifiers = List();

  BGrabOrder.fromJson(Map json)
      : created_at = json["created_at"],
        updated_at = json["updated_at"],
        deleted_at = json["deleted_at"],
        product_category_id = json["product_category_id"],
        modifiers_amount = json["modifiers_amount"],
        cost = json["cost"],
        modifiers_cost = json["modifiers_cost"],
        id = json["id"],
        transaction_id = json["transaction_id"],
        note = json["note"],
        title = json["title"],
        product_id = json["product_id"],
        qty = json["qty"],
        price = json["price"],
        amount = json["amount"],
        subtotal = json["subtotal"] {
    if (json["modifiers"] != null) {
      modifiers.clear();
      for (var item in json["modifiers"]) {
        BGrabModifier mod = BGrabModifier.fromJson(item);
        modifiers.add(mod);
      }
    }
  }

  Map toMap() {
    Map<String, dynamic> map = Map();
    map["created_at"] = created_at;
    map["updated_at"] = updated_at;
    map["deleted_at"] = deleted_at;
    map["product_category_id"] = product_category_id;
    map["modifiers_amount"] = modifiers_amount;
    map["cost"] = cost;
    map["modifiers_cost"] = modifiers_cost;
    map["id"] = id;
    map["transaction_id"] = transaction_id;
    map["note"] = note;
    map["title"] = title;
    map["product_id"] = product_id;
    map["qty"] = qty;
    map["price"] = price;
    map["amount"] = amount;
    map["subtotal"] = subtotal;
    List<Map> arrModifiers = List();
    for (var item in modifiers) {
      arrModifiers.add(item.toMap());
    }
    map["modifiers"] = arrModifiers;
    return map;
  }

  BGrabOrder.fromMap(Map map) {
    created_at = map["created_at"];
    updated_at = map["updated_at"];
    deleted_at = map["deleted_at"];
    product_category_id = map["product_category_id"];
    modifiers_amount = map["modifiers_amount"];
    cost = map["cost"];
    modifiers_cost = map["modifiers_cost"];
    id = map["id"];
    transaction_id = map["transaction_id"];
    note = map["note"];
    title = map["title"];
    product_id = map["product_id"];
    qty = map["qty"];
    price = map["price"];
    amount = map["amount"];
    subtotal = map["subtotal"];
    
    if (map["modifiers"] != null)
      for (var item in map["modifiers"]) {
        modifiers.add(BGrabModifier.fromMap(item));
      }
  }
}
