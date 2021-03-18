import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart';
import 'package:pawoon/Bean/BGrabParent.dart';
import 'package:pawoon/Bean/BModifierData.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOrder.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Bean/BPrinter.dart';
import 'package:pawoon/Bean/BProduct.dart';
import 'package:pawoon/Bean/BRekap.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/Views/RekapPopup.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:wifi/wifi.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart' show rootBundle;

class PrinterWifi extends StatefulWidget {
  @override
  PrinterWifiLogic createState() => PrinterWifiLogic();
}

class PrinterWifiLogic extends State<PrinterWifi> {
  String localIp = '';
  List<String> devices = [];
  Map<String, String> mapIpName = Map();
  bool isDiscovering = false;
  int found = -1;
  bool firstTime = true;
  Loader2 loader = Loader2(tintColor: Colors.white);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (firstTime) {
      discover(context);
      firstTime = false;
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(context,
            name: "Pilih Printer",
            displayRight: true,
            rightIcon: Icon(Icons.refresh, color: Colors.white),
            onRightClick: () => discover(context)),
        body: body());
  }

  Widget body() {
    return Container(
        color: Cons.COLOR_PRIMARY,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: loader.isLoading
            ? Center(child: loader)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    SizedBox(height: 15),
                    found >= 0
                        ? Wgt.textLarge(context, "$found Printer Ditemukan",
                            color: Colors.white)
                        : Container(),
                    Wgt.spaceTop(5),
                    if (found >= 0)
                      Wgt.text(
                          context, "Pilih printer yang ingin dikoneksikan :",
                          color: Colors.white),
                    Wgt.spaceTop(15),
                    Expanded(
                        child: ListView.builder(
                            itemCount: devices.length,
                            itemBuilder: (BuildContext context, int index) {
                              return cell(index);
                            })),
                    Divider(color: Colors.white),
                    Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Row(children: [
                          Wgt.textSecondary(context, "Tidak Ditemukan?",
                              color: Colors.white),
                          Expanded(child: Container()),
                          Wgt.btn(context, "Input IP Manual",
                              onClick: () => doInputManual(),
                              transparent: true,
                              borderColor: Colors.white,
                              height: 40,
                              textcolor: Colors.white,
                              fontSize: 13),
                        ]))
                  ]));
  }

  Future<void> doInputManual() async {
    var balikan =
        await showDialog(context: context, builder: (_) => PopupPrintWifi());
    if (balikan != null) {
      connect(printerIp: balikan);
    }
  }

  Future<void> doSelectDevice(index) async {
    var balikan = await showDialog(
        context: context,
        builder: (_) => PopupPrinterWifiConnect(ip: devices[index]));
    if (balikan != null) {
      if (balikan["connect"]) {
        connect(printerIp: devices[index]);
      } else if (balikan["print"]) {
        testPrint(devices[index], context);
      }
    }
  }

  Widget cell(index) {
    return InkWell(
        // onTap: () => testPrint(devices[index], context),
        onTap: () => doSelectDevice(index),
        child: Card(
            elevation: 2,
            child: Column(children: <Widget>[
              Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Row(children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 5, right: 5),
                        child: Icon(Icons.wifi, color: Colors.lightBlue)),
                    SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                          Wgt.text(context, "${devices[index]}"),
                          Wgt.spaceTop(3),
                          Wgt.textSecondary(context, "${devices[index]}",
                              color: Colors.grey[800]),
                        ])),
                  ])),
            ])));
  }

  void discover(BuildContext ctx) async {
    loader.isLoading = true;
    setState(() {
      isDiscovering = true;
      devices.clear();
      found = -1;
    });

    String ip;
    try {
      ip = await Wifi.ip;
    } catch (e) {
      final snackBar = SnackBar(
          content: Text('WiFi is not connected', textAlign: TextAlign.center));
      Scaffold.of(ctx).showSnackBar(snackBar);
      return;
    }
    setState(() {
      localIp = ip;
      // loader.isLoading = false;
    });

    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    int port = 9100;
    print('subnet:\t$subnet, port:\t$port');

    final stream = NetworkAnalyzer.discover2(subnet, port);

    stream.listen((NetworkAddress addr) async {
      print('Found device: ${addr.ip}');
      if (addr.exists) {
        print('Found device: ${addr.ip}');
        devices.add(addr.ip);
        await getName(ip: addr.ip);
        found = devices.length;

        loader.isLoading = false;
        setState(() {});
      }
    })
      ..onDone(() {
        setState(() {
          isDiscovering = false;
          loader.isLoading = false;
          found = devices.length;
        });
      })
      ..onError((dynamic e) {
        final snackBar = SnackBar(
            content: Text('Unexpected exception', textAlign: TextAlign.center));
        Scaffold.of(ctx).showSnackBar(snackBar);
      });
  }

  Future<void> getName({ip}) async {
    try {
      InternetAddress add = await InternetAddress(ip).reverse();
      if (add.host != null && add.host != ip) {
        print('found name ${add.host}');
      }
    } catch (e) {
      print("err:$e");
    }
  }

  Future<void> testReceipt(NetworkPrinter printer) async {
    // printer.text(
    //     'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    // printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
    //     styles: PosStyles(codeTable: 'CP1252'));
    // printer.text('Special 2: blåbærgrød',
    //     styles: PosStyles(codeTable: 'CP1252'));

    // printer.text('Bold text', styles: PosStyles(bold: true));
    // printer.text('Reverse text', styles: PosStyles(reverse: true));
    // printer.text('Underlined text',
    //     styles: PosStyles(underline: true), linesAfter: 1);
    // printer.text('Align left', styles: PosStyles(align: PosAlign.left));
    // printer.text('Align center', styles: PosStyles(align: PosAlign.center));
    // printer.text('Align right',
    //     styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    // printer.row([
    //   PosColumn(
    //     text: 'col3',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.center, underline: true),
    //   ),
    //   PosColumn(
    //     text: 'col6',
    //     width: 6,
    //     styles: PosStyles(align: PosAlign.center, underline: true),
    //   ),
    //   PosColumn(
    //     text: 'col3',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.center, underline: true),
    //   ),
    // ]);

    // printer.text('Text size 200%',
    //     styles: PosStyles(
    //       height: PosTextSize.size2,
    //       width: PosTextSize.size2,
    //     ));

    printer.feed(2);
    printer.cut();
  }

  static Future<void> printDemoReceipt(NetworkPrinter printer) async {
    final ByteData data = await rootBundle.load('assets/logo_pawoon_black.png');
    final Uint8List bytes = data.buffer.asUint8List();
    var image = decodeImage(bytes);
    printer.imageRaster(image);
    printer.feed(1);
    printer.text("Tes Printer Berhasil!");
    printer.feed(1);
    printer.cut();
  }

  Future<void> connect({printerIp}) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    Helper.showProgress(context);
    final PosPrintResult res = await printer.connect(printerIp, port: 9100);
    if (res == PosPrintResult.success) {
      BPrinter item = BPrinter();
      item.address = "$printerIp";
      item.name = "$printerIp";
      await DBPawoon().insertOrUpdate(
          tablename: DBPawoon.DB_PRINTERS, id: "address", data: item.toMap());
      printer.disconnect();

      // Timer(Duration(seconds: 100), () {
      Helper.hideProgress(context);
      // });
      Helper.toastSuccess(context, "Koneksi sukses");
      Helper.closePage(context, payload: true);
    } else {
      Helper.hideProgress(context);

      Helper.toastError(
          context, "Tidak dapat menghubungkan perangkat ini ke printer");
    }
  }

  static void testPrint(String printerIp, BuildContext ctx) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect(printerIp, port: 9100);

    if (res == PosPrintResult.success) {
      // DEMO RECEIPT
      await printDemoReceipt(printer);
      // TEST PRINT
      // await testReceipt(printer);
      printer.disconnect();
    }
  }

  static Future<void> printOrder(context, {order, BPrinter printer}) async {
    NetworkPrinter p = await connectToPrinter(ip: printer.address);
    if (p == null) {
      // Helper.toastError(context, "Failed to print");
      return;
    }
    BOrderParent o;
    BGrabParent g;
    if (order.runtimeType == BOrderParent) {
      o = order;
      for (var i = 0; i < printer.cetakStruk; i++) {
        p.text('${o.outlet.name}', styles: PosStyles(align: PosAlign.center));
        p.text('${o.outlet.address}',
            styles: PosStyles(align: PosAlign.center));
        p.text('${o.outlet.city_name}',
            styles: PosStyles(align: PosAlign.center));
        if (o.outlet.phones != null && o.outlet.phones != "") {
          p.text('${o.outlet.phones[0]}',
              styles: PosStyles(align: PosAlign.center));
        }
        p.feed(1);
        p.text('Kode struk : ${o.receipt_code}',
            styles: PosStyles(align: PosAlign.left));
        p.text(
            'Tanggal : ${Helper.toDate(timestamp: o.timestamp, parseToFormat: "dd-MM-yyyy HH:mm:ss")}',
            styles: PosStyles(align: PosAlign.left));
        p.text('Kasir : ${o.op.name}', styles: PosStyles(align: PosAlign.left));
        p.feed(1);
        p.text('${o.salestype.name}', styles: PosStyles(align: PosAlign.left));

        p.hr();
        o.mappingOrder.forEach((key, value) {
          p.row([
            PosColumn(text: '${value.nameOrder} x ${value.qty}', width: 8),
            PosColumn(
                width: 4,
                text:
                    '${Helper.formatRupiahDouble(value.priceTotal, currency: "")}',
                styles: PosStyles(align: PosAlign.right)),
          ]);
          // p.text('${value.nameOrder} x ${value.qty}',
          //     styles: PosStyles(align: PosAlign.left));
          p.text(
              '+ Harga (${Helper.formatRupiahInt(value.product.price, currency: "")})',
              styles: PosStyles(align: PosAlign.left));
          if (value.modifiers != null)
            for (var mod in value.modifiers) {
              p.text(
                  '${mod.name} x ${mod.qty} (${Helper.formatRupiahInt(mod.price, currency: "")})',
                  styles: PosStyles(align: PosAlign.left));
            }
        });
        p.hr();
        p.row([
          PosColumn(text: 'Subtotal', width: 8),
          PosColumn(
              width: 4,
              text: '${Helper.formatRupiahDouble(o.subtotal, currency: "")}',
              styles: PosStyles(align: PosAlign.right)),
        ]);
        p.row([
          PosColumn(
              text: 'Service Charge (${o.service.toStringAsFixed(1)}%)',
              width: 8),
          PosColumn(
              width: 4,
              text:
                  '${Helper.formatRupiahDouble(o.serviceAmount, currency: "")}',
              styles: PosStyles(align: PosAlign.right)),
        ]);
        p.row([
          PosColumn(text: 'PPN (${o.tax.toStringAsFixed(1)}%)', width: 8),
          PosColumn(
              width: 4,
              text: '${Helper.formatRupiahDouble(o.taxAmount, currency: "")}',
              styles: PosStyles(align: PosAlign.right)),
        ]);
        p.row([
          PosColumn(text: 'Pembulatan', width: 8),
          PosColumn(
              width: 4,
              text:
                  '(${Helper.formatRupiahDouble(o.pembulatan, currency: "")})',
              styles: PosStyles(align: PosAlign.right)),
        ]);
        p.hr();
        p.row([
          PosColumn(text: 'Total', width: 8),
          PosColumn(
              width: 4,
              text: '${Helper.formatRupiahDouble(o.grandTotal, currency: "")}',
              styles: PosStyles(align: PosAlign.right)),
        ]);
        p.feed(1);
        // Di ubah jadi map dulu supaya format nya jadi
        var objServer = o.objectToServer();
        for (var payment in objServer["payments"]) {
          p.row([
            PosColumn(text: '${payment["title"]}', width: 8),
            PosColumn(
                width: 4,
                text:
                    '${Helper.formatRupiahDouble(payment["amount"], currency: "")}',
                styles: PosStyles(align: PosAlign.right)),
          ]);
        }
        p.row([
          PosColumn(text: 'Kembali', width: 8),
          PosColumn(
              width: 4,
              text: '${Helper.formatRupiahInt(o.total_change, currency: "")}',
              styles: PosStyles(align: PosAlign.right)),
        ]);
        p.text('** LUNAS **', styles: PosStyles(align: PosAlign.center));
        p.feed(1);
        if (i > 0) {
          p.text('** SALINAN STRUK **',
              styles: PosStyles(align: PosAlign.center));
          p.feed(1);
        }
        p.text('Terima Kasih', styles: PosStyles(bold: true));
        p.feed(2);
        p.cut();
      }
    } else if (order.runtimeType == BGrabParent) {
      g = order;
      // print("${g.outlet}");
      // return;
      for (var i = 0; i < printer.cetakStruk; i++) {
        p.text('${g.outlet.name}', styles: PosStyles(align: PosAlign.center));
        p.text('${g.outlet.address}',
            styles: PosStyles(align: PosAlign.center));
        p.text('${g.outlet.city_name}',
            styles: PosStyles(align: PosAlign.center));
        if (g.outlet.phones != null && g.outlet.phones != "") {
          p.text('${g.outlet.phones[0]}',
              styles: PosStyles(align: PosAlign.center));
        }
        p.feed(1);
        p.text('Kode struk : ${g.receipt_code}',
            styles: PosStyles(align: PosAlign.left));
        p.text(
            'Tanggal : ${Helper.toDate(dateString: g.timestamp, parseToFormat: "dd-MM-yyyy HH:mm:ss")}',
            styles: PosStyles(align: PosAlign.left));
        p.text('Kasir : ${g.op.name}', styles: PosStyles(align: PosAlign.left));
        // p.feed(1);
        // p.text('${g.salestype.name}', styles: PosStyles(align: PosAlign.left));
        p.row([
          PosColumn(text: '${g.sales_type.name} ', width: 6),
          PosColumn(
              width: 6,
              text: '${g.grab_short_order_number}',
              styles: PosStyles(align: PosAlign.right)),
        ]);
        p.hr();
        for (var value in g.items) {
          p.row([
            PosColumn(text: '${value.title} x ${value.qty}', width: 8),
            PosColumn(
                width: 4,
                text: '${Helper.formatRupiahDouble(value.price, currency: "")}',
                styles: PosStyles(align: PosAlign.right)),
          ]);
          //   // p.text('${value.nameOrder} x ${value.qty}',
          //   //     styles: PosStyles(align: PosAlign.left));
          //   p.text(
          //       '+ Harga (${Helper.formatRupiahInt(value.product.price, currency: "")})',
          //       styles: PosStyles(align: PosAlign.left));
          for (var mod in value.modifiers) {
            p.text(
                '${mod.title} x ${mod.qty} (${Helper.formatRupiahInt(mod.price, currency: "")})',
                styles: PosStyles(align: PosAlign.left));
          }
        }

        p.hr();
        p.row([
          PosColumn(text: 'Subtotal', width: 8),
          PosColumn(
              width: 4,
              text: '${Helper.formatRupiah(g.subtotal, currency: "")}',
              styles: PosStyles(align: PosAlign.right)),
        ]);
        for (var item in g.taxes_and_services) {
          if (item.type == "tax") {
            p.row([
              PosColumn(text: 'Pajak Grab (${item.percentage}%)', width: 8),
              PosColumn(
                  width: 4,
                  text: '${Helper.formatRupiahInt(item.amount, currency: "")}',
                  styles: PosStyles(align: PosAlign.right)),
            ]);
          }
        }
        p.hr();
        p.row([
          PosColumn(text: 'Total', width: 8),
          PosColumn(
              width: 4,
              text: '${Helper.formatRupiah(g.final_amount, currency: "")}',
              styles: PosStyles(align: PosAlign.right)),
        ]);
        p.feed(1);

        p.row([
          PosColumn(text: 'GrabFood', width: 8),
          PosColumn(
              width: 4,
              text: '${Helper.formatRupiahInt(g.payment.amount, currency: "")}',
              styles: PosStyles(align: PosAlign.right)),
        ]);
        p.row([
          PosColumn(text: 'Kembali', width: 8),
          PosColumn(
              width: 4,
              text: '${Helper.formatRupiah(g.total_change, currency: "")}',
              styles: PosStyles(align: PosAlign.right)),
        ]);
        p.feed(1);
        p.text('** LUNAS **', styles: PosStyles(align: PosAlign.center));
        p.feed(1);
        if (i > 0) {
          p.text('** SALINAN STRUK **',
              styles: PosStyles(align: PosAlign.center));
          p.feed(1);
        }
        p.text('Terima Kasih', styles: PosStyles(bold: true));
        p.feed(2);
        p.cut();
      }
    }
    p.disconnect();
  }

  static Future<void> printDapur(context, {order, BPrinter printer}) async {
    NetworkPrinter p = await connectToPrinter(ip: printer.address);
    if (p == null) {
      // Helper.toastError(context, "Failed to print");
      return;
    }
    BOrderParent o;
    BGrabParent g;
    if (order.runtimeType == BOrderParent) {
      o = order;
      for (var i = 0; i < printer.cetakDapur; i++) {
        List<String> enabledCategoryId = List();
        if (printer.selectionDapur != null &&
            printer.selectionDapur.length - 1 >= i &&
            printer.selectionDapur[i] != null &&
            printer.selectionDapur[i] != "") {
          enabledCategoryId = printer.selectionDapur[i].toString().split(",");
        }

        p.text('DAPUR', styles: PosStyles(align: PosAlign.center));
        p.feed(1);
        p.text(
            'Tanggal : ${Helper.toDate(timestamp: o.timestamp, parseToFormat: "dd-MM-yyyy HH:mm:ss")}',
            styles: PosStyles(align: PosAlign.left));
        p.text('No. order : ${o.id}', styles: PosStyles(align: PosAlign.left));
        p.text('Kasir : ${o.op.name}', styles: PosStyles(align: PosAlign.left));
        p.feed(1);
        p.text('${o.salestype.name}', styles: PosStyles(align: PosAlign.left));

        p.hr();
        o.mappingOrder.forEach((key, value) {
          if (enabledCategoryId.isNotEmpty &&
              !enabledCategoryId.contains(value.product.category.id)) {
            // Jangan di print
          } else {
            p.row([
              PosColumn(text: '${value.nameOrder} x ${value.qty}', width: 12),
            ]);
            for (var mod in value.modifiers) {
              p.text('+ ${mod.name} x ${mod.qty}',
                  styles: PosStyles(align: PosAlign.left));
            }
          }
        });
        p.hr();
        p.feed(1);
        if (i > 0) {
          p.text('** CETAK ULANG DAPUR **',
              styles: PosStyles(align: PosAlign.center));
          p.feed(1);
        }
        p.feed(2);
        p.cut();
      }
    } else if (order.runtimeType == BGrabParent) {
      g = order;

      for (var i = 0; i < printer.cetakDapur; i++) {
        List<String> enabledCategoryId = List();
        if (printer.selectionDapur[i] != null &&
            printer.selectionDapur[i] != "") {
          enabledCategoryId = printer.selectionDapur[i].toString().split(",");
        }

        p.text('DAPUR', styles: PosStyles(align: PosAlign.center));
        p.feed(1);
        p.text(
            'Tanggal : ${Helper.toDate(timestamp: g.timestamp, parseToFormat: "dd-MM-yyyy HH:mm:ss")}',
            styles: PosStyles(align: PosAlign.left));
        p.text('No order : ${g.id}', styles: PosStyles(align: PosAlign.left));
        p.text('Kasir : ${g.op.name}', styles: PosStyles(align: PosAlign.left));
        p.feed(1);
        p.text('${g.sales_type.name}', styles: PosStyles(align: PosAlign.left));

        p.hr();
        for (var value in g.items) {
          if (enabledCategoryId.isNotEmpty &&
              !enabledCategoryId.contains(value.product_category_id)) {
            // Jangan di print
          } else {
            p.row([
              PosColumn(text: '${value.title} x ${value.qty}', width: 12),
            ]);
            for (var mod in value.modifiers) {
              p.text('+ ${mod.title} x ${mod.qty}',
                  styles: PosStyles(align: PosAlign.left));
            }
          }
        }

        p.hr();
        p.feed(1);
        if (i > 0) {
          p.text('** CETAK ULANG DAPUR **',
              styles: PosStyles(align: PosAlign.center));
          p.feed(1);
        }
        p.feed(2);
        p.cut();
      }
      p.disconnect();
    }
  }

  static Future<void> printLabel(context, {order, BPrinter printer}) async {
    NetworkPrinter p = await connectToPrinter(ip: printer.address);
    if (p == null) {
      // Helper.toastError(context, "Failed to print");
      return;
    }
    BOrderParent o;
    BGrabParent g;
    if (order.runtimeType == BOrderParent) {
      o = order;
      for (var i = 0; i < printer.cetakLabel; i++) {
        List<String> enabledCategoryId = List();
        if (printer.selectionDapur[i] != null &&
            printer.selectionDapur[i] != "") {
          enabledCategoryId = printer.selectionDapur[i].toString().split(",");
        }

        int j = 1;
        o.mappingOrder.forEach((key, value) {
          if (enabledCategoryId.isNotEmpty &&
              !enabledCategoryId.contains(value.product.category.id)) {
            // Jangan di print
          } else {
            p.text('No. order : ${o.id}',
                styles: PosStyles(align: PosAlign.left));
            p.text('No. item : $j / ${o.mappingOrder.length}',
                styles: PosStyles(align: PosAlign.left));

            p.hr();
            p.row([
              PosColumn(text: '${value.nameOrder} x ${value.qty}', width: 12),
            ]);
            for (var mod in value.modifiers) {
              p.text('+ ${mod.name} x ${mod.qty}',
                  styles: PosStyles(align: PosAlign.left));
            }
          }
          j++;
        });
        p.feed(2);
        p.cut();
      }
    } else if (order.runtimeType == BGrabParent) {
      g = order;

      for (var i = 0; i < printer.cetakDapur; i++) {
        List<String> enabledCategoryId = List();
        if (printer.selectionDapur[i] != null &&
            printer.selectionDapur[i] != "") {
          enabledCategoryId = printer.selectionDapur[i].toString().split(",");
        }

        int j = 1;
        for (var value in g.items) {
          if (enabledCategoryId.isNotEmpty &&
              !enabledCategoryId.contains(value.product_category_id)) {
            // Jangan di print
          } else {
            p.text('No order : ${g.id}',
                styles: PosStyles(align: PosAlign.left));
            p.text('No item : $j / ${g.items.length}',
                styles: PosStyles(align: PosAlign.left));
            p.hr();
            p.row([
              PosColumn(text: '${value.title} x ${value.qty}', width: 12),
            ]);
            for (var mod in value.modifiers) {
              p.text('+ ${mod.title} x ${mod.qty}',
                  styles: PosStyles(align: PosAlign.left));
            }
          }
        }

        p.feed(2);
        p.cut();
      }
      p.disconnect();
    }
  }

  static Future<void> printRekap(context,
      {BRekap rekap,
      BOutlet outlet,
      BPrinter printer,
      BOperator op,
      List<BOrderParent> arrOrders}) async {
    NetworkPrinter p = await connectToPrinter(ip: printer.address);
    if (p == null) {
      // Helper.toastError(context, "Failed to print");
      return;
    }

    arrOrders.sort((a, b) {
      return a.timestamp.toString().compareTo(b.timestamp.toString());
    });
    String first = "";
    String last = "";
    if (arrOrders.length > 0) {
      first = Helper.toDate(
          timestamp: arrOrders[0].timestamp,
          parseToFormat: "dd-MM-yyyy HH:mm:ss");
      last = Helper.toDate(
          timestamp: arrOrders[arrOrders.length - 1].timestamp,
          parseToFormat: "dd-MM-yyyy HH:mm:ss");
    }

    // Outlet
    p.text("${outlet.name}", styles: PosStyles(align: PosAlign.center));
    p.text("${outlet.address}", styles: PosStyles(align: PosAlign.center));
    p.text("${outlet.city_name}", styles: PosStyles(align: PosAlign.center));
    if (outlet.phones != null && outlet.phones != "") {
      p.text('${outlet.phones[0]}', styles: PosStyles(align: PosAlign.center));
    }

    // Judul
    p.hr();
    p.text('LAPORAN PENJUALAN',
        styles: PosStyles(bold: true, align: PosAlign.center));
    p.hr();

    // Kasir
    p.text("Kasir : ${op.name}");
    p.text(
        "Waktu: ${Helper.toDate(datetime: DateTime.now(), parseToFormat: "dd-MM-yyyy HH:mm:ss")}");
    p.text("Trx pertama: $first");
    p.text("Trx terakhir: $last");
    p.text("Order tersimpan: ${rekap.total_pending_transaction}");
    p.text("Order berlangsung: ${rekap.total_ongoing_installment_order}");

    // Sales
    p.feed(1);
    p.text('Penjualan', styles: PosStyles(bold: true, align: PosAlign.center));
    p.hr();
    Map<String, BOrder> mapSales2 = Map();
    Map<String, BModifierData> mapMod2 = Map();
    int tot_subtotal = 0;
    int tot_diskon = 0;
    int tot_ppn = 0;
    int tot_service = 0;
    int tot_pembulatan = 0;
    int tot_total = 0;
    double ppn_pct = 0;
    double service_pct = 0;

    for (var o in arrOrders) {
      tot_subtotal += o.subtotal.toInt();
      tot_diskon += o.discount_amount.toInt();
      tot_ppn += o.taxAmount.toInt();
      tot_service += o.serviceAmount.toInt();
      tot_pembulatan += o.pembulatan.toInt();
      tot_total += o.grandTotal.toInt();
      o.mappingTaxServices.forEach((key, value) {
        if (key == "tax") {
          ppn_pct = value.percentage;
        } else if (key == "service") {
          service_pct = value.percentage;
        }
      });

      o.mappingOrder.forEach((key, value) {
        if (mapSales2[key] == null)
          mapSales2[key] = value;
        else {
          mapSales2[key].qty += value.qty;
          mapSales2[key].priceTotal += value.priceTotal;
        }

        for (var mod in value.modifiers) {
          String k = mod.id;
          if (mapMod2[k] == null) {
            mapMod2[k] = mod;
          } else {
            mapMod2[k].qty += mod.qty;
          }
        }
      });
    }

    mapSales2.forEach((key, value) {
      p.row([
        PosColumn(text: '${value.nameOrder} x ${value.qty}', width: 6),
        PosColumn(
            text: '${Helper.formatRupiahInt(value.priceTotal, currency: "")}',
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    });

    mapMod2.forEach((key, value) {
      p.row([
        PosColumn(text: '${value.name} x ${value.qty}', width: 6),
        PosColumn(
            text:
                '${Helper.formatRupiahInt(value.qty * value.price, currency: "")}',
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    });
    p.hr();
    p.row([
      PosColumn(text: 'Subtotal', width: 6),
      PosColumn(
          text: '${Helper.formatRupiahInt(tot_subtotal, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    p.row([
      PosColumn(text: 'Diskon order', width: 6),
      PosColumn(
          text: '${Helper.formatRupiahInt(tot_diskon, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    p.row([
      PosColumn(text: 'PPN (${ppn_pct.round()}%)', width: 6),
      PosColumn(
          text: '${Helper.formatRupiahInt(tot_ppn, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    p.row([
      PosColumn(text: 'Service (${service_pct.round()}%)', width: 6),
      PosColumn(
          text: '${Helper.formatRupiahInt(tot_service, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    p.row([
      PosColumn(text: 'Pembulatan', width: 6),
      PosColumn(
          text: '${Helper.formatRupiahInt(tot_pembulatan, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    p.hr();
    p.row([
      PosColumn(text: 'TOTAL', width: 6),
      PosColumn(
          text: '${Helper.formatRupiahInt(tot_total, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);

    // Penerimaan aktual
    p.feed(1);
    p.text('Penerimaan Aktual',
        styles: PosStyles(bold: true, align: PosAlign.center));
    p.hr();

    p.row([
      PosColumn(text: 'Tunai', width: 6),
      PosColumn(
          text: '${Helper.formatRupiahInt(rekap.total_cash, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    p.row([
      PosColumn(text: 'Kartu', width: 6),
      PosColumn(
          text: '${Helper.formatRupiahInt(rekap.total_non_cash, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    for (var item in rekap.custom_payment_json) {
      p.row([
        PosColumn(text: '${item.name}', width: 6),
        PosColumn(
            text: '${Helper.formatRupiah(item.amount, currency: "")}',
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    }
    for (var item in rekap.integrated_payments) {
      // print(item["title"]);
      // print(Helper.formatRupiahDouble(item["amount"]));
      p.row([
        PosColumn(text: '${item["title"]}', width: 6),
        PosColumn(
            text: '${Helper.formatRupiahDouble(item["amount"], currency: "")}',
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    }
    p.hr();
    p.row([
      PosColumn(text: 'TOTAL', width: 6),
      PosColumn(
          text: '${Helper.formatRupiahInt(rekap.actual_income, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);

    // Penerimaan sistem
    p.feed(1);
    p.text('Penerimaan Sistem',
        styles: PosStyles(bold: true, align: PosAlign.center));
    p.hr();
    p.row([
      PosColumn(text: 'Penjualan', width: 6),
      PosColumn(
          text: '${Helper.formatRupiahInt(rekap.sales_amount, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    p.row([
      PosColumn(text: 'Retur', width: 6),
      PosColumn(
          text:
              '${Helper.formatRupiahInt(rekap.void_transactions, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    p.row([
      PosColumn(text: 'Kas Masuk', width: 6),
      PosColumn(
          text: '${Helper.formatRupiahInt(rekap.cash_in, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    p.row([
      PosColumn(text: 'Kas Keluar', width: 6),
      PosColumn(
          text: '${Helper.formatRupiahInt(rekap.cash_out, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);
    p.hr();
    p.row([
      PosColumn(text: 'TOTAL', width: 6),
      PosColumn(
          text: '${Helper.formatRupiahInt(rekap.system_amount, currency: "")}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);

    // Selisih
    p.feed(1);
    p.text('Selisih Penerimaan',
        styles: PosStyles(bold: true, align: PosAlign.center));
    p.hr();
    int selisih = rekap.actual_income - rekap.system_amount;
    p.row([
      PosColumn(text: 'Aktual - sistem', width: 6),
      if (selisih < 0)
        PosColumn(
            text:
                '(${Helper.formatRupiahInt(rekap.actual_income - rekap.system_amount, currency: "")})',
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      if (selisih >= 0)
        PosColumn(
            text:
                '${Helper.formatRupiahInt(rekap.actual_income - rekap.system_amount, currency: "")}',
            width: 6,
            styles: PosStyles(align: PosAlign.right))
    ]);

    // End
    p.feed(2);
    p.cut();
    p.disconnect();
  }

  static Future<NetworkPrinter> connectToPrinter({ip}) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect(ip, port: 9100);

    if (res == PosPrintResult.success) {
      return printer;
    } else {
      return null;
    }
  }
}

class PopupPrintWifi extends StatefulWidget {
  @override
  _PopupPrintWifiState createState() => _PopupPrintWifiState();
}

class _PopupPrintWifiState extends State<PopupPrintWifi> {
  TextEditingController cont = TextEditingController();
  CustomInput input;
  @override
  void initState() {
    super.initState();
    input = CustomInput(
        hint: "Contoh:192.168.0.1",
        bordered: true,
        displayUnderline: false,
        controller: cont,
        borderColor: Cons.COLOR_PRIMARY);
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
              JudulPopup(context: context, title: "Input IP Manual"),
              Wgt.separator(),
              Container(
                  padding: EdgeInsets.all(20),
                  child: Column(children: [
                    input,
                    Wgt.spaceTop(20),
                    Row(children: [
                      Expanded(
                          child: Wgt.btn(context, "BATAL",
                              transparent: true,
                              borderColor: Colors.red,
                              textcolor: Colors.red,
                              onClick: () => doCancel())),
                      Wgt.spaceLeft(20),
                      Expanded(
                          child: Wgt.btn(context, "KONEKSIKAN",
                              onClick: () => doSubmit())),
                    ]),
                  ])),
            ]))));
  }

  void doCancel() {
    Helper.closePage(context);
  }

  void doSubmit() {
    if (cont.text == "") {
      Helper.toastError(context, "Mohon isi IP Address");
      return;
    }
    Helper.closePage(context, payload: cont.text);
  }
}

class PopupPrinterWifiConnect extends StatefulWidget {
  String ip;
  PopupPrinterWifiConnect({ip});
  @override
  _PopupPrinterWifiConnectState createState() =>
      _PopupPrinterWifiConnectState();
}

class _PopupPrinterWifiConnectState extends State<PopupPrinterWifiConnect> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Container(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              InkWell(
                  onTap: () => doConnect(),
                  child: Row(children: [
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.all(20),
                            child: Wgt.text(context, "Hubungkan",
                                align: TextAlign.center,
                                weight: FontWeight.w700,
                                color: Cons.COLOR_PRIMARY)))
                  ])),
              Wgt.separator(),
              InkWell(
                  onTap: () => doTestPrint(),
                  child: Row(children: [
                    Expanded(
                      child: Container(
                          padding: EdgeInsets.all(20),
                          child: Wgt.text(context, "Test Print",
                              weight: FontWeight.w700,
                              align: TextAlign.center,
                              color: Cons.COLOR_PRIMARY)),
                    )
                  ]))
            ]))));
  }

  void doTestPrint() {
    Helper.closePage(context, payload: {"print": true, "connect": false});
  }

  void doConnect() {
    Helper.closePage(context, payload: {"print": false, "connect": true});
  }
}
