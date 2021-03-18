import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BBillings.dart';
import 'package:pawoon/Bean/BInvoice.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';

import '../main.dart';

class Billing extends StatefulWidget {
  Billing({Key key}) : super(key: key);

  @override
  _BillingState createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  TextEditingController contVoucher = TextEditingController();
  Loader2 loader = Loader2();
  PullToRefresh pullToRefresh = PullToRefresh();
  Map<String, Map> mapPlan = Map();
  BBillings billings;
  // SnK - https://www.pawoon.com/syarat-dan-ketentuan-layanan/
  // Privacy - https://www.pawoon.com/kebijakan-privasi/

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await UserManager.getString(UserManager.BILLING_OBJ).then((value) {
      if (value != null && value != "") {
        billings = BBillings.fromJson(json.decode(value));
      }
    });
    await refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Pilih Plan"), body: body());
  }

  Widget body() {
    if (billings == null) return Container();

    return loader.isLoading
        ? loader
        : Container(
            child: pullToRefresh.generate(
                onRefresh: () => refresh(),
                child: SingleChildScrollView(
                    child: Column(children: [
                  bannerInfo(),
                  bodyItems(),
                ]))));
  }

  Widget bannerInfo() {
    var date1 = DateTime.now();
    var date2 = Helper.parseDate(dateString: billings.trial_end_date);
    var difference = date2.difference(date1).inDays + 1;

    return Container(
        padding: EdgeInsets.all(10),
        color: Colors.yellow[100],
        child: Row(children: [
          Expanded(
              child: Wgt.text(
                  context, "Masa trial akan habis dalam $difference hari",
                  align: TextAlign.center, color: Colors.orange[700]))
        ]));
  }

  List<String> arrTextBasic = [
    "Transaksi aman dan nyaman tanpa batas",
    "Tingkatkan pendapatan anda dengan manajemen multioutlet yang mudah",
    "Keep on track dengan laporan komprehensif",
    "Tingkatkan kepuasan pelanggan dengan manajemen pelanggan dan promo",
    "Optimalkan pelayanan dengan manajemen karyawan",
  ];

  Widget bodyItems() {
    return Container(
        margin: EdgeInsets.only(top: 40, bottom: 40),
        width: MediaQuery.of(context).size.width * 3 / 4,
        child: Card(
            child: Row(children: [
          Expanded(
              flex: 1,
              child: Container(
                  color: Colors.lightBlue[50],
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                      child: Column(children: [
                    Wgt.text(context, "BASIC",
                        color: Cons.COLOR_PRIMARY, weight: FontWeight.w700),
                    Column(
                        children: List.generate(arrTextBasic.length, (index) {
                      return Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(children: [
                            Icon(Icons.check_circle,
                                color: Cons.COLOR_PRIMARY, size: 15),
                            Wgt.spaceLeft(10),
                            Expanded(
                                child: Wgt.textSecondary(
                                    context, arrTextBasic[index],
                                    color: Colors.grey[800], maxlines: 100)),
                          ]));
                    })),
                  ])))),
          Expanded(flex: 2, child: bodyKanan()),
        ])));
  }

  Widget bodyKanan() {
    return Container(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wgt.text(context, "Berlangganan Pawoon Sekarang"),
          Wgt.spaceTop(20),
          Row(children: [
            Expanded(child: paket1()),
            Wgt.spaceLeft(10),
            Expanded(child: paket12()),
          ]),
          Wgt.spaceTop(20),
          CustomInput(
              controller: contVoucher,
              hint: "Kode Voucher (Optional)",
              bordered: true,
              displayUnderline: false),
          Wgt.spaceTop(20),
          Row(children: [
            Expanded(
                child: Wgt.btn(context, "MULAI BERLANGGANAN",
                    onClick: () => doMulaiBerlangganan())),
          ])
        ]));
  }

  Widget paket1() {
    if (mapPlan["1"] == null) return Container();
    bool active = selectedPaket == "1";
    return InkWell(
        onTap: () => paketSelected(tag: "1"),
        child: Stack(children: [
          Positioned(
              child: Card(
                  child: Column(children: [
            Container(
                padding: EdgeInsets.all(15),
                color: active ? Cons.COLOR_ACCENT : Colors.grey[50],
                child: Row(children: [
                  Expanded(child: Container()),
                  Wgt.text(context, "1 Bulan ",
                      color: active ? Colors.white : Colors.black,
                      weight: FontWeight.w700),
                  Wgt.textSecondary(context, "per outlet",
                      color: active ? Colors.white : Colors.black),
                  Expanded(child: Container()),
                ])),
            Container(
                padding: EdgeInsets.all(25),
                child: Wgt.text(context,
                    "${Helper.formatRupiahInt(mapPlan["1"]["price"])}"))
          ])))
        ]));
  }

  Widget paket12() {
    if (mapPlan["12"] == null) return Container();
    bool active = selectedPaket == "12";
    num hemat = (mapPlan["1"]["price"] * 12 - mapPlan["12"]["price"]) /
        (mapPlan["1"]["price"] * 12) *
        100;
    return InkWell(
        onTap: () => paketSelected(tag: "12"),
        child: Stack(children: [
          Positioned(
              child: Card(
                  child: Column(children: [
            Container(
                padding: EdgeInsets.all(15),
                color: active ? Cons.COLOR_ACCENT : Colors.grey[50],
                child: Row(children: [
                  Expanded(child: Container()),
                  Wgt.text(context, "1 Tahun ",
                      color: active ? Colors.white : Colors.black,
                      weight: FontWeight.w700),
                  Wgt.textSecondary(context, "per outlet",
                      color: active ? Colors.white : Colors.black),
                  Expanded(child: Container()),
                ])),
            Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Wgt.text(context,
                        "${Helper.formatRupiahInt(mapPlan["12"]["price"])}"),
                    Wgt.spaceTop(5),
                    Wgt.textSecondarySmall(context,
                        "${Helper.formatRupiahInt(mapPlan["12"]["price"] / 12)} per bulan"),
                  ],
                ))
          ]))),
          Center(
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(100)),
                padding:
                    EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 10),
                child: Wgt.textSecondarySmall(
                    context, "Hemat ${hemat.round()}%",
                    color: Colors.white, weight: FontWeight.bold)),
          )
        ]));
  }

  String selectedPaket = "1";
  void paketSelected({tag}) {
    selectedPaket = tag;
    setState(() {});
  }

  Future<void> refresh() async {
    String strInvoice = await UserManager.getString(UserManager.INVOICE);
    if (strInvoice != null && strInvoice != "") {
      // print(strInvoice);
      BInvoice invoice = BInvoice.fromJson(json.decode(strInvoice));
      if (invoice.payment_method == "bca-va") {
        navBca(invoice);
      }
    } else {
      await getBilling();

      setState(() {
        pullToRefresh.stopRefresh();
        loader.isLoading = false;
      });
    }
    // await getPaymentMethod();
    // await paymentCheckout();
  }

  void navBca(invoice) {
    Helper.closePageToHome(context);
    Helper.openPage(context, Main.BILLING_BCA, arg: {"invoice": invoice});
  }

  void doMulaiBerlangganan() {
    Helper.openPage(context, Main.BILLING_PAYMENT_METHOD, arg: {
      "billingType": "1",
      "cycle": "$selectedPaket",
      "total": mapPlan[selectedPaket]["price"],
      "totalDevice": "1",
    });
  }

  Future<void> getBilling() async {
    var billingType = "1";
    /*
    1 = trial
    2 = paid
    */
    if (billings.subscription_type == "paid") {
      billingType = "2";
    }

    await Logic(context).billingPrice(
        billingType: "$billingType",
        cycleType: "1",
        totalDevice: "1",
        code: "",
        success: (json) {
          print(json);
          if (json["data"] != null)
            mapPlan["1"] = {
              "price": json["data"]["total_price"],
              "voucher": json["data"]["voucher"]
            };
        });

    await Logic(context).billingPrice(
        billingType: "$billingType",
        cycleType: "12",
        totalDevice: "1",
        code: "",
        success: (json) {
          if (json["data"] != null)
            mapPlan["12"] = {
              "price": json["data"]["total_price"],
              "voucher": json["data"]["voucher"]
            };
        });
  }

  Future checkInvoice({invoiceid}) {
    return Logic(context).billingCheck(
        invoiceid: invoiceid,
        success: (json) {
          print(json);
        });
  }
}
