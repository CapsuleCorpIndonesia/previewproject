import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BPayment.dart';
import 'package:pawoon/Bean/BPaymentCustom.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/Views/RekapPopup.dart';

import '../main.dart';

class SplitPayment extends StatefulWidget {
  @override
  _SplitPaymentState createState() => _SplitPaymentState();
}

class _SplitPaymentState extends State<SplitPayment> {
  List<BPayment> arr1 = List();
  // List<BPaymentCustom> arr2 = List();
  BOrderParent orderParent;

  @override
  void initState() {
    super.initState();
    arr1.add(BPayment.cash());
    arr1.add(BPayment.card());
  }

  @override
  Widget build(BuildContext context) {
    if (orderParent == null) {
      orderParent = Helper.getPageData(context)["orderParent"];
      for (BPaymentCustom p in orderParent.outlet.company.paymentmethods) {
        BPayment payment = BPayment.custom();
        payment.isiCustom(customPayment: p);
        arr1.add(payment);
      }
      // arr2.addAll(orderParent.outlet.company.paymentmethods);
      doSplit();
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Split Payment"), body: body());
  }

  Widget body() {
    return Center(
        child: Container(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(40),
                child: Column(children: [
                  Wgt.textLarge(context, "Total Tagihan",
                      color: Colors.grey[600], weight: FontWeight.w600),
                  Row(children: [
                    Expanded(flex: 1, child: Container()),
                    Expanded(flex: 6, child: wTagihan()),
                    Expanded(flex: 1, child: Container()),
                  ]),
                  Wgt.spaceTop(40),
                  Wgt.textLarge(context, "Split Pembayaran",
                      color: Colors.grey[800], weight: FontWeight.bold),
                  listSelections(),
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      width: 400,
                      child: Wgt.btn(context, "Tambah Metode Pembayaran",
                          transparent: true,
                          onClick: () => doAddMethod(),
                          borderColor: Cons.COLOR_PRIMARY,
                          textcolor: Cons.COLOR_PRIMARY)),
                ]))));
  }

  Widget wTagihan() {
    String tagihan = Helper.formatRupiahDouble(orderParent.grandTotal);
    return Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Color(0xFFF1F9FA),
            border: Border.all(color: Colors.grey[300], width: 3.0)),
        child: Row(children: [
          Expanded(
              child: Wgt.textLarge(context, "$tagihan",
                  size: Wgt.FONT_SIZE_LARGE_X,
                  weight: FontWeight.bold,
                  align: TextAlign.center)),
        ]));
  }

  void doAddMethod() {
    BPayment pay = BPayment.cash();
    pay.amount = 0;
    arrSelections.add(pay);
    setState(() {});
  }

  void doSplit() {
    if (orderParent == null) return;
    arrInputs.clear();
    arrSelections.clear();

    int harga1 = (orderParent.grandTotal / 2).ceil();
    int harga2 = orderParent.grandTotal.toInt() - harga1;
    BPayment pay1 = BPayment.cash();
    pay1.amount = harga1;
    arrSelections.add(pay1);

    BPayment pay2 = BPayment.cash();
    pay2.amount = harga2;
    arrSelections.add(pay2);
    setState(() {});
  }

  List<BPayment> arrSelections = List();
  List<CustomInput> arrInputs = List();
  Widget listSelections() {
    return ListView.builder(
        itemCount: arrSelections.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return cellSelection(index);
        });
  }

  Widget cellSelection(index) {
    BPayment item = arrSelections[index];
    bool done = item.done;
    String method = "";
    method = item.title;

    CustomInput input;
    if (arrInputs.isEmpty ||
        arrInputs.length <= index ||
        arrInputs[index] == null) {
      TextEditingController cont = TextEditingController();
      // cont.addListener(() {
      //   // String text = cont.text.replaceAll("Rp.", "").replaceAll(",", "");
      //   // cont.text = Helper.formatRupiah(text);
      // });
      cont.text = "${item.amount}";
      input = CustomInput(
          polosan: true, controller: cont, type: TextInputType.number);
      arrInputs.add(input);
    } else {
      input = arrInputs[index];
    }
    bool showDelete = arrSelections.length > 2;

    return Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Row(children: [
          Expanded(flex: 2, child: Container()),
          Wgt.spaceLeft(20),
          Expanded(
              flex: 3,
              child: Wgt.btn(context, "$method",
                  onClick: () => doChangeType(index),
                  transparent: !done,
                  height: 50,
                  enabled: !done,
                  borderColor: done ? Colors.grey : Cons.COLOR_PRIMARY,
                  textcolor: done ? Colors.white : Cons.COLOR_PRIMARY)),
          Wgt.spaceLeft(20),
          Expanded(
              flex: 3,
              child: Container(
                  height: 50,
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[500]),
                      color: done ? Colors.grey[500] : Colors.transparent),
                  child: done
                      ? Center(
                          child: Row(children: [
                          Expanded(
                              child: Wgt.text(context, "${item.amount}",
                                  color: Colors.white)),
                        ]))
                      : input)),
          Wgt.spaceLeft(20),
          Expanded(
              flex: 3,
              child: Wgt.btn(context, "Bayar",
                  enabled: !done, height: 50, onClick: () => doBayar(index))),
          Wgt.spaceLeft(20),
          showDelete && !done
              ? Expanded(flex: 2, child: btnHapus(index))
              : Expanded(flex: 2, child: done ? btnSukses() : Container()),
        ]));
  }

  Widget btnHapus(index) {
    return Container(
        height: 50,
        child: InkWell(
            onTap: () => doDelete(index),
            child: Container(
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red[700]),
                ),
                child: Row(children: [
                  Expanded(child: Container()),
                  Icon(Icons.delete, color: Colors.red[700]),
                  Wgt.spaceLeft(10),
                  Wgt.textSecondary(context, "Hapus", color: Colors.red[700]),
                  Expanded(child: Container()),
                ]))));
  }

  Widget btnSukses() {
    return Container(
        height: 50,
        child: Container(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
            ),
            child: Row(children: [
              Expanded(child: Container()),
              Icon(Icons.check_circle_sharp, color: Colors.green),
              Wgt.spaceLeft(10),
              Wgt.textSecondary(context, "Lunas", color: Colors.green),
              Expanded(child: Container()),
            ])));
  }

  void doDelete(index) {
    arrSelections.removeAt(index);
    arrInputs.removeAt(index);
    setState(() {});

    if (arrSelections.length == 2) {
      doSplit();
    }
  }

  Future<void> doChangeType(index) async {
    var item = await showDialog(
        context: context,
        builder: (_)=> PopupPaymentType(arr1: arr1, selected: arrSelections[index]));
    if (item != null) {
      arrSelections[index] = item;
      setState(() {});
    }
  }

  void doBayar(index) {
    Helper.openPage(context, Main.BAYAR,
        arg: {"payment": arrSelections[index]});
  }
}

