import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pawoon/Bean/BGrabModifier.dart';
import 'package:pawoon/Bean/BGrabOrder.dart';
import 'package:pawoon/Bean/BGrabParent.dart';
import 'package:pawoon/Bean/BModifierData.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOrder.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/SyncData.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/Views/OrderPopups.dart';

import 'Order.dart';

class History extends StatefulWidget {
  History({Key key}) : super(key: key);

  @override
  _SavedState createState() => _SavedState();
}

class _SavedState extends State<History> {
  Map<String, List<dynamic>> mapData = Map();
  SplayTreeMap<String, List<dynamic>> mapDataFiltered = SplayTreeMap();
  Map<String, String> mapStatus = {
    "0": "Semua",
    "1": "Sukses",
    "2": "Berlangsung",
    "-1": "Void",
  };
  dynamic orderActive;
  CustomInput inputSearch;
  TextEditingController contSearch = TextEditingController();
  Dropdown2 ddStatus;
  BOperator op;

  @override
  void initState() {
    super.initState();
    inputSearch = CustomInput(
      hint: "Cari Transaksi",
      controller: contSearch,
      polosan: true,
    );
    contSearch.addListener(() {
      doFilter();
    });
    ddStatus = Dropdown2(
        list: mapStatus,
        selected: "0",
        showUnderline: false,
        onValueChanged: () {
          doFilter();
        });
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Riwayat Transaksi"), body: body());
  }

