import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BDevice.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Bean/BRekap.dart';
import 'package:pawoon/Bean/BRekapCashflow.dart';
import 'package:pawoon/Bean/BRekapHitungan.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Lang.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';

/* -------------------------------------------------------------------------- */
/*                                   TAMBAH                                   */
/* -------------------------------------------------------------------------- */
class PopupRekapTambah extends StatefulWidget {
  BRekapCashflow rekapCashflow;

  @override
  PopupRekapTambahState createState() => PopupRekapTambahState();
}

class PopupRekapTambahState extends State<PopupRekapTambah> {
  String selectedMode = Cons.KAS_MASUK;
  CustomInput inputJumlah;
  CustomInput inputNotes;
  TextEditingController contJumlah = TextEditingController();
  TextEditingController contNotes = TextEditingController();
  bool inputValid1 = false;
  bool inputValid2 = false;
  @override
  void initState() {
    super.initState();
    inputJumlah = CustomInput(
        hint: "Jumlah",
        formatCurrency: true,
        controller: contJumlah,
        type: TextInputType.number,
        validator: (text) {
          inputValid1 = false;
          if (text == "") return "*Tidak boleh kosong";
          // if (num.tryParse(text) == null) return "Format salah";
          inputValid1 = true;
          setState(() {});
          return "";
        });
    inputNotes = CustomInput(
        hint: "Catatan",
        controller: contNotes,
        validator: (text) {
          inputValid2 = false;
          if (text == "") return "*Tidak boleh kosong";
          inputValid2 = true;
          setState(() {});
          return "";
        });
    if (widget.rekapCashflow == null) {
      widget.rekapCashflow = BRekapCashflow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: MediaQuery.of(context).size.width / 2,
            child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              JudulPopup(context: context, title: "Tambah Kas Masuk / Keluar"),
              Wgt.separator(),
              Container(
                  padding: EdgeInsets.all(20),
                  child: Column(children: [
                    Row(children: [
                      Expanded(
                          child: btnMode(
                              tag: Cons.KAS_MASUK, title: Lang.KAS_MASUK)),
                      Wgt.spaceLeft(10),
                      Expanded(
                          child: btnMode(
                              tag: Cons.KAS_KELUAR, title: Lang.KAS_KELUAR)),
                    ]),
                    Wgt.spaceTop(30),
                    inputJumlah,
                    Wgt.spaceTop(10),
                    inputNotes,
                    Wgt.spaceTop(40),
                    Row(children: [
                      Expanded(
                          child: Wgt.btn(context, "SIMPAN",
                              enabled: inputValid1 && inputValid2,
                              onClick: () => doSave(),
                              color: Cons.COLOR_ACCENT)),
                    ])
                  ]))
            ]))));
  }

  Widget btnMode({tag, title}) {
    bool active = tag == selectedMode;
    return InkWell(
        onTap: () {
          selectedMode = tag;
          setState(() {});
        },
        child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                    color: active ? Cons.COLOR_PRIMARY : Colors.grey),
                color: active ? Cons.COLOR_PRIMARY : Colors.transparent),
            child: Wgt.text(context, "$title",
                align: TextAlign.center,
                color: active ? Colors.white : Colors.grey)));
  }

  void doSave() {
    if (contJumlah.text == "") {
      Helper.toastError(context, "Jumlah tidak boleh kosong");
      return;
    }
    if (contNotes.text == "") {
      Helper.toastError(context, "Catatan tidak boleh kosong");
      return;
    }

    String jumlah = contJumlah.text.replaceAll(RegExp("[^\\d]"), "");
    widget.rekapCashflow.note = contNotes.text;
    widget.rekapCashflow.type = selectedMode;
    if (selectedMode == Cons.KAS_KELUAR) {
      widget.rekapCashflow.title = Lang.KAS_KELUAR;
      widget.rekapCashflow.amount = double.parse(jumlah);
    } else {
      widget.rekapCashflow.title = Lang.KAS_MASUK;
      widget.rekapCashflow.amount = double.parse(jumlah);
    }

    Helper.closePage(context, payload: {"rekap": widget.rekapCashflow});
  }
}

/* -------------------------------------------------------------------------- */
/*                                  REKAP KAS                                 */
/* -------------------------------------------------------------------------- */
class PopupRekapKas extends StatefulWidget {
  PopupRekapKas({Key key}) : super(key: key);

  @override
  _PopupRekapKasState createState() => _PopupRekapKasState();
}

class _PopupRekapKasState extends State<PopupRekapKas> {
  // Map<String, CustomInput> arrInputs = Map();
  // List<Widget> arrCell = List();
  // List<TextEditingController> arrController = List();
  Loader2 loader = Loader2();
  String outletid = "";
  bool showAmount = false;
  BOutlet outlet;
  BOperator op;
  BDevice device;
  // Map<String, int> mapValue = Map();
  int total = 0;
  int totalSeharusnya = 0;
  int isidata = 0;

