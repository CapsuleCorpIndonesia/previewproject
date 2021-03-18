import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BPrinter.dart';
import 'package:pawoon/Bean/BProduct.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Wgt.dart';

class PrinterDetails extends StatefulWidget {
  @override
  _PrinterDetailsState createState() => _PrinterDetailsState();
}

class _PrinterDetailsState extends State<PrinterDetails> {
  BPrinter printer;
  TextEditingController contName = TextEditingController();
  TextEditingController contLebar = TextEditingController();
  List<List<String>> arrDapurSelection = List();

  @override
  void initState() {
    super.initState();
    doRefresh();
  }

  @override
  Widget build(BuildContext context) {
    if (printer == null) {
      printer = Helper.getPageData(context)["printer"];
      isiData();
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(context,
            name: "Printer Detail",
            displayRight: true,
            rightTextColor: Colors.white,
            rightText: "DISCONNECT",
            onRightClick: () => doDisconnect()),
        body: body());
  }

  Future<void> doDisconnect() async {
    if (printer == null) {
      return;
    }
    await DBPawoon().delete(
        tablename: DBPawoon.DB_PRINTERS,
        id: "address",
        data: {"address": printer.address});
    Helper.closePage(context, payload: true);
  }

  Widget body() {
    return Container(
        child: SingleChildScrollView(
            child: Column(children: [
      wNama(),
      wStruk(),
      wDapur(),
      wLabel(),
      wLebar(),
      Wgt.spaceTop(10),
      Row(children: [
        Expanded(
            child: Wgt.btn(context, "SIMPAN",
                weight: FontWeight.bold, onClick: () => doSimpan())),
      ]),
    ])));
  }

  Future<void> doSimpan() async {
    printer.selectionDapur.clear();
    for (var item in arrDapurSelection) {
      printer.selectionDapur.add(item.join(","));
    }

    if (printer.lebar != "" && printer.lebar != "32" && printer.lebar != "48") {
      printer.lebar = contLebar.text;
    }

    printer.name = contName.text;
    await DBPawoon().insertOrUpdate(
        tablename: DBPawoon.DB_PRINTERS, id: "address", data: printer.toMap());
    Helper.toastSuccess(context, "Settings saved");
    Helper.closePage(context, payload: true);
  }

  void isiData() {
    if (printer == null) return;
    contName.text = printer.name;
    for (var item in printer.selectionDapur) {
      arrDapurSelection.add(item.toString().split(","));
    }
    if (printer.lebar != "" && printer.lebar != "32" && printer.lebar != "48") {
      contLebar.text = printer.lebar;
    }
  }

