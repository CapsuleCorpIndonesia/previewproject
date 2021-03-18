import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BPelanggan.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/Views/PelangganPopup.dart';

class Pelanggan extends StatefulWidget {
  Pelanggan({Key key}) : super(key: key);

  @override
  _PelangganState createState() => _PelangganState();
}

class _PelangganState extends State<Pelanggan> {
  List<BPelanggan> arrPelanggan = List();
  List<BPelanggan> arrPelangganFiltered = List();
  CustomInput inputSearch;
  TextEditingController contSearch = TextEditingController();
  BOrderParent orderParent;
  Loader2 loader = Loader2();

  @override
  void initState() {
    super.initState();
    inputSearch = CustomInput(
      hint: "Cari Pelanggan",
      controller: contSearch,
      polosan: true,
    );
    refresh();
    contSearch.addListener(() {
      doFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (orderParent == null) {
      orderParent = Helper.getPageData(context)["orderParent"];
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(context,
            name: "Pelanggan",
            arrIconButtons: rightButtons(),
            displayRight: true),
        body: body());
  }

  List<Widget> rightButtons() {
    return <Widget>[
      InkWell(
          onTap: () => doScanQr(),
          child: Row(children: [
            Icon(Icons.qr_code),
            Wgt.spaceLeft(5),
            Wgt.textSecondary(context, "SCAN QR",
                color: Colors.white, weight: FontWeight.w600)
          ])),
      Wgt.spaceLeft(20),
      InkWell(
          onTap: () => doAddUser(),
          child: Row(children: [
            Icon(Icons.person_add),
            Wgt.spaceLeft(5),
            Wgt.textSecondary(context, "Tambah",
                color: Colors.white, weight: FontWeight.w600)
          ])),
      Wgt.spaceLeft(20),
    ];
  }

  void doScanQr() {}

  Future<void> doAddUser() async {
    var result =
        await showDialog(context: context, builder: (_) => PopupPelangganAdd());
    if (result != null) {
      refresh();
    }
  }

  Widget body() {
    return Container(
        child: SingleChildScrollView(
            child: Column(children: [
      panelSearch(),
      ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: arrPelangganFiltered.length,
          itemBuilder: (context, index) {
            return cellPelanggan(arrPelangganFiltered[index], index);
          })
    ])));
  }

  Widget cellPelanggan(BPelanggan item, index) {
    return Material(
        color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
        child: InkWell(
            onTap: () => doPelanggan(item),
            child: Container(
                padding: EdgeInsets.all(20),
                child: Row(children: [
                  Container(
                      height: 50,
                      width: 50,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Cons.COLOR_PRIMARY,
                          borderRadius: BorderRadius.circular(50)),
                      child: FittedBox(
                          child: Wgt.text(context, doGetInitials(item.name),
                              color: Colors.white, weight: FontWeight.w600))),
                  Wgt.spaceLeft(10),
                  // Name
                  Expanded(
                      child: Wgt.text(context, "${item.name}",
                          weight: FontWeight.bold,
                          size: Wgt.FONT_SIZE_NORMAL_2,
                          color: Colors.grey[800])),
                  // Email
                  Expanded(
                      child: Row(children: [
                    Icon(Icons.email, color: Colors.grey[400], size: 30),
                    Wgt.spaceLeft(10),
                    Wgt.text(context, "${item.email != null ? item.email : ""}")
                  ])),
                  // Phone
                  Expanded(
                      child: Row(children: [
                    Icon(Icons.phone, color: Colors.grey[400], size: 30),
                    Wgt.spaceLeft(10),
                    Wgt.text(context, "${item.phone != null ? item.phone : ""}")
                  ])),
                ]))));
  }

  Widget panelSearch() {
    return Container(
        padding: EdgeInsets.all(0),
        child: Row(children: [
          Wgt.spaceLeft(20),
          Icon(Icons.search, color: Colors.grey),
          Wgt.spaceLeft(10),
          Expanded(child: inputSearch),
        ]));
  }

  void doPelanggan(BPelanggan pelanggan) {
    showDialog(
        context: context,
        builder: (_) => PopupPelanggan(
            outlet: orderParent.outlet,
            customer: pelanggan,
            listenerPilih: () {
              doPelangganTerpilih(pelanggan);
            }));
  }

  void doPelangganTerpilih(BPelanggan pelanggan) {
    orderParent.pelanggan = pelanggan;
    Helper.closePage(context);
  }

  void doFilter() {
    arrPelangganFiltered.clear();
    String txt = contSearch.text;
    if (txt.isNotEmpty) {
      for (BPelanggan cs in arrPelanggan) {
        if (cs.name.toString().contains(txt)) arrPelangganFiltered.add(cs);
      }
    } else {
      arrPelangganFiltered.addAll(arrPelanggan);
    }
    setState(() {});
  }

  Future<void> refresh() async {
    arrPelanggan.clear();

    loader.isLoading = true;
    setState(() {});

    await DBPawoon().select(tablename: DBPawoon.DB_CUSTOMERS).then((value) {
      for (var customerRaw in value) {
        BPelanggan cs = BPelanggan.fromMap(customerRaw);
        arrPelanggan.add(cs);
      }
    });

    if (arrPelanggan.isNotEmpty)
      arrPelanggan
          .sort((a, b) => a.name.toString().compareTo(b.name.toString()));

    doFilter();

    loader.isLoading = false;
    setState(() {});
  }

  String doGetInitials(name) {
    var nameParts = name.split(" ").map((elem) {
      return elem[0];
    });

    if (nameParts.length == 0) {
      return "";
    }

    int numberOfParts = min(2, nameParts.length);
    return nameParts.join().substring(0, numberOfParts);
  }
}
