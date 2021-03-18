class BPaymentResponse {
  var id;
  var receipt_code;
  List<BPaymentResponseDetails> payments = List();
  BPaymentResponse.fromJson(Map json)
      : id = json["id"],
        receipt_code = json["receipt_code"] {
    if (json["payments"] != null) {
      for (var item in json["payments"]) {
        payments.add(BPaymentResponseDetails.fromJson(item));
      }
    }
  }
}

class BPaymentResponseDetails {
  var id;
  var payment_qr_string;
  var method;
  BPaymentResponseIntegration integrated_payment_response;

  BPaymentResponseDetails.fromJson(Map json)
      : id = json["id"],
        payment_qr_string = json["payment_qr_string"],
        method = json["method"] {
    if (json["integrated_payment_response"] != null)
      integrated_payment_response = BPaymentResponseIntegration.fromJson(
          json["integrated_payment_response"]);
  }
}

class BPaymentResponseIntegration {
  var status_code;
  var status_message;
  var transaction_id;
  var order_id;
  var merchant_id;
  var gross_amount;
  var currency;
  var payment_type;
  var transaction_time;
  var transaction_status;
  var fraud_status;
  var qrString;
  var merchantTrxID;
  List<BPaymentResponseIntegrationActions> actions = List();

  BPaymentResponseIntegration.fromJson(Map json)
      : status_code = json["status_code"],
        status_message = json["status_message"],
        transaction_id = json["transaction_id"],
        order_id = json["order_id"],
        merchant_id = json["merchant_id"],
        gross_amount = json["gross_amount"],
        currency = json["currency"],
        payment_type = json["payment_type"],
        transaction_time = json["transaction_time"],
        transaction_status = json["transaction_status"],
        fraud_status = json["fraud_status"],
        qrString = json["qrString"],
        merchantTrxID = json["merchantTrxID"] {
    if (json["actions"] != null) {
      for (var item in json["actions"]) {
        actions.add(BPaymentResponseIntegrationActions.fromJson(item));
      }
    }
  }
}

class BPaymentResponseIntegrationActions {
  var name;
  var method;
  var url;
  BPaymentResponseIntegrationActions.fromJson(Map json)
      : name = json["name"],
        method = json["method"],
        url = json["url"];
}