  Widget wNama() {
    bool isWifi = false;
    if (printer != null && printer.address.toString().contains("."))
      isWifi = true;
    return Container(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(isWifi ? Icons.wifi : Icons.bluetooth,
                size: 30, color: Colors.grey),
            Wgt.spaceLeft(10),
            Expanded(
                child: CustomInput(hint: "Printer name", controller: contName)),
          ]),
          Wgt.spaceTop(10),
          Wgt.text(context, "${printer.address}", color: Colors.grey[700]),
        ]));
  }

  Widget wStruk() {
    return Container(
        child: Column(children: [
      Wgt.separator(color: Colors.grey[400]),
      Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
          color: Colors.grey[200],
          child: Row(children: [
            Wgt.text(context, "CETAK STRUK",
                weight: FontWeight.w600, color: Colors.grey[600]),
            Expanded(child: Container()),
            CupertinoSwitch(
                value: printer.enableCetakStruk,
                activeColor: Cons.COLOR_PRIMARY,
                onChanged: (val) {
                  printer.enableCetakStruk = val;
                  setState(() {});
                }),
          ])),
      Wgt.separator(color: Colors.grey[400]),
      if (printer.enableCetakStruk)
        Container(
            padding: EdgeInsets.all(20),
            child: Row(children: [
              Wgt.text(context, "Jumlah"),
              Expanded(child: Container()),
              angka(
                  value: printer.cetakStruk,
                  listenerAdd: () {
                    printer.cetakStruk++;
                  },
                  listenerMin: () {
                    printer.cetakStruk--;
                  }),
            ]))
    ]));
  }

  Widget wDapur() {
    if (printer.cetakDapur > arrDapurSelection.length &&
        mapCategory.isNotEmpty) {
      for (var i = 0; i < printer.cetakDapur - arrDapurSelection.length; i++) {
        arrDapurSelection.add(List.of(mapCategory.keys.toList()));
      }
    }
    return Container(
        child: Column(children: [
      Wgt.separator(color: Colors.grey[400]),
      Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
          color: Colors.grey[200],
          child: Row(children: [
            Wgt.text(context, "CETAK PESANAN/DAPUR",
                weight: FontWeight.w600, color: Colors.grey[600]),
            Expanded(child: Container()),
            CupertinoSwitch(
                value: printer.enableCetakDapur,
                activeColor: Cons.COLOR_PRIMARY,
                onChanged: (val) {
                  printer.enableCetakDapur = val;
                  setState(() {});
                }),
          ])),
      Wgt.separator(color: Colors.grey[400]),
      if (printer.enableCetakDapur)
        Container(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              Row(children: [
                Wgt.text(context, "Jumlah"),
                Expanded(child: Container()),
                angka(
                    value: printer.cetakDapur,
                    listenerAdd: () {
                      printer.cetakDapur++;
                      arrDapurSelection.add(List.of(mapCategory.keys.toList()));
                    },
                    listenerMin: () {
                      printer.cetakDapur--;
                      arrDapurSelection.removeLast();
                    }),
              ]),
              ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 0, bottom: 20),
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: arrDapurSelection.length,
                  itemBuilder: (context, index) {
                    List<String> arrText = List();
                    for (var item in arrDapurSelection[index]) {
                      arrText.add(mapCategory[item]);
                    }
                    return Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wgt.text(context, "Judul Tiket #${index + 1}",
                                  color: Colors.grey[700]),
                              Wgt.separator(
                                  marginbot: 10,
                                  margintop: 10,
                                  color: Colors.grey),
                              InkWell(
                                onTap: () => doSelectionDapur(index),
                                child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Colors.grey[300])),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Wgt.text(
                                              context, "Kategori yang dicetak"),
                                          Wgt.textSecondary(
                                              context, "${arrText.join(", ")}",
                                              maxlines: 1),
                                        ])),
                              )
                            ]));
                  })
            ]))
    ]));
  }

  Future<void> doSelectionDapur(index) async {
    await showDialog(
        context: context,
        builder: (_)=> PopupLabelSelector(
            selected: arrDapurSelection[index], mapCategory: mapCategory));
    setState(() {});
  }

  /* ------------------------------- KATEGORI DICETAK ------------------------------ */
  Widget wLabel() {
    if (printer.selectionCategory.isEmpty) {
      printer.selectionCategory.addAll(mapCategory.keys.toList());
    }
    List<String> arrtext = List();
    for (var item in printer.selectionCategory) {
      arrtext.add(mapCategory[item]);
    }
    return Container(
        child: Column(children: [
      Wgt.separator(color: Colors.grey[400]),
      Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
          color: Colors.grey[200],
          child: Row(children: [
            Wgt.text(context, "CETAK LABEL (KHUSUS PRINTER EPSON)",
                weight: FontWeight.w600, color: Colors.grey[600]),
            Expanded(child: Container()),
            CupertinoSwitch(
                value: printer.enableCetakLabel,
                activeColor: Cons.COLOR_PRIMARY,
                onChanged: (val) {
                  printer.enableCetakLabel = val;
                  setState(() {});
                }),
          ])),
      Wgt.separator(color: Colors.grey[400]),
      if (printer.enableCetakLabel)
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.all(20),
              child: Row(children: [
                Wgt.text(context, "Jumlah"),
                Expanded(child: Container()),
                angka(
                    value: printer.cetakLabel,
                    listenerAdd: () {
                      printer.cetakLabel++;
                    },
                    listenerMin: () {
                      printer.cetakLabel--;
                    }),
              ])),
          Wgt.separator(),
          Container(
              // padding: EdgeInsets.all(20),
              child: InkWell(
                  onTap: () => doSelectLabel(),
                  child: Row(children: [
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.all(20),
                            // decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.grey),
                            //     borderRadius: BorderRadius.circular(5)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wgt.text(context, "Kategori yang dicetak"),
                                  Wgt.textSecondary(
                                      context, "${arrtext.join(", ")}",
                                      maxlines: 1, color: Colors.grey[600]),
                                ])))
                  ]))),
        ])
    ]));
  }

  Future<void> doSelectLabel() async {
    await showDialog(
        context: context,
        builder: (_)=> PopupLabelSelector(
            selected: printer.selectionCategory, mapCategory: mapCategory));
    setState(() {});
  }

  Map<String, String> mapCategory = Map();
  Future loadProducts() {
    return DBPawoon().select(tablename: DBPawoon.DB_PRODUCTS).then((value) {
      for (Map mapProd in value) {
        BProduct prod = BProduct.fromMap(json.decode(mapProd["data_json"]));

        if (prod.category != null) {
          var category = prod.category.id;
          mapCategory["$category"] = prod.category.name;
        }

        var sortedKeys = mapCategory.keys.toList(growable: false)
          ..sort((k1, k2) => mapCategory[k1].compareTo(mapCategory[k2]));
        LinkedHashMap<String, String> sortedMap =
            new LinkedHashMap.fromIterable(sortedKeys,
                key: (k) => k, value: (k) => mapCategory[k]);
        mapCategory = sortedMap;
      }
    });
  }

  /* ------------------------------- LEBAR STRUK ------------------------------ */
  Widget wLebar() {
    return Container(
        child: Column(children: [
      Wgt.separator(color: Colors.grey[400]),
      Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
          color: Colors.grey[200],
          child: Row(children: [
            Wgt.text(context, "LEBAR STRUK",
                weight: FontWeight.w600, color: Colors.grey[600]),
          ])),
      Wgt.separator(color: Colors.grey[400]),
      Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          child: Row(children: [
            Expanded(
                child: RadioListTile(
                    activeColor: Cons.COLOR_PRIMARY,
                    title: Wgt.text(context, "Default"),
                    groupValue: printer.lebar,
                    onChanged: (value) {
                      printer.lebar = value;
                      setState(() {});
                    },
                    value: "")),
            Expanded(
                child: RadioListTile(
                    activeColor: Cons.COLOR_PRIMARY,
                    title: Wgt.text(context, "32"),
                    groupValue: printer.lebar,
                    onChanged: (value) {
                      printer.lebar = value;
                      setState(() {});
                    },
                    value: "32")),
            Expanded(
                child: RadioListTile(
                    activeColor: Cons.COLOR_PRIMARY,
                    title: Wgt.text(context, "48"),
                    groupValue: printer.lebar,
                    onChanged: (value) {
                      printer.lebar = value;
                      setState(() {});
                    },
                    value: "48")),
            Expanded(
                child: RadioListTile(
                    activeColor: Cons.COLOR_PRIMARY,
                    selected: (printer.lebar != "" &&
                        printer.lebar != "32" &&
                        printer.lebar != "48"),
                    onChanged: (value) {
                      printer.lebar = value;
                      setState(() {});
                    },
                    title: Row(children: [
                      Wgt.text(context, "Custom"),
                      Wgt.spaceLeft(20),
                      Expanded(
                          child: Column(children: [
                        CustomInput(
                            hint: "0",
                            polosan: true,
                            controller: contLebar,
                            enabled: printer.lebar != "" &&
                                printer.lebar != "32" &&
                                printer.lebar != "48"),
                        Wgt.separator(color: Colors.grey),
                      ]))
                    ]),
                    groupValue: printer.lebar)),
          ]))
    ]));
  }

  Widget angka({value = 1, listenerAdd, listenerMin}) {
    return Row(children: [
      Container(
          child: btnOutline(
              text: "-",
              listener: () {
                if (value <= 1) return;
                value--;
                listenerMin();
                setState(() {});
              })),
      Wgt.spaceLeft(20),
      Wgt.textLarge(context, "$value"),
      Wgt.spaceLeft(20),
      Container(
          child: btnOutline(
              text: "+",
              listener: () {
                value++;
                listenerAdd();
                setState(() {});
              }))
    ]);
  }

  Widget btnOutline({text, color, listener}) {
    if (color == null) color = Cons.COLOR_PRIMARY;
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: listener,
            child: Container(
                height: 40,
                width: 50,
                decoration: BoxDecoration(border: Border.all(color: color)),
                child: FittedBox(
                  child: Wgt.text(context, "$text",
                      color: color, align: TextAlign.center),
                ))));
  }

  Future<void> doRefresh() async {
    List<Future> arrFut = List();
    arrFut.add(loadProducts());
    await Future.wait(arrFut);
    setState(() {});
  }
}

