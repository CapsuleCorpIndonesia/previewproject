
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BPayment.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/SyncData.dart';
import 'package:pawoon/Helper/Wgt.dart';

class BayarSukses extends StatefulWidget {
  @override
  _BayarSuksesState createState() => _BayarSuksesState();
}

class _BayarSuksesState extends State<BayarSukses> {
  bool enableEmail = false;
  BOrderParent order;
  BPayment payment;
  TextEditingController contEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      order = Helper.getPageData(context)["order"];
      if (order.pelanggan.email != null) contEmail.text = order.pelanggan.email;
    }
    if (payment == null) payment = Helper.getPageData(context)["payment"];

    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Pembayaran Sukses"), body: body());
  }

  Widget body() {
    String imgName = "";
    String method = "";
    for (var item in order.payment) {
      if (item.method == "gopay") {
        imgName = "logo_gopay.png";
      }

      method = item.title;
    }
    return Center(
        child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.max, children: [
      // Expanded(child: Container()),
      Wgt.spaceTop(40),
      Icon(Icons.check_circle, color: Cons.COLOR_PRIMARY, size: 100),
      Wgt.spaceTop(20),
      Row(children: [
        Expanded(child: Container()),
        Wgt.text(context, "Pembayaran dengan  ",
            size: Wgt.FONT_SIZE_NORMAL_2, color: Colors.grey[700]),
        if (imgName == "")
          Wgt.text(context, "$method",
              size: Wgt.FONT_SIZE_NORMAL_2, color: Colors.grey[700]),
        if (imgName != "") Image.asset("assets/$imgName", height: 40),
        Wgt.text(context, "  berhasil dilakukan",
            size: Wgt.FONT_SIZE_NORMAL_2, color: Colors.grey[700]),
        Expanded(child: Container()),
      ]),
      Wgt.spaceTop(10),
      uangKembali(),
      Wgt.spaceTop(20),
      kirimEmail(),
      Wgt.spaceTop(20),
      Container(
          width: MediaQuery.of(context).size.width / 4 + 180,
          child:
              Wgt.btn(context, "SELESAI", onClick: () => doSaveTransaction())),
      // Debug json pakai ini
      // InkWell(
      //     onTap: () {
      //       Clipboard.setData(ClipboardData(
      //           text: "${json.encode([order.objectToServer()])}"));
      //     },
      //     child: Wgt.text(context, "${json.encode([order.objectToServer()])}")),
      // Expanded(child: Container()),
      Wgt.spaceTop(40),
    ])));
  }

  Widget uangKembali() {
    int change = 0;
    if (order != null) change = order.total_change;
    if (payment != null) change = payment.change.toInt();
    return Container(
        margin: EdgeInsets.only(top: 20, bottom: 0),
        child: Column(children: [
          Wgt.text(context, "Uang Kembali",
              size: Wgt.FONT_SIZE_NORMAL_2, color: Colors.grey[700]),
          Wgt.textLarge(context, "${Helper.formatRupiahInt(change)}",
              size: Wgt.FONT_SIZE_LARGE_X,
              color: Colors.grey[700],
              weight: FontWeight.bold)
        ]));
  }

  Widget kirimEmail() {
    return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]),
            borderRadius: BorderRadius.circular(5)),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email, color: Colors.grey[500], size: 40),
              Wgt.spaceLeft(20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wgt.text(context, "Kirim struk ke email",
                    weight: FontWeight.w100),
                Container(
                    margin: EdgeInsets.only(top: 10),
                    width: MediaQuery.of(context).size.width / 4,
                    child: CustomInput(
                        enabled: enableEmail,
                        borderColor: Colors.grey[300],
                        displayUnderline: true,
                        hint: "Masukkan email tujuan",
                        type: TextInputType.emailAddress,
                        controller: contEmail,
                        bordered: false)),
              ]),
              Wgt.spaceLeft(20),
              CupertinoSwitch(
                  value: enableEmail,
                  onChanged: (val) {
                    enableEmail = !enableEmail;
                    setState(() {});
                  },
                  activeColor: Cons.COLOR_PRIMARY)
            ]));
  }

  Future<void> doSaveTransaction() async {
    if (order != null) {
      if (contEmail.text != "" && enableEmail)
        order.pelanggan.email = contEmail.text;
      updateTimestamps();

      // Clipboard.setData(
      //     ClipboardData(text: "${json.encode([order.objectToServer()])}"));
      // Clipboard.setData(ClipboardData(text: "${Logic.ACCESS_TOKEN}"));

      await DBPawoon()
          .delete(tablename: DBPawoon.DB_ORDERS, data: order.toMap());
      order.id = null;
      await DBPawoon()
          .insert(tablename: DBPawoon.DB_TRANSACTION, data: order.toMap());
      await DBPawoon().incrementLocalId(id: order.id);
      await hitungStock();

      Helper.printReceipt(context, order, showSelection: false);
      SyncData.updateUnsyncCount();
      // syncTransactions();

      Helper.toastSuccess(context, "Pesanan Tersimpan");
      Helper.closePage(context, payload: {"sukses": true});
    } else if (payment != null) {
      payment.done = true;
      Helper.closePage(context, payload: {"sukses": true});
    }
  }

  void updateTimestamps() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String t = Helper.formatISOTime(Helper.toDate(
        parseToFormat: "yyyy-MM-dd'T'HH:mm:ss", timestamp: timestamp));

    order.timestamp = timestamp;
    for (var p in order.payment) {
      p.timestamp = t;
    }
  }

  Future hitungStock() {
    List<Future> arrFut = List();
    order.mappingOrder.forEach((key, value) {
      value.product.stock = value.product.stock - value.qty;
      arrFut.add(DBPawoon()
          .update(tablename: DBPawoon.DB_PRODUCTS, data: value.product.toDb()));
    });

    return Future.wait(arrFut);
  }
}
