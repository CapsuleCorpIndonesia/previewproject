import 'package:pawoon/Bean/BPayment.dart';

class BPaymentCustom {
  var id;
  var name;
  var amount;

  BPaymentCustom.clone(item) {
    if (item == null) return;
    // print("item: ${item.id}");
    id = item.id;
    name = item.name;
    amount = item.amount;
  }

  BPaymentCustom.fromJson(Map json)
      : id = json["id"],
        name = json["name"];
  BPaymentCustom.fromJson2(Map json)
      : id = json["id"],
        name = json["title"],
        amount = json["amount"];

  BPaymentCustom.fromMap(Map map) {
    this.id = map["id"];
    this.name = map["name"];
  }

  Map toMap() {
    Map map = Map();
    map["id"] = this.id;
    map["name"] = this.name;
    return map;
  }
}
