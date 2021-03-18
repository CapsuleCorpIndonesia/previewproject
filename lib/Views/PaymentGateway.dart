import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BPayment.dart';
import 'package:pawoon/Bean/BPaymentResponse.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentGateway extends StatefulWidget {
  @override
  _PaymentGatewayState createState() => _PaymentGatewayState();
}

class _PaymentGatewayState extends State<PaymentGateway> {
  String type;
  String title = "";
  String imgName = "";
  String outletid;
  BOrderParent orderParent;
  Loader2 loader = Loader2();

  @override
  Widget build(BuildContext context) {
    if (orderParent == null) {
      orderParent = Helper.getPageData(context)["orderParent"];
      if (orderParent.payment.isNotEmpty &&
          orderParent.payment[0] != null &&
          orderParent.payment[0].responseRaw != null &&
          orderParent.payment[0].responseRaw != "") {
        orderParent.payment[0].response = BPaymentResponse.fromJson(
            json.decode(orderParent.payment[0].responseRaw));
      }
      type = Helper.getPageData(context)["type"];
      setupType();
    }

    return Wgt.base(context,
        appbar: Wgt.appbar(context,
            name: "$title",
            displayRight: true,
            rightText: "RELOAD BARCODE",
            displayLeft: true,
            leftIcon: InkWell(
                onTap: () => doCancel(),
                child: Icon(Icons.clear, color: Colors.white)),
            onRightClick: () => doReloadBarcode(),
            rightTextColor: Colors.white),
        body: WillPopScope(onWillPop: () async => false, child: body()));
  }

