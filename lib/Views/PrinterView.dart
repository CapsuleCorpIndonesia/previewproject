import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BPrinter.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/Views/RekapPopup.dart';

import '../main.dart';
import 'PrinterWifi.dart';

class PrinterView extends StatefulWidget {
  PrinterView({Key key}) : super(key: key);

  @override
  _PrinterViewState createState() => _PrinterViewState();
}

class _PrinterViewState extends State<PrinterView> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.grey[50], child: list());
  }

  Widget list() {
    if (arrPrinters.isEmpty) return widgetEmpty();
    return Container(
        child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              Wgt.text(context, "${arrPrinters.length} Printer Terhubung",
                  size: Wgt.FONT_SIZE_NORMAL_2, weight: FontWeight.w700),
              Wgt.spaceTop(10),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return cell(index);
                  },
                  itemCount: arrPrinters.length)
            ])));
  }

  Widget cell(index) {
    BPrinter item = arrPrinters[index];
    return Container(
        child: Card(
            elevation: 3,
            child: InkWell(
                onTap: () => doPrinterDetails(item),
                child: Stack(
                  children: [
                    Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Column(children: [
                          Wgt.spaceTop(10),
                          Container(
                              padding: EdgeInsets.only(left: 15),
                              child: Image.asset("assets/ic_printer_icon.png",
                                  height: 50)),
                          Wgt.spaceTop(10),
                          Wgt.text(context, "${item.name}",
                              weight: FontWeight.bold, color: Colors.grey[700]),
                          Wgt.spaceTop(3),
                          Wgt.text(context, "${item.address}",
                              color: Colors.grey),
                          Wgt.separator(margintop: 20),
                          Row(children: [
                            Expanded(
                                child: Container(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Wgt.btn(context, "Tes Print",
                                  transparent: true,
                                  onClick: () => doTestPrint(item),
                                  textcolor: Cons.COLOR_PRIMARY),
                            ))
                          ])
                        ])),
                    Positioned(
                        right: 10,
                        top: 10,
                        child: Icon(Icons.settings,
                            color: Cons.COLOR_PRIMARY, size: 35))
                  ],
                ))));
  }

  Future<void> doPrinterDetails(BPrinter item) async {
    var balikin = await Helper.openPage(context, Main.PRINTER_DETAILS,
        arg: {"printer": BPrinter.clone(item)});
    if (balikin != null) loadData();
  }

  void doTestPrint(BPrinter printer, {showSelection = false}) {
    if (printer.address.toString().contains(".")) {
      // berarti ip address => wifi
      PrinterWifiLogic.testPrint(printer.address, context);
    } else if (printer.address.toString().contains(":")) {
      // Bluetooth
    }
  }

  Widget widgetEmpty() {
    return Container(
        child: Column(children: [
      Expanded(child: Container()),
      Row(children: [
        Expanded(flex: 1, child: Container()),
        Expanded(
            flex: 2,
            child: Column(children: [
              Container(
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Icon(Icons.print, color: Colors.grey[500], size: 70),
                    Icon(Icons.clear, color: Colors.grey[500], size: 35),
                  ])),
              Wgt.spaceTop(20),
              Wgt.text(context, "Perangkat ini belum terhubung dengan printer",
                  maxlines: 3,
                  size: Wgt.FONT_SIZE_NORMAL_2,
                  align: TextAlign.center),
              Wgt.spaceTop(20),
              Wgt.btn(context, "Hubungkan Printer",
                  transparent: true,
                  borderColor: Cons.COLOR_PRIMARY,
                  textcolor: Cons.COLOR_PRIMARY,
                  onClick: () => doConnectPrinter()),
            ])),
        Expanded(flex: 1, child: Container()),
      ]),
      Expanded(child: Container()),
    ]));
  }

  List<BPrinter> arrPrinters = List();
  Future<void> loadData() async {
    arrPrinters.clear();
    List items = await DBPawoon().select(tablename: DBPawoon.DB_PRINTERS);
    for (var item in items) {
      arrPrinters.add(BPrinter.fromMap(item));
    }

    setState(() {});
  }

  Future<void> doConnectPrinter() async {
    var balikan =
        await showDialog(context: context, builder: (_)=> PrinterPopupSelection());
    if (balikan != null) {
      // }else if (widget.doWifi){
      if (balikan["bluetooth"]) {
        // bluetooth
        Helper.openPage(context, Main.PRINTER_LOGIC);
      } else if (balikan["wifi"]) {
        // wifi
        var hasil = await Helper.openPage(context, Main.PRINTER_WIFI);
        if (hasil != null) {
          await loadData();
        }
      }
    }
  }
}