class PopupPaymentType extends StatefulWidget {
  List<BPayment> arr1 = List();
  List<BPaymentCustom> arr2 = List();
  BPayment selected;
  PopupPaymentType({this.arr1, this.arr2, this.selected});
  @override
  _PopupPaymentTypeState createState() => _PopupPaymentTypeState();
}

class _PopupPaymentTypeState extends State<PopupPaymentType> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: MediaQuery.of(context).size.width / 2,
            child: SingleChildScrollView(
                child: Column(children: [
              JudulPopup(context: context, title: "Custom Payment"),
              Wgt.separator(),
              Container(
                  padding: EdgeInsets.only(left: 20, top: 20, right: 20),
                  child: Column(children: [
                    list1(),
                    // list2(),
                    Row(children: [
                      Expanded(
                          child: Wgt.btn(context, "SIMPAN",
                              color: Cons.COLOR_ACCENT,
                              onClick: () => doSimpan())),
                    ]),
                    Wgt.spaceTop(20),
                  ])),
            ]))));
  }

  Widget list1() {
    return Column(
        children: List.generate(widget.arr1.length, (index) {
      return cell(title: widget.arr1[index].title, id: widget.arr1[index]);
    }));
  }

  Widget list2() {
    return Column(
        children: List.generate(widget.arr2.length, (index) {
      return cell(title: widget.arr2[index].name);
    }));
  }

  Widget cell({title, id}) {
    bool active = widget.selected.company_method_id == id.company_method_id &&
        widget.selected.method == id.method;
    // bool active = true;
    return Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Material(
          color: active ? Cons.COLOR_PRIMARY : Colors.transparent,
          child: InkWell(
              onTap: () => doSelect(id: id),
              child: Row(children: [
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            border: Border.all(color: Cons.COLOR_PRIMARY)),
                        child: Wgt.text(context, "$title",
                            color: active ? Colors.white : Colors.black,
                            align: TextAlign.center))),
              ])),
        ));
  }

  void doSelect({id}) {
    widget.selected = id;
    setState(() {});
  }

  void doSimpan() {
    Helper.closePage(context, payload: widget.selected);
  }
}
