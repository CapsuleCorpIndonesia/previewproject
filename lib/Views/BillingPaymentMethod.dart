import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BInvoice.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';

import '../main.dart';

class BillingPaymentMethod extends StatefulWidget {
  BillingPaymentMethod({Key key}) : super(key: key);

  @override
  BillingPaymentMethodState createState() => BillingPaymentMethodState();
}

class BillingPaymentMethodState extends State<BillingPaymentMethod> {
  Loader2 loader = Loader2();
  String billingType;
  String cycle;
  num total;
  String totalDevice;
  Map<String, String> mapPaymentMethod = Map();
  Map<String, String> mapImg = {
    "bca-va": "virtual_account_bca.png",
    "midtrans": "kartu_kredit.png",
    "va-permata": "transfer_bank_lain.png"
  };
  String selectedPayment = "";
  bool tncChecked = false;

  PullToRefresh pullToRefresh = PullToRefresh();
  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (billingType == null) {
      billingType = Helper.getPageData(context)["billingType"];
      cycle = Helper.getPageData(context)["cycle"];
      total = Helper.getPageData(context)["total"];
      totalDevice = Helper.getPageData(context)["totalDevice"];
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Pilih Metode Pembayaran"),
        body: Center(
            child: Container(
                width: MediaQuery.of(context).size.width / 2, child: body())));
  }

  Widget body() {
    return loader.isLoading
        ? loader
        : pullToRefresh.generate(
            onRefresh: () => refresh(), child: bodyDetails());
  }

  Widget bodyDetails() {
    return Container(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wgt.text(context, "Pilih Metode Pembayaran", color: Colors.grey[700]),
        Column(
            children:
                List.generate(mapPaymentMethod.length, (index) => cell(index))),
        Wgt.spaceTop(20),
        Row(children: [
          Checkbox(
              value: tncChecked,
              onChanged: (val) {
                tncChecked = val;
                setState(() {});
              },
              activeColor: Cons.COLOR_ACCENT),
          Expanded(
              child: Wrap(children: [
            Wgt.text(context, "Saya menyetujui "),
            InkWell(
                onTap: () => navSyaratKetentuan(),
                child: Wgt.text(context, "Syarat dan Ketentuan ",
                    color: Cons.COLOR_PRIMARY)),
            Wgt.text(context, ", serta "),
            InkWell(
                onTap: () => navPrivacy(),
                child: Wgt.text(context, "Kebijakan Privasi ",
                    color: Cons.COLOR_PRIMARY)),
            Wgt.text(context, "Pawoon."),
          ]))
        ]),
        Wgt.separator(color: Colors.grey, marginbot: 20, margintop: 20),
        Wgt.text(context, "Jumlah yang harus dibayarkan : ",
            color: Colors.grey),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wgt.text(context, "Rp ", color: Colors.grey),
          Wgt.textLarge(
              context, "${Helper.formatRupiahDouble(total, currency: "")}")
        ]),
        Wgt.spaceTop(20),
        Row(children: [
          Expanded(
              child: Wgt.btn(context, "MULAI BERLANGGANAN",
                  onClick: () => doCheckout(),
                  enabled: tncChecked && selectedPayment != "")),
        ]),
      ])),
    );
  }

  Widget cell(index) {
    String key = mapPaymentMethod.keys.toList()[index];
    bool active = selectedPayment == key;
    return Container(
        margin: EdgeInsets.only(top: 10),
        child: InkWell(
            onTap: () => selectPayment(tag: key),
            child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: active ? Cons.COLOR_PRIMARY : Colors.transparent,
                    border: Border.all(color: Cons.COLOR_PRIMARY),
                    borderRadius: BorderRadius.circular(5)),
                child: Row(children: [
                  Image.asset("assets/${mapImg[key]}", height: 20),
                  Wgt.spaceLeft(10),
                  Wgt.text(context, mapPaymentMethod[key],
                      color: active ? Colors.white : Colors.grey[700]),
                ]))));
  }

  void selectPayment({tag}) {
    selectedPayment = tag;
    setState(() {});
  }

  Future<void> refresh() async {
    await getPaymentMethod();
    setState(() {
      loader.isLoading = false;
      pullToRefresh.stopRefresh();
    });
  }

  Future<void> getPaymentMethod() {
    return Logic(context).billingPaymentMethod(success: (json) {
      if (json["data"] != null) {
        mapPaymentMethod.clear();
        for (var item in json["data"]) {
          mapPaymentMethod[item["method"]] = item["label"];
        }
      }
    });
  }

  Future<void> doCheckout() {
    // midtrans
    //  "client_base_url": "https://api-staging.pawoon.com/v2/billing-v2/midtrans",
    // "client_key": "SB-Mid-client-WNkot0AVHheEzN6S"

    Helper.showProgress(context);
    return Logic(context).billingCheckout(
        billingType: billingType,
        cycleType: cycle,
        paymentMethod: selectedPayment,
        totalDevice: totalDevice,
        success: (j) async {
          // print(j);
          if (j["data"] != null && j["data"]["invoice"] != null) {
            BInvoice invoice = BInvoice.fromJson(j["data"]["invoice"]);
            await UserManager.saveString(
                UserManager.INVOICE, json.encode(invoice.toMap()));

            if (invoice.payment_method == "bca-va") {
              navBca(invoice);
            } else {
              navMidtrans();
            }
          }
        });
  }

  void navBca(invoice) {
    Helper.closePageToHome(context);
    Helper.openPage(context, Main.BILLING_BCA, arg: {"invoice": invoice});
  }

  void navMidtrans() {}

  void navSyaratKetentuan() {
    Helper.openWebview(context,
        url: "https://www.pawoon.com/syarat-dan-ketentuan-layanan/");
  }

  void navPrivacy() {
    Helper.openWebview(context,
        url: "https://www.pawoon.com/kebijakan-privasi/");
  }
}