  Widget body() {
    if (loader.isLoading) return Center(child: loader);
    if (orderParent.payment[0].response == null) return Container();
    String qrUrl = "";
    String qrString = "";
    String amount = "";
    for (var item in orderParent.payment[0].response.payments) {
      amount = item.integrated_payment_response.gross_amount.toString();
      if (item.integrated_payment_response.qrString != null &&
          item.integrated_payment_response.qrString != "")
        qrString = item.integrated_payment_response.qrString;
      else {
        for (var actions in item.integrated_payment_response.actions) {
          if (actions.name == "generate-qr-code") {
            qrUrl = actions.url;
            // print("url : $qrUrl");
            break;
          }
        }
      }

      if (qrUrl != "" || qrString != "") break;
    }
    return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[100],
        child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 40, bottom: 40),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/$imgName", height: 70),
                  Wgt.spaceTop(10),
                  Wgt.text(context,
                      "Scan QR code dibawah untuk melakukan pembayaran",
                      color: Colors.grey[700]),
                  Wgt.spaceTop(40),
                  if (qrUrl != "")
                    Container(
                        margin: EdgeInsets.only(bottom: 40),
                        child: InkWell(
                            onTap: () => doCopyQr(),
                            child: Wgt.image(
                                url: qrUrl,
                                height: 300,
                                square: true,
                                roundedRadius: 7))),
                  if (qrString != "")
                    Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(20),
                        height: 300,
                        child: FittedBox(
                            child: QrImage(
                                data: "$qrString",
                                version: QrVersions.auto,
                                size: 300))),
                  Wgt.text(context, "${Helper.formatRupiah(amount)}",
                      size: Wgt.FONT_SIZE_LARGE_X,
                      weight: FontWeight.w700,
                      color: Colors.grey[700]),
                  Wgt.spaceTop(40),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Cons.COLOR_PRIMARY)),
                      child: Wgt.btn(context, "PERIKSA TRANSAKSI",
                          onClick: () => doCheckTransaksi(),
                          transparent: false,
                          borderColor: Cons.COLOR_PRIMARY,
                          padding: EdgeInsets.only(
                              left: 20, right: 20, top: 15, bottom: 15),
                          color: Colors.white,
                          textcolor: Cons.COLOR_PRIMARY,
                          weight: FontWeight.bold)),
                  Wgt.spaceTop(40),
                  Wgt.text(context, "Sistem Aplikasi Kasir",
                      color: Colors.grey[900]),
                  Wgt.spaceTop(10),
                  Image.asset("assets/logo_pawoon_b.png", height: 40),
                ])));
  }

  Future<void> loadLocalData() async {
    outletid = await UserManager.getString(UserManager.OUTLET_ID);
  }

  Future<void> setupType() async {
    if (type == null) return;
    await loadLocalData();

    if (type == "gopay") {
      title = "GoPay";
      imgName = "logo_gopay.png";
      await doGenerateGopay();
    }
    if (type == "linkaja") {
      title = "LinkAja";
      imgName = "logo_linkaja.png";
      await doGenerateLinkaja();
    }

    stopScheduler();
    runSchedulerSync();

    loader.isLoading = false;
    setState(() {});
  }

  Future<void> doSimpan() async {
    var hasil = await DBPawoon().insertOrUpdate(
        tablename: DBPawoon.DB_ORDERS, data: orderParent.toMap());
    Clipboard.setData(
        ClipboardData(text: "${json.encode(orderParent.toMap())}"));
    if (hasil != null && hasil >= 1) {
      await DBPawoon().incrementLocalId(id: orderParent.id);
    } else {
      Helper.toastError(context, "Data gagal tersimpan");
    }
  }

  Future doGenerateGopay() async {
    // loader.isLoading = true;
    // setState(() {});

    BPayment payment = BPayment.gopay();

    try {
      if (orderParent.payment[0].responseRaw != "") {
        payment.response = BPaymentResponse.fromJson(
            json.decode(orderParent.payment[0].responseRaw));
        orderParent.payment[0].response = payment.response;
        return;
      } else {
        orderParent.payment.clear();
        orderParent.payment.add(payment);
      }
    } catch (e) {}

    Map data = orderParent.objectToServer();
    // Clipboard.setData(ClipboardData(text: "${json.encode(data)}"));

    return Logic(context).paymentIntegration(
        data: {"data": json.encode(data)},
        outletid: outletid,
        success: (j) {
          if (j["data"] != null) {
            payment.response = BPaymentResponse.fromJson(j["data"]);
            payment.responseRaw = json.encode(j["data"]);

            doSimpan();
          }
        });
  }

  Future doGenerateLinkaja() async {
    // loader.isLoading = true;
    // setState(() {});
    BPayment payment = BPayment.linkAja();

    try {
      if (orderParent.payment[0].responseRaw != "") {
        payment.response = BPaymentResponse.fromJson(
            json.decode(orderParent.payment[0].responseRaw));
        orderParent.payment[0].response = payment.response;
        return;
      } else {
        orderParent.payment.clear();
        orderParent.payment.add(payment);
      }
    } catch (e) {}

    Map data = orderParent.objectToServer();
    return Logic(context).paymentIntegration(
        data: {"data": json.encode(data)},
        outletid: outletid,
        success: (j) {
          if (j["data"] != null) {
            payment.response = BPaymentResponse.fromJson(j["data"]);
            payment.responseRaw = json.encode(j["data"]);

            doSimpan();
          }
        });
  }

  void doCopyQr() {
    String url = "";
    for (var item in orderParent.payment[0].response.payments) {
      for (var actions in item.integrated_payment_response.actions) {
        if (actions.name == "generate-qr-code") {
          url = actions.url;
          break;
        }
      }
    }
    Clipboard.setData(ClipboardData(text: "$url"));
  }

  void doCheckTransaksi({showProgress = true}) {
    // if (paymentResponse == null || paymentResponse.payments == null) return;

    if (showProgress) Helper.showProgress(context);
    String paymentid;
    for (var item in orderParent.payment[0].response.payments) {
      paymentid = "${item.id}";
    }
    Logic(context)
        .paymentIntegrationCheck(
            outletid: outletid,
            data: {"transaction_payment_id": "$paymentid"},
            transactionid: orderParent.payment[0].response.id,
            success: (json) {
              if (json["data"] != null) {
                String status = json["data"]["status"];
                if (status == "PENDING")
                  paymentPending();
                else if (status == "FAILED")
                  paymentFailed();
                else if (status == "SUCCESS") paymentSuccess();
              }
            })
        .then((value) {
      Helper.hideProgress(context);
    });
  }

  void paymentFailed() {
    orderParent.payment.clear();

    Helper.closePage(context);
    Helper.popupDialog(context,
        title: "Payment FAILED", text: "Please try again");
  }

  void paymentPending() {}

  void paymentSuccess() {
    Helper.closePage(context,
        payload: {"orderParent": orderParent, "langsung": true});
  }

  void doReloadBarcode() {
    loader.isLoading = true;
    setState(() {});
    setupType();
  }

  StreamSubscription periodicCheck;
  StreamSubscription periodicCancel;
  void runSchedulerSync() {
    periodicCheck =
        new Stream.periodic(const Duration(seconds: 15)).listen((_) {
      doCheckTransaksi(showProgress: false);
    });

    periodicCancel =
        new Stream.periodic(const Duration(minutes: 1)).listen((_) {
      paymentFailed();
    });
  }

  void stopScheduler() {
    if (periodicCheck != null) periodicCheck.cancel();
    if (periodicCancel != null) periodicCancel.cancel();
  }

  @override
  void dispose() {
    stopScheduler();
    super.dispose();
  }

  void doCancel() {
    Helper.confirm(context, "$title",
        "Apakah Anda yakin membatalkan transaksi $title ini?", () {
      // Success

      orderParent.payment.clear();
      Helper.closePage(context);
    }, () {
      // Fail
    });
  }
}
