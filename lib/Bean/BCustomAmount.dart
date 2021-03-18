class BCustomAmount {
  num total = 0;
  String notes = "";

  var id;
  var name;
  var sku;
  var price;
  var barcode;
  var desc;
  var img;
  var tax;
  var stock_unit;
  var type;
  var is_all_location_stock;
  var is_all_location_price;
  var is_sellable;
  var is_stock_tracked;
  var has_alertstock;
  var alert_stock_limit;
  var has_modifier;
  var has_variant;
  var use_outlet_tax;
  var parent_id;
  var v1_id;
  var amount;
  var updated_at;
  var deleted_at;

  BCustomAmount();
  BCustomAmount.clone(BCustomAmount item, {multiplier = 1}) {
    this.total = item.total;
    this.notes = item.notes;
    this.id = item.id;
    this.name = item.name;
    this.sku = item.sku;
    this.price = item.price;
    this.barcode = item.barcode;
    this.desc = item.desc;
    this.img = item.img;
    this.tax = item.tax;
    this.stock_unit = item.stock_unit;
    this.type = item.type;
    this.is_all_location_stock = item.is_all_location_stock;
    this.is_all_location_price = item.is_all_location_price;
    this.is_sellable = item.is_sellable;
    this.is_stock_tracked = item.is_stock_tracked;
    this.has_alertstock = item.has_alertstock;
    this.alert_stock_limit = item.alert_stock_limit;
    this.has_modifier = item.has_modifier;
    this.has_variant = item.has_variant;
    this.use_outlet_tax = item.use_outlet_tax;
    this.parent_id = item.parent_id;
    this.v1_id = item.v1_id;
    this.amount = item.amount;
    this.updated_at = item.updated_at;
    this.deleted_at = item.deleted_at;
  }
  BCustomAmount.fromJson(Map json)
      : id = json["id"],
        name = json["name"],
        sku = json["sku"],
        price = json["price"],
        barcode = json["barcode"],
        desc = json["desc"],
        img = json["img"],
        tax = json["tax"],
        stock_unit = json["stock_unit"],
        type = json["type"],
        is_all_location_stock = json["is_all_location_stock"],
        is_all_location_price = json["is_all_location_price"],
        is_sellable = json["is_sellable"],
        is_stock_tracked = json["is_stock_tracked"],
        has_alertstock = json["has_alertstock"],
        alert_stock_limit = json["alert_stock_limit"],
        has_modifier = json["has_modifier"],
        has_variant = json["has_variant"],
        use_outlet_tax = json["use_outlet_tax"],
        parent_id = json["parent_id"],
        v1_id = json["v1_id"],
        amount = json["amount"],
        updated_at = json["updated_at"],
        deleted_at = json["deleted_at"];

  Map toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['total'] = total;
    map['notes'] = notes;
    return map;
  }

  BCustomAmount.fromMap(Map<dynamic, dynamic> map) {
    this.total = map['total'];
    this.notes = map['notes'];
  }

  Map toObjectLocal() {
    Map<String, dynamic> map = Map();
    map["id"] = this.id;
    map["name"] = this.name;
    map["sku"] = this.sku;
    map["price"] = this.price;
    map["barcode"] = this.barcode;
    map["desc"] = this.desc;
    map["img"] = this.img;
    map["tax"] = this.tax;
    map["stock_unit"] = this.stock_unit;
    map["type"] = this.type;
    map["is_all_location_stock"] = this.is_all_location_stock;
    map["is_all_location_price"] = this.is_all_location_price;
    map["is_sellable"] = this.is_sellable;
    map["is_stock_tracked"] = this.is_stock_tracked;
    map["has_alertstock"] = this.has_alertstock;
    map["alert_stock_limit"] = this.alert_stock_limit;
    map["has_modifier"] = this.has_modifier;
    map["has_variant"] = this.has_variant;
    map["use_outlet_tax"] = this.use_outlet_tax;
    map["parent_id"] = this.parent_id;
    map["v1_id"] = this.v1_id;
    map["amount"] = this.amount;
    map["updated_at"] = this.updated_at;
    map["deleted_at"] = this.deleted_at;
    return map;
  }
}