  Map<String, BRekapHitungan> mapHitungan = Map();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: MediaQuery.of(context).size.width / 2,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                JudulPopup(context: context, title: "Rekap Kas"),
                Wgt.separator(),
                loader.isLoading ? loader : body()
              ]),
            )));
  }

  Widget body() {
    total = 0;
    mapHitungan.forEach((key, value) {
      total += value.amount.toInt();
    });
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(children: [
          Column(
              children: List.generate(mapHitungan.length, (index) {
            String key = mapHitungan.keys.toList()[index];
            return mapHitungan[key].cell;
          })),
          Wgt.spaceTop(20),
          Wgt.separator(color: Colors.grey),
          Wgt.spaceTop(20),
          Container(
              child: Row(children: [
            Wgt.text(context, "TOTAL", weight: FontWeight.bold),
            Expanded(child: Container()),
            Wgt.text(context, "${Helper.formatRupiahInt(total)}"),
          ])),
          if (showAmount != null && showAmount)
            Row(children: [
              Wgt.textSecondary(context, "Jumlah seharusnya ",
                  color: Colors.grey[600]),
              Wgt.textSecondary(
                  context, "${Helper.formatRupiahInt(totalSeharusnya)}",
                  color: Colors.grey[600], weight: FontWeight.bold),
            ]),
          Wgt.spaceTop(20),
          Wgt.separator(color: Colors.grey),
          Wgt.spaceTop(20),
          Row(children: [
            Expanded(
                child: Wgt.btn(context, "SIMPAN",
                    color: Cons.COLOR_ACCENT, onClick: () => doSimpan())),
          ]),
        ]));
  }

  void addInput({title, String amount, tag, enabled = true}) {
    BRekapHitungan hitungan;
    if (mapHitungan[tag] != null) {
      hitungan = mapHitungan[tag];
    } else {
      hitungan = BRekapHitungan();
      hitungan.tag = tag;
      mapHitungan[hitungan.tag] = hitungan;

      if (!enabled) {
        hitungan.amount = num.parse(amount);
      }

      TextEditingController cont = TextEditingController();
      cont.addListener(() {
        if (cont.text != "") {
          String jumlah = cont.text.replaceAll(RegExp("[^\\d]"), "");
          hitungan.amount = num.parse(jumlah).toDouble();
          setState(() {});
        }
      });

      CustomInput input = CustomInput(
          hint: "0",
          type: TextInputType.number,
          controller: cont,
          polosan: true,
          formatCurrency: true,
          enabled: enabled,
          textAlign: TextAlign.right);
      if (!enabled) {
        cont.text = Helper.formatRupiah(amount);
      }

      hitungan.input = input;
      hitungan.controller = cont;
    }

    if (title == "cash-out") {
      totalSeharusnya -= num.parse(amount).toInt();
      hitungan.seharusnya -= num.parse(amount).toDouble();
    } else {
      totalSeharusnya += num.parse(amount).toInt();
      hitungan.seharusnya += num.parse(amount).toDouble();
    }

    if (title == "cash-in" || title == "cash-out") title = "Tunai";
    hitungan.title = title;

    hitungan.cell = Container(
        padding: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
        child: Column(children: [
          Row(children: [
            Wgt.text(
                context, "${title.toString().replaceAll("integrated_", "")}"),
            Expanded(child: hitungan.input),
          ]),
          Wgt.separator(),
          if (showAmount != null && showAmount)
            Container(
                padding: EdgeInsets.only(top: 10, bottom: 0),
                child: Row(children: [
                  Wgt.textSecondary(context, "Jumlah seharusnya ",
                      color: Colors.grey[600]),
                  Wgt.textSecondary(context,
                      "${Helper.formatRupiahInt(hitungan.seharusnya.toInt())}",
                      color: Colors.grey[600], weight: FontWeight.bold),
                ]))
        ]));

    setState(() {});
  }

  Future<void> loadData() async {
    List<Future> arrFut1 = List();
    arrFut1.add(UserManager.getString(UserManager.OUTLET_ID)
        .then((value) => outletid = value));
    arrFut1.add(UserManager.getBool(UserManager.SETTING_SALDO_REKAP)
        .then((value) => showAmount = value));

    arrFut1.add(UserManager.getString(UserManager.OUTLET_OBJ).then((value) {
      if (value != null && value != "")
        outlet = BOutlet.parseObject(json.decode(value));
    }));
    arrFut1.add(UserManager.getString(UserManager.OPERATOR_OBJ).then((value) {
      if (value != null && value != "")
        op = BOperator.parseObject(json.decode(value));
    }));
    arrFut1.add(UserManager.getString(UserManager.DEVICE_OBJ).then((value) {
      if (value != null && value != "")
        device = BDevice.parseObject(json.decode(value));
    }));
    await Future.wait(arrFut1);
    if (op.type != "owner") showAmount = false;

    List<Future> arrFut = List();
    await getRekapCashflow();
    await getRekapCashCards();
    await getRekapCustomPayments();
    await getRekapIntegratedPayments();
    await getRekapGet();
    await Future.wait(arrFut);

    loader.isLoading = false;
    setState(() {});

    if (isidata == 0) {
      Helper.closePage(context);
      Helper.popupDialog(context,
          title: "Perhatian", text: "Tidak ada data untuk direkap");
    }
  }

  Future getRekapCashflow() {
    return Logic(context).rekapCashflow(success: (json) {
      print("cashflow : $json");
      for (var item in json["data"]) {
        addInput(title: item["title"], amount: item["amount"], tag: "Tunai");
      }
      if (json["data"] != null) isidata += json["data"].length;
    });
  }

  Future getRekapCashCards() {
    return Logic(context).rekapCashCards(success: (json) {
      print("cashcard : $json");
      bool tunaiSudah = false;
      bool kartuSudah = false;
      for (var item in json["data"]) {
        if (item["title"] == "Tunai") tunaiSudah = true;
        if (item["title"] == "Kartu") kartuSudah = true;

        addInput(
            title: item["title"], amount: item["amount"], tag: item["title"]);
      }
      if (json["data"] != null) isidata += json["data"].length;

      if (!tunaiSudah) addInput(title: "Tunai", amount: "0", tag: "Tunai");
      if (!kartuSudah) addInput(title: "Kartu", amount: "0", tag: "Kartu");
    });
  }

  Future getRekapCustomPayments() {
    return Logic(context).rekapCustomPayments(success: (json) {
      print("custom : $json");
      for (var item in json["data"]) {
        addInput(
            title: item["title"], amount: item["amount"], tag: item["uuid"]);
      }
      if (json["data"] != null) isidata += json["data"].length;
    });
  }

  Future getRekapIntegratedPayments() {
    return Logic(context).rekapIntegratedPayments(success: (json) {
      print("integrated : $json");
      for (var item in json["data"]) {
        addInput(
            title: "integrated_${item["title"]}",
            amount: item["amount"],
            tag: "integrated_${item["title"]}",
            enabled: false);
      }
      if (json["data"] != null) isidata += json["data"].length;
    });
  }

  Future getRekapGet() {
    return Logic(context).rekapGet(
        outletid: outletid,
        success: (json) {
          // print(json);
        });
  }

  Future<void> doSimpan() async {
    // arrInputs.forEach((key, value) {
    //   if (value.controller.text == "") value.controller.text = "0";
    // });

    BRekap rekap = BRekap();
    rekap.cashier_id = op.id;
    rekap.device_id = device.id;
    rekap.id = "0";
    rekap.sales_amount = total;
    rekap.order_begin = "";
    rekap.order_end = "";

    // if (arrInputs == null ||
    //     arrInputs["cash"] == null ||
    //     arrInputs["cash"].controller == null)
    //   rekap.total_cash = 0;
    // else

    // double cash = 0;
    // double noncash = 0;
    // if (mapHitungan["cash"] != null) cash = mapHitungan["cash"].amount;
    // if (mapHitungan["cards"] != null) noncash = mapHitungan["cards"].amount;
    // rekap.total_cash = cash.toInt();
    // rekap.total_non_cash = noncash.toInt();
    List<Map> customPayment = List();
    List<Map> integrated = List();
    mapHitungan.forEach((key, value) {
      if (key == "Tunai")
        rekap.total_cash = mapHitungan["Tunai"].amount.toInt();
      else if (key == "Kartu")
        rekap.total_non_cash = mapHitungan["Kartu"].amount.toInt();
      else if (value.title.startsWith("integrated_")) {
        integrated.add({
          "method": value.title.replaceAll("integrated_", ""),
          "amount": value.seharusnya,
        });
      } else
        customPayment.add({
          "amount": value.amount,
          "company_payment_method_id": key,
          "method": "custom",
          "title": value.title,
        });
    });
    // print(integrated);
    rekap.custom_payment = customPayment;
    rekap.recon_code = Helper.generateRandomString();
    rekap.outlet_id = outlet.id;
    rekap.integrated_payments = integrated;

    if (total == 0) {
      Helper.popupDialog(context,
          text: "Salah satu dari metode pembayaran harus diisi",
          title: "Perhatian");
      return;
    } else {
      List<Map> list = await DBPawoon().select(tablename: DBPawoon.DB_ORDERS);
      if (list.isNotEmpty) {
        Helper.confirm(context, "Perhatian",
            "Ada order yang belum diselesaikan. Anda yakin tetap melakukan rekap kas?",
            () async {
          Helper.closePage(context, payload: rekap);
        }, () {
          // Helper.closePageToHome(context);
        });
      } else {
        Helper.closePage(context, payload: rekap);
      }
    }
  }
}

/* -------------------------------------------------------------------------- */
/*                                    UTILS                                   */
/* -------------------------------------------------------------------------- */
class JudulPopup extends StatelessWidget {
  var context;
  var title;
  JudulPopup({this.context, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
        child: Row(children: [
          InkWell(
              child: Icon(Icons.clear, color: Colors.grey, size: 30),
              onTap: () {
                Helper.closePage(context);
              }),
          Wgt.spaceLeft(10),
          Wgt.text(context, "$title",
              size: Wgt.FONT_SIZE_NORMAL_2,
              weight: FontWeight.bold,
              color: Colors.grey[900]),
        ]));
  }
}