  Widget body() {
    return Container(
        child: Row(children: [
      Expanded(flex: 3, child: panelKiri()),
      Expanded(flex: 5, child: panelKanan()),
    ]));
  }

/* -------------------------------------------------------------------------- */
/*                                 PANEL KIRI                                 */
/* -------------------------------------------------------------------------- */
  Widget panelKiri() {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200])),
        child: Column(children: [
          search(),
          Wgt.separator(),
          Expanded(
              child: mapDataFiltered.isEmpty
                  ? panelKosong()
                  : ListView.builder(
                      itemCount: mapDataFiltered.length,
                      itemBuilder: (context, index) {
                        String key = mapDataFiltered.keys
                            .toList()
                            .reversed
                            .toList()[index];
                        List arr = mapDataFiltered[key];
                        return listHistory(tanggal: key, data: arr);
                      })),
        ]));
  }

  Widget panelKosong() {
    if (contSearch.text != "") return panelSearchKosong();
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Wgt.text(context, "Tidak Ada Transaksi",
              weight: FontWeight.bold, size: Wgt.FONT_SIZE_NORMAL_2),
          Wgt.spaceTop(10),
          Wgt.text(context, "Anda belum pernah melakukan transaksi",
              color: Colors.grey),
          Wgt.spaceTop(10),
          Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey),
        ]));
  }

  Widget panelSearchKosong() {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Wgt.text(context, "Tidak Ditemukan",
              weight: FontWeight.bold, size: Wgt.FONT_SIZE_NORMAL_2),
          Wgt.spaceTop(10),
          Wgt.text(context, "Transaksi yang Anda cari tidak ditemukan",
              color: Colors.grey),
          Wgt.spaceTop(10),
          Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey),
        ]));
  }

  Widget search() {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
        child: Row(children: [
          Icon(Icons.search, color: Colors.grey, size: 25),
          Expanded(child: inputSearch),
          Expanded(
              child: Container(
                  height: 40,
                  padding: EdgeInsets.only(left: 15, right: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Cons.COLOR_PRIMARY),
                      borderRadius: BorderRadius.circular(50)),
                  child: ddStatus)),
        ]));
  }

  void doFilter() {
    String filter = contSearch.text;
    filter = filter.toLowerCase();
    mapDataFiltered.clear();

    mapData.forEach((key, value) {
      for (dynamic parent in value) {
        bool ada = false;

        if (filter != "") {
          if (parent.runtimeType == BOrderParent) {
            parent.mappingOrder.forEach((key2, value2) {
              if (value2.nameOrder.toString().toLowerCase().contains(filter)) {
                ada = true;
              }
            });
            if (parent.receipt_code.toString().toLowerCase().contains(filter)) {
              ada = true;
            }
          } else if (parent.runtimeType == BGrabParent) {
            if (parent.receipt_code.toString().toLowerCase().contains(filter) ||
                parent.grab_short_order_number
                    .toString()
                    .toLowerCase()
                    .contains(filter)) ada = true;
            parent.items.forEach((key2, value2) {
              if (value2.title.toString().toLowerCase().contains(filter)) {
                ada = true;
              }
            });
          }
        }
        /*
          Done status :
          0 = sukses
          1 = berlangsung
          -1 = void

          Status dropdown
          0 = All
          1 = sukses
          2 = berlangsung
          -1 = void
        */
        if (parent.runtimeType == BOrderParent) {
          if (ddStatus.selected != "0") {
            if (ddStatus.selected == "1" && parent.status == "success")
              ada = true;
            else if (ddStatus.selected == "2" && parent.status == "ongoing")
              ada = true;
            else if (ddStatus.selected == "-1" && parent.status == "void")
              ada = true;
            else
              ada = false;
          }
        } else if (parent.runtimeType == BGrabParent) {
          if (ddStatus.selected != "0") {
            if (ddStatus.selected == "1" &&
                parent.online_order_status == "DELIVERED")
              ada = true;
            else if (ddStatus.selected == "-1" &&
                (parent.online_order_status == "CANCELLED" ||
                    parent.online_order_status == "FAILED"))
              ada = true;
            else
              ada = false;
          }
        }

        if (ddStatus.selected == "0" && filter == "") ada = true;

        if (ada) {
          if (mapDataFiltered[key] == null) mapDataFiltered[key] = List();
          mapDataFiltered[key].add(parent);
        }
      }
    });

    setState(() {});
  }

  Widget listHistory({tanggal, List<dynamic> data}) {
    data.sort((a, b) {
      return b.timestamp.toString().compareTo(a.timestamp.toString());
    });

    String tglStr = tanggal;
    if (tglStr == Helper.toDate(datetime: DateTime.now())) {
      tglStr = "HARI INI";
    }
    return Column(children: [
      Container(
          color: Colors.grey[100],
          padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
          child: Row(children: [
            Wgt.textSecondary(context, "$tglStr"),
            Expanded(child: Container()),
            Wgt.textSecondary(context, "${data.length} TRANSAKSI"),
          ])),
      ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            dynamic item = data[index];
            return cellHistory(item);
          })
    ]);
  }

  Widget cellHistory(dynamic item) {
    if (item.runtimeType == BGrabParent) {
      return cellHistoryGrab(item);
    }
    bool active = orderActive != null && orderActive == item;
    String time =
        Helper.toDate(timestamp: item.timestamp, parseToFormat: "HH:mm");
    String status = "Sukses";
    switch (item.status) {
      case "sukses":
        status = "Sukses";
        break;

      case "void":
        status = "Void";
        break;

      default:
        status = "Sukses";
        break;
    }

    var bgColor = Colors.white;
    var textColor = Colors.grey[800];
    if (item.status == "void") {
      bgColor = Colors.red[50];
      textColor = Colors.red;
    }
    return Material(
        color: active ? Cons.COLOR_PRIMARY : bgColor,
        child: InkWell(
            onTap: () => clickHistory(item),
            child: Column(children: [
              Container(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Wgt.textSecondary(context, "${item.payment[0].title}",
                              color: active ? Colors.white : Colors.grey[500]),
                          Wgt.text(context,
                              "${Helper.formatRupiahDouble(item.grandTotal)}",
                              weight: FontWeight.bold,
                              color: active ? Colors.white : Colors.grey[800])
                        ])),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Wgt.textSecondary(context, "Status",
                              color: active ? Colors.white : Colors.grey[500]),
                          Wgt.text(context, "$status",
                              weight: FontWeight.bold,
                              color: active ? Colors.white : textColor)
                        ])),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Wgt.textSecondary(context, "Jam",
                              color: active ? Colors.white : Colors.grey[500]),
                          Wgt.text(context, "$time",
                              weight: FontWeight.bold,
                              color: active ? Colors.white : Colors.grey[800])
                        ]))
                  ])),
              Wgt.separator(),
            ])));
  }

  Widget cellHistoryGrab(dynamic item) {
    bool active = orderActive != null && orderActive == item;
    String time =
        Helper.toDate(dateString: item.timestamp, parseToFormat: "HH:mm");
    // print("timestamp : ${item.timestamp}")
    String status = "";
    var colorStatus = Colors.black;
    var colorBg = Colors.white;
    if (item.online_order_status == "CANCELLED" ||
        item.online_order_status == "FAILED") {
      status = "Void";
      colorStatus = Colors.red[700];
      colorBg = Colors.red[50];
    } else {
      status = "Sukses";
    }
    return Material(
        color: active ? Cons.COLOR_PRIMARY : colorBg,
        child: InkWell(
            onTap: () => clickHistory(item),
            child: Column(children: [
              Container(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Wgt.textSecondary(context, "${item.payment.title}",
                              color: active ? Colors.white : Colors.grey[500]),
                          Wgt.text(context,
                              "${Helper.formatRupiah(item.final_amount)}",
                              weight: FontWeight.bold,
                              color: active ? Colors.white : Colors.grey[800])
                        ])),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Wgt.textSecondary(context, "Status",
                              color: active ? Colors.white : Colors.grey[500]),
                          Wgt.text(context, "$status",
                              weight: FontWeight.bold,
                              color: active ? Colors.white : colorStatus)
                        ])),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Wgt.textSecondary(context, "Jam",
                              color: active ? Colors.white : Colors.grey[500]),
                          Wgt.text(context, "$time",
                              weight: FontWeight.bold,
                              color: active ? Colors.white : Colors.grey[800])
                        ])),
                    Image.asset("assets/logo_grab.png", height: 25)
                  ])),
              Wgt.separator(),
            ])));
  }

  void clickHistory(dynamic item) {
    orderActive = item;
    setState(() {});
  }

