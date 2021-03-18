class BLaporanProduct {
  var name;
  var qty;
  var type;
  var amount;
  BLaporanProduct.fromJson(Map json)
      : name = json["name"],
        qty = json["qty"],
        type = json["type"],
        amount = json["amount"];
}
