import 'package:pawoon/Bean/BPaymentCustom.dart';
import 'package:pawoon/Helper/Helper.dart';

import 'BPaymentResponse.dart';

class BPayment {
  var method;
  var company_method_id = "";
  var timestamp;
  var title;
  var id = 0;
  num amount = 0;
  double change = 0;
  double bayar = 0;
  bool done = false;

  BPaymentCustom custom;
  BPaymentResponse response;
  String responseRaw;

  BPayment();

  BPayment.clone(item, {multiplier = 1}) {
    if (item == null) return;
    method = item.method;
    company_method_id = item.company_method_id;
    timestamp = item.timestamp;
    title = item.title;
    id = item.id;
    amount = item.amount * multiplier;
    change = item.change * multiplier;
    bayar = item.bayar * multiplier;
    done = item.done;
    response = item.response;
    custom = BPaymentCustom.clone(item.custom);
  }

  BPayment.cash() {
    method = "cash";
    title = "Tunai";
    timestamp = Helper.formatISOTime(Helper.toDate(
        parseToFormat: "yyyy-MM-dd'T'HH:mm:ss", datetime: DateTime.now()));
  }

  BPayment.card() {
    method = "card";
    title = "Kartu";
    timestamp = Helper.formatISOTime(Helper.toDate(
        parseToFormat: "yyyy-MM-dd'T'HH:mm:ss", datetime: DateTime.now()));
  }

  BPayment.custom() {
    method = "others";
    title = "Lainnya";
    timestamp = Helper.formatISOTime(Helper.toDate(
        parseToFormat: "yyyy-MM-dd'T'HH:mm:ss", datetime: DateTime.now()));

    // Title ambil dari webservice
  }
/*""method"" -> ""gopay""
""title"" -> ""GoPay""

""method"" -> ""ovo""
""title"" -> ""OVO""

""method"" -> ""dana""
""title"" -> ""DANA""

""method"" -> ""linkaja""
""title"" -> ""LinkAja""

""method"" -> ""shopeepay""
""title"" -> ""ShopeePay""
*/
  BPayment.gopay() {
    method = "gopay";
    title = "GoPay";
    timestamp = Helper.formatISOTime(Helper.toDate(
        parseToFormat: "yyyy-MM-dd'T'HH:mm:ss", datetime: DateTime.now()));
  }
  BPayment.linkAja() {
    method = "linkaja";
    title = "LinkAja";
    timestamp = Helper.formatISOTime(Helper.toDate(
        parseToFormat: "yyyy-MM-dd'T'HH:mm:ss", datetime: DateTime.now()));
  }

  void isiCustom({BPaymentCustom customPayment}) {
    if (customPayment != null) {
      title = customPayment.name;
      this.custom = customPayment;
      this.company_method_id = customPayment.id;
    }
  }

  Map toObjectServer({multiplier = 1}) {
    Map map = Map();
    map["id"] = this.id;
    map["amount"] = this.amount * multiplier;
    map["change"] = this.change * multiplier;
    map["method"] = this.method;
    map["company_payment_method_id"] = this.company_method_id;
    map["timestamp"] = this.timestamp;
    map["title"] = this.title;
    // map["responseRaw"] = this.responseRaw;
    return map;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map["id"] = this.id;
    map["amount"] = this.amount;
    map["change"] = this.change;
    map["method"] = this.method;
    map["company_payment_method_id"] = this.company_method_id;
    map["timestamp"] = this.timestamp;
    map["title"] = this.title;
    map["responseRaw"] = this.responseRaw;

    return map;
  }

  BPayment.fromMap(Map map) {
    this.id = map["id"];
    this.amount = map["amount"];
    this.change = map["change"];
    this.method = map["method"];
    this.company_method_id = map["company_payment_method_id"];
    this.timestamp = map["timestamp"];
    this.title = map["title"];
    this.responseRaw = map["responseRaw"];
  }
}