/* -------------------------------------------------------------------------- */
/*                                 PANEL KANAN                                */
/* -------------------------------------------------------------------------- */
  Widget panelKanan() {
    if (orderActive == null) return Container();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: Container(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wgt.spaceTop(5),
                        Wgt.textSecondary(context, "INFORMASI TRANSAKSI"),
                        Wgt.spaceTop(15),
                        panelKananAtas(),
                        pesanan(),
                      ])))),
      notes(),
      summary(),
      btnActions(),
    ]);
  }

  Widget notes() {
    if (orderActive.runtimeType == BGrabParent) return Container();
    if (orderActive.notes == null || orderActive.notes == "")
      return Container();
    return Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200])),
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wgt.text(context, "Catatan :", color: Colors.grey[600]),
          Row(children: [
            Expanded(child: Wgt.text(context, "${orderActive.notes}")),
          ]),
        ]));
  }

  Widget panelKananAtas() {
    if (orderActive.runtimeType == BGrabParent) return panelKananAtasGrab();

    String paymentTitle = orderActive.payment[0].title;
    if (orderActive.payment[0].method == "gopay" &&
        orderActive.payment[0].company_method_id == "") {
      paymentTitle = orderActive.payment[0].title + " Pawoon";
    }

    Widget headerStatus = Container();
    if (orderActive.status == "void") {
      headerStatus = Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          color: Colors.red[50],
          child: Row(children: [
            Expanded(
                child: Wgt.text(context,
                    "Pesanan telah dibatalkan karena ${orderActive.void_reason}",
                    maxlines: 5,
                    align: TextAlign.center,
                    color: Colors.red[800])),
          ]));
    }
    return Column(children: [
      headerStatus,
      Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey[300])),
          child: Row(children: [
            if (orderActive.runtimeType == BOrderParent)
              Container(
                  child: Row(children: [
                Image.asset("assets/ic_settings_cell_black_24dp.png",
                    color: Colors.grey[600], height: 25),
                Wgt.spaceLeft(10),
                Wgt.textSecondary(context, "${orderActive.op.name}",
                    color: Colors.grey[600]),
              ])),
            Expanded(child: Container()),
            Container(
                child: Row(children: [
              Image.asset("assets/ic_receipt_white.png",
                  color: Colors.grey[600], height: 20),
              Wgt.spaceLeft(10),
              Wgt.textSecondary(context, "${orderActive.receipt_code}",
                  color: Colors.grey[600])
            ])),
            Expanded(child: Container()),
            Container(
                child: Row(children: [
              Image.asset("assets/ic_credit_big_white.png",
                  color: Colors.grey[600], height: 20),
              Wgt.spaceLeft(10),
              Wgt.textSecondary(context, "$paymentTitle",
                  color: Colors.grey[600])
            ])),
            Expanded(child: Container()),
            if (orderActive.runtimeType == BOrderParent)
              if (orderActive.pelanggan.name != null &&
                  orderActive.pelanggan.name.isNotEmpty)
                Container(
                    child: Row(children: [
                  Image.asset("assets/ic_account_box_24_px.png",
                      color: Colors.grey[500], height: 20),
                  Wgt.spaceLeft(10),
                  Wgt.textSecondary(context, "${orderActive.pelanggan.name}",
                      color: Colors.grey[600]),
                ])),
          ])),
    ]);
  }

  Widget panelKananAtasGrab() {
    String paymentTitle = orderActive.payment.title;

    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey[300])),
        child: Row(children: [
          Container(
              child: Row(children: [
            Image.asset("assets/ic_settings_cell_black_24dp.png",
                color: Colors.grey[600], height: 25),
            Wgt.spaceLeft(10),
            Wgt.textSecondary(context, "${op.name}", color: Colors.grey[600]),
          ])),
          Expanded(child: Container()),
          Container(
              child: Row(children: [
            Image.asset("assets/ic_receipt_white.png",
                color: Colors.grey[600], height: 20),
            Wgt.spaceLeft(10),
            Wgt.textSecondary(context, "${orderActive.receipt_code}",
                color: Colors.grey[600])
          ])),
          Expanded(child: Container()),
          Container(
              child: Row(children: [
            Image.asset("assets/ic_credit_big_white.png",
                color: Colors.grey[600], height: 20),
            Wgt.spaceLeft(10),
            Wgt.textSecondary(context, "$paymentTitle", color: Colors.grey[600])
          ])),
          Expanded(child: Container()),
          Image.asset("assets/logo_grab.png", height: 25),
          if (orderActive.online_order_status == "CANCELLED" ||
              orderActive.online_order_status == "FAILED")
            Wgt.text(context, "Void", color: Colors.red[700])
        ]));
  }

  Widget pesanan() {
    return Container(
        margin: EdgeInsets.only(top: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wgt.textSecondary(context, "PESANAN"),
          Wgt.spaceTop(15),
          if (orderActive.runtimeType == BOrderParent)
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: orderActive.mappingOrder.length,
                itemBuilder: (context, index) {
                  String key = orderActive.mappingOrder.keys.toList()[index];
                  return cellPesanan(
                      item: orderActive.mappingOrder[key], key: key);
                }),
          if (orderActive.runtimeType == BGrabParent)
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: orderActive.items.length,
                itemBuilder: (context, index) {
                  return cellPesananGrab(item: orderActive.items[index]);
                }),
          cellCustomAmount(),
        ]));
  }

  Widget cellPesanan({key, dynamic item}) {
    return Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200])),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              height: 50,
              width: 50,
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Cons.COLOR_ACCENT),
              child: FittedBox(
                  child:
                      Wgt.text(context, "${item.qty}", color: Colors.white))),
          Wgt.spaceLeft(20),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Wgt.spaceTop(10),
                Row(children: [
                  Expanded(child: Wgt.text(context, "${item.nameOrder}")),
                  Wgt.spaceLeft(20),
                  Wgt.text(
                      context, "${Helper.formatRupiahInt(item.priceTotal)}"),
                ]),
                listModifiers(item),
                if (item.notes != null && item.notes != "")
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(children: [
                        Wgt.text(context, "Catatan : ", color: Colors.black),
                        Wgt.text(context, "${item.notes}",
                            color: Cons.COLOR_PRIMARY),
                      ])),
              ])),
        ]));
  }

  Widget cellPesananGrab({dynamic item}) {
    return Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200])),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              height: 50,
              width: 50,
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Cons.COLOR_ACCENT),
              child: FittedBox(
                  child:
                      Wgt.text(context, "${item.qty}", color: Colors.white))),
          Wgt.spaceLeft(20),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Wgt.spaceTop(10),
                Row(children: [
                  Expanded(child: Wgt.text(context, "${item.title}")),
                  Wgt.spaceLeft(20),
                  Wgt.text(context, "${Helper.formatRupiahInt(item.amount)}"),
                ]),
                listModifiersGrab(item),
              ])),
        ]));
  }

  Widget cellCustomAmount() {
    if (orderActive.runtimeType != BOrderParent) return Container();
    if (orderActive.customAmount == null || orderActive.customAmount.total <= 0)
      return Container();
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200])),
        padding: EdgeInsets.all(15),
        child: Column(children: [
          Row(children: [
            Wgt.text(context, "Custom Amount"),
            Expanded(child: Container()),
            Wgt.text(context,
                "${Helper.formatRupiahInt(orderActive.customAmount.total)}"),
          ]),
          orderActive.customAmount.notes != ""
              ? Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(children: [
                    Wgt.text(context, "Catatan : ", color: Colors.black),
                    Wgt.text(context, "${orderActive.customAmount.notes}",
                        color: Cons.COLOR_PRIMARY)
                  ]))
              : Container(),
        ]));
  }

  Widget listModifiers(BOrder item) {
    if (item.modifiers == null || item.modifiers.isEmpty) return Container();

    return Container(
        margin: EdgeInsets.only(top: 10),
        child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: item.modifiers.length,
            itemBuilder: (context, index) {
              BModifierData mod = item.modifiers[index];
              return Container(
                  child: Row(children: [
                Expanded(
                    child: Wgt.text(context, "+ ${mod.name} x ${mod.qty}")),
                Wgt.text(context,
                    "${Helper.formatRupiahInt(mod.price * mod.qty * item.qty)}"),
              ]));
            }));
  }

  Widget listModifiersGrab(BGrabOrder item) {
    if (item.modifiers == null || item.modifiers.isEmpty) return Container();

    return Container(
        margin: EdgeInsets.only(top: 10),
        child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: item.modifiers.length,
            itemBuilder: (context, index) {
              BGrabModifier mod = item.modifiers[index];
              return Container(
                  child: Row(children: [
                Expanded(
                    child: Wgt.text(context, "+ ${mod.title} x ${mod.qty}")),
                Wgt.text(context, "${mod.price}"),
              ]));
            }));
  }

  Widget summary() {
    if (orderActive.runtimeType == BGrabParent) return summaryGrab();

// Clipboard.setData(
//         ClipboardData(text: "${json.encode(orderActive.objectToServer())}"));
    String salestype = "";
    double subtotal = 0.0;
    // String tax
    if (orderActive.runtimeType == BOrderParent) {
      salestype = orderActive.salestype.name;
      subtotal = orderActive.subtotal;
    } else if (orderActive.runtimeType == BGrabParent) {
      salestype = orderActive.sales_type.mode;
    }
    return Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200])),
        child: Column(children: [
          rowSummary(text: "Tipe penjualan", isi: "$salestype"),
          rowSummary(
              text: "Subtotal", isi: "${Helper.formatRupiahDouble(subtotal)}"),
          if (orderActive.serviceAmount != 0)
            rowSummary(
                text:
                    "Service Charge (${orderActive.service.toStringAsFixed(0)}%)",
                isi: "${Helper.formatRupiahDouble(orderActive.serviceAmount)}"),
          if (orderActive.taxAmount != 0)
            rowSummary(
                text: "PPN (${orderActive.tax.toStringAsFixed(0)}%)",
                isi: "${Helper.formatRupiahDouble(orderActive.taxAmount)}"),
          if (orderActive.pembulatan > 0)
            rowSummary(
                text: "Pembulatan",
                isi: "-${Helper.formatRupiahDouble(orderActive.pembulatan)}"),
          if (orderActive.pembulatan < 0)
            rowSummary(
                text: "Pembulatan",
                isi:
                    "${Helper.formatRupiahDouble(orderActive.pembulatan * -1)}"),
          rowSummary(
              text: "TOTAL",
              isi: "${Helper.formatRupiahDouble(orderActive.grandTotal)}"),
        ]));
  }

  Widget summaryGrab() {
    Map<String, BGrabTax> mapTax = Map();
    for (var item in orderActive.taxes_and_services) {
      mapTax[item.type] = item;
    }
    return Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200])),
        child: Column(children: [
          rowSummary(
              text: "Tipe penjualan", isi: "${orderActive.payment.title}"),
          rowSummary(
              text: "Subtotal",
              isi: "${Helper.formatRupiah(orderActive.subtotal)}"),
          if (mapTax["service"] != null)
            rowSummary(
                text: "PPN (${mapTax["service"].percentage}%)",
                isi: "${Helper.formatRupiah(orderActive.total_service)}"),
          if (mapTax["tax"] != null)
            rowSummary(
                text: "Pajak Grab (${mapTax["tax"].percentage}%)",
                isi: "${Helper.formatRupiah(orderActive.total_tax)}"),
          rowSummary(
              text: "TOTAL",
              isi: "${Helper.formatRupiah(orderActive.final_amount)}"),
        ]));
  }

  Widget rowSummary({text, isi}) {
    return Container(
        padding: EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
        child: Row(children: [
          Expanded(
              child: Wgt.textSecondary(context, "$text", color: Colors.black)),
          Expanded(
              child: Wgt.textSecondary(context, "$isi",
                  align: TextAlign.end, color: Colors.black)),
        ]));
  }

  Widget btnActions() {
    bool enableCancel = true;

    if (orderActive.runtimeType == BGrabParent) {
      enableCancel = false;
    } else {
      if (orderActive.payment[0].company_method_id == "" &&
          orderActive.payment[0].method != "cash" &&
          orderActive.payment[0].method != "card") {
        enableCancel = false;
      }

      if (orderActive.status == "void") {
        enableCancel = false;
      }
    }
    if (!Order.permissions.contains("void_transaction")) {
      enableCancel = false;
    }
    return Container(
        margin: EdgeInsets.all(20),
        child: Row(children: [
          Expanded(
              child: Material(
                  color: Cons.COLOR_PRIMARY,
                  child: InkWell(
                    onTap: () => doCetakStruk(orderActive),
                    child: Container(
                        padding: EdgeInsets.all(12),
                        child: Row(children: [
                          Expanded(child: Container()),
                          Image.asset("assets/ic_receipt_white.png",
                              height: 20),
                          Wgt.spaceLeft(10),
                          Wgt.text(context, "Cetak Struk",
                              size: Wgt.FONT_SIZE_NORMAL_2,
                              weight: FontWeight.bold,
                              color: Colors.white),
                          Expanded(child: Container()),
                        ])),
                  ))),
          Wgt.spaceLeft(20),
          Expanded(
              child: Material(
                  color: !enableCancel ? Colors.grey[400] : Colors.red[700],
                  child: InkWell(
                    onTap: () {
                      if (!Order.permissions.contains("void_transaction")) {
                        Helper.toastError(context,
                            "Anda tidak memiliki akses untuk membatalkan transaksi");
                        return;
                      }
                      if (enableCancel) doCancelTransaction();
                    },
                    child: Container(
                        padding: EdgeInsets.all(12),
                        child: Row(children: [
                          Expanded(child: Container()),
                          Icon(Icons.remove_shopping_cart,
                              size: 25, color: Colors.white),
                          Wgt.spaceLeft(10),
                          Container(
                              child: Wgt.text(context, "Batalkan Transaksi",
                                  size: Wgt.FONT_SIZE_NORMAL_2,
                                  weight: FontWeight.bold,
                                  color: Colors.white)),
                          Expanded(child: Container()),
                        ])),
                  ))),
        ]));
  }

  void doCetakStruk(order) {
    Helper.printReceipt(context, order, showSelection: true, reprint: true);
  }

  Future<void> doCancelTransaction() async {
    var reason =
        await showDialog(context: context, builder: (_) => PopupVoid());
    if (reason != null) {
      doSaveVoid(reason: reason);
    }
  }

  Future<void> doSaveVoid({reason}) async {
    BOrderParent order = BOrderParent.clone(orderActive, multiplier: -1);
    order.void_reason = reason;
    order.status = "void";
    order.void_receipt_code = order.receipt_code;
    order.receipt_code = Helper.generateRandomString();
    order.id = null;
    order.op = op;
    updateTimestamps(order);

    var item = order.objectToServer(reason: reason);
    // Clipboard.setData(
    //     ClipboardData(text: "${json.encode(item)}"));
    // return;

    orderActive.status = "void";
    orderActive.void_reason = reason;

    await DBPawoon().insertOrUpdate(
        tablename: DBPawoon.DB_TRANSACTION, data: order.toMap());
    await DBPawoon().insertOrUpdate(
        tablename: DBPawoon.DB_TRANSACTION, data: orderActive.toMap());
    await SyncData.updateUnsyncCount();
    syncTransactions(item: item, outletid: order.outlet.id);
  }

  void updateTimestamps(BOrderParent order) {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String t = Helper.formatISOTime(Helper.toDate(
        parseToFormat: "yyyy-MM-dd'T'HH:mm:ss", timestamp: timestamp));

    order.timestamp = timestamp;
    for (var p in order.payment) {
      p.timestamp = t;
    }
  }

  Future<void> syncTransactions({item, outletid}) async {
    // print("${json.encode([item])}");
    // Clipboard.setData(
    //     ClipboardData(text: "${json.encode([order.objectToServer(multiplier: -1)])}"));

    // Helper.printReceipt(context, order, showSelection: false);
    if (!await Helper.validateInternet(context, popup: false)) {
      loadData();
      return;
    }
    Helper.showProgress(context);
    await Logic(context)
        .transactions(
            outletid: outletid,
            data: [item],
            success: (json) async {
              for (var item in json["data"]) {
                await DBPawoon().insertOrUpdate(
                    tablename: DBPawoon.DB_TRANSACTION,
                    id: "receipt_code",
                    data: {
                      "receipt_code": item["receipt_code"],
                      "server_id": item["id"],
                    });
                loadData();
              }
            })
        .then((value) {
      Helper.hideProgress(context);
    });
  }

  Future<void> loadData() async {
    List<Map> list =
        await DBPawoon().select(tablename: DBPawoon.DB_TRANSACTION);
    List<dynamic> arrData = List();

    for (Map m in list) {
      // print(m["payment"]);
      // Clipboard.setData(
      //     ClipboardData(text: "${json.encode(m)}"));
      arrData.add(BOrderParent.fromMap(m));
    }

    List<Map> list2 =
        await DBPawoon().select(tablename: DBPawoon.DB_ORDER_ONLINE);

    // Only display status ini
    List<String> arrStatus = ["DELIVERED", "CANCELLED", "FAILED"];
    for (Map m in list2) {
      BGrabParent item = BGrabParent.fromMap(m);
      if (arrStatus.contains(item.online_order_status)) arrData.add(item);
    }

    mapData.clear();
    mapDataFiltered.clear();

    for (dynamic parent in arrData) {
      // Kalau kosong, otomatis di pasang yang paling atas
      String dt;
      if (parent.timestamp.runtimeType == int)
        dt = Helper.toDate(timestamp: parent.timestamp);
      else
        dt = Helper.toDate(dateString: parent.timestamp);

      if (mapData[dt] == null) mapData[dt] = List();
      mapData[dt].add(parent);
    }

    doFilter();
    // Ambil item pertama, supaya otomatis click
    if (orderActive == null &&
        mapDataFiltered != null &&
        mapDataFiltered.keys.isNotEmpty &&
        mapDataFiltered[mapDataFiltered.keys.last] != null) {
      orderActive = mapDataFiltered[mapDataFiltered.keys.last].last;
    }

    await UserManager.getString(UserManager.OPERATOR_OBJ).then((value) {
      if (value != null) op = BOperator.parseObject(json.decode(value));
    });

    setState(() {});
  }
}