class PopupLabelSelector extends StatefulWidget {
  List selected = List();
  Map<String, String> mapCategory = Map();
  PopupLabelSelector({this.selected, this.mapCategory});
  @override
  _PopupLabelSelectorState createState() => _PopupLabelSelectorState();
}

class _PopupLabelSelectorState extends State<PopupLabelSelector> {
  @override
  void initState() {
    super.initState();
    if (widget.selected.isEmpty) {
      widget.selected.addAll(widget.mapCategory.keys.toList());
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
              ListView.builder(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.mapCategory.length,
                  itemBuilder: (context, index) {
                    String key = widget.mapCategory.keys.toList()[index];
                    return ListTile(
                        onTap: () {
                          var val = widget.selected.contains(key);
                          if (!val) {
                            widget.selected.add(key);
                          } else {
                            widget.selected.remove(key);
                          }

                          setState(() {});
                        },
                        title: Wgt.text(context, "${widget.mapCategory[key]}"),
                        trailing: Checkbox(
                            value: widget.selected.contains(key),
                            onChanged: (val) {
                              if (val) {
                                widget.selected.add(key);
                              } else {
                                widget.selected.remove(key);
                              }
                              setState(() {});
                            }));
                  }),
              // Row(children: [
              //   Expanded(child: Wgt.btn(context, "SIMPAN", onClick: ()=>doSimpan())),
              // ])
            ]),
          ),
        ));
  }

  // void doSimpan() {
  //   Helper.closePage(context, payload: widget.selected);
  // }
}
