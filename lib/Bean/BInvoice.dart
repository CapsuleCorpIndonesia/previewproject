class BInvoice {
  var status;
  var payment_method;
  var virtual_account;
  var amount;
  var id;
  var number;
  var billing_type_description;
  var timestamp;

  BInvoice.fromJson(Map json)
      : status = json["status"],
        payment_method = json["payment_method"],
        virtual_account = json["virtual_account"],
        amount = json["amount"],
        id = json["id"],
        number = json["number"],
        billing_type_description = json["billing_type_description"] {
    if (json["timestamp"] == null)
      timestamp = DateTime.now().millisecondsSinceEpoch;
    else {
      timestamp = json["timestamp"];
    }
  }

  Map toMap() {
    Map map = Map();
    map["status"] = status;
    map["payment_method"] = payment_method;
    map["virtual_account"] = virtual_account;
    map["amount"] = amount;
    map["id"] = id;
    map["number"] = number;
    map["billing_type_description"] = billing_type_description;
    if (timestamp == null) timestamp = DateTime.now().millisecondsSinceEpoch;

    map["timestamp"] = timestamp;
    return map;
  }
}