class PrinterPopupSelection extends StatefulWidget {
  PrinterPopupSelection({Key key}) : super(key: key);

  @override
  _PrinterPopupSelectionState createState() => _PrinterPopupSelectionState();
}

class _PrinterPopupSelectionState extends State<PrinterPopupSelection> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              JudulPopup(context: context, title: "Pilih Jenis Printer"),
              Wgt.separator(),
              InkWell(
                  onTap: () => doSelectWifi(),
                  child: Container(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 20),
                      child: Row(children: [
                        Icon(Icons.print, color: Cons.COLOR_PRIMARY, size: 50),
                        Wgt.spaceLeft(20),
                        Wgt.text(context, "Wi-Fi / LAN / MPOP",
                            size: Wgt.FONT_SIZE_NORMAL_2),
                      ]))),
              Wgt.separator(),
              InkWell(
                  onTap: () => doSelectBluetooth(),
                  child: Container(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 20),
                      child: Row(children: [
                        Icon(Icons.bluetooth,
                            color: Cons.COLOR_PRIMARY, size: 50),
                        Wgt.spaceLeft(20),
                        Wgt.text(context, "Bluetooth",
                            size: Wgt.FONT_SIZE_NORMAL_2),
                      ]))),
            ])));
  }

  Future<void> doSelectWifi() async {
    var balikan = await showDialog(
        context: context, builder: (_)=> PrinterPopupReminder(doWifi: true));
    Helper.closePage(context, payload: balikan);
  }

  Future<void> doSelectBluetooth() async {
    var balikan = await showDialog(
        context: context, builder: (_)=> PrinterPopupReminder(doBluetooth: true));
    Helper.closePage(context, payload: balikan);
  }
}

class PrinterPopupReminder extends StatefulWidget {
  bool doWifi = false;
  bool doBluetooth = false;

  PrinterPopupReminder({this.doWifi = false, this.doBluetooth = false});

  @override
  _PrinterPopupReminderState createState() => _PrinterPopupReminderState();
}

class _PrinterPopupReminderState extends State<PrinterPopupReminder> {
  @override
  Widget build(BuildContext context) {
    String text = "";
    if (widget.doBluetooth) {
      text =
          "Pastikan printer bluetooth yang ingin dikoneksikan sudah di pair dengan perangkat ini.";
    }
    if (widget.doWifi) {
      text =
          "Pastikan printer dan perangkat ini sudah terhubung di jaringan Wi-Fi / LAN yang sama";
    }
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width / 2,
            child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.info_outline, color: Colors.green, size: 80),
              Wgt.spaceTop(10),
              Wgt.textLarge(context, "Info",
                  color: Colors.grey[700], weight: FontWeight.w600),
              Wgt.spaceTop(20),
              Wgt.text(context, "$text",
                  maxlines: 100, align: TextAlign.center),
              Wgt.spaceTop(50),
              // Expanded(child: Container()),
              Row(children: [
                Expanded(
                    child: Wgt.btn(context, "Lanjutkan",
                        onClick: () => doLanjut())),
              ]),
              Wgt.spaceTop(20),
              Row(children: [
                Expanded(
                    child: Wgt.btn(context, "Kembali",
                        transparent: true,
                        borderColor: Cons.COLOR_PRIMARY,
                        textcolor: Cons.COLOR_PRIMARY,
                        onClick: () => doKembali())),
              ]),
            ]))));
  }

  void doKembali() {
    Helper.closePage(context);
  }

  void doLanjut() {
    Helper.closePage(context,
        payload: {"wifi": widget.doWifi, "bluetooth": widget.doBluetooth});
    // if (widget.doBluetooth) {
    //   Helper.openPage(context, Main.PRINTER_LOGIC);
    // }else if (widget.doWifi){
    //   Helper.openPage(context, Main.PRINTER_WIFI);
    // }
  }
}
