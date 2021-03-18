class BModifierData {
  var id;
  var name;
  var price;
  var cost;
  var qty = 0;

  BModifierData();

  BModifierData.clone(BModifierData data, {multiplier=1}) {
    this.id = data.id;
    this.name = data.name;
    this.price = data.price * multiplier;
    this.cost = data.cost;
    this.qty = data.qty * multiplier;
  }

  BModifierData.fromJson(Map json)
      : id = json["id"],
        name = json["name"],
        price = json["price"],
        cost = json["cost"];
        
  Map objectToServer() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['modifier_id'] = this.id;
    map['title'] = this.name;
    map['price'] = this.price;
    map['amount'] = this.price;
    map['qty'] = this.qty;
    map['discount_percentage'] = 0;
    map['discount_amount'] = 0;

    return map;
  }

/* -------------------------------------------------------------------------- */
/*                                     DB                                     */
/* -------------------------------------------------------------------------- */
  Map toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = this.id;
    map['name'] = this.name;
    map['price'] = this.price;
    map['cost'] = this.cost;
    map['qty'] = this.qty;

    return map;
  }

  BModifierData.fromMap(Map<dynamic, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];
    this.price = map['price'];
    this.cost = map['cost'];
    this.qty = map['qty'];
  }
}
