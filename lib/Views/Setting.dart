import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:pawoon/Bean/BBillings.dart';
import 'package:pawoon/Bean/BDevice.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Bean/BProduct.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/HTTPImb.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/SyncData.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/Views/SettingPosisiProduk.dart';

import 'Base.dart';
import 'Order.dart';
import 'PrinterView.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Map<String, List<BProduct>> mapProducts = Map();
  Map<String, String> mapCategory = Map();
  SettingIndex activeTag = SettingIndex.product;
  Loader2 loader = Loader2();
  BOutlet outlet;
  BOperator op;
  BDevice device;
  BBillings billings;
  String ip = "";
  bool isFirstTime = true;
  String emailLogin = "";
  SettingPosisiProduk settingPosisi;
  TextEditingController contNomorPertama = TextEditingController();
  var listenerUpdateData;
  bool showEmailAlert = false;
  @override
  void initState() {
    super.initState();
    loadData();
    loadSettings();
    contNomorPertama.addListener(() {
      saveNoOrder();
    });
    settingPosisi = SettingPosisiProduk();
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstTime) {
      mapProducts = Helper.getPageData(context)["mapProducts"];
      mapCategory = Helper.getPageData(context)["mapCategory"];
      listenerUpdateData = Helper.getPageData(context)["listenerUpdateData"];
      isFirstTime = false;
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Pengaturan"), body: body());
  }

  Widget body() {
    return loader.isLoading
        ? loader
        : Stack(
            children: [
              Container(
                  child: Row(children: [
                Expanded(flex: 3, child: panelKiri()),
                Expanded(flex: 10, child: panelKanan()),
              ])),
              emailConfirm(),
            ],
          );
  }

  Widget emailConfirm() {
    if (!showEmailAlert) return Container();
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            color: Colors.grey[900],
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Wgt.spaceLeft(20),
              Wgt.text(context, "Email belum diverifikasi",
                  color: Colors.white),
              Wgt.spaceLeft(20),
              Wgt.btn(context, "Ok",
                  textcolor: Colors.orange, transparent: true, onClick: () {
                setState(() {
                  showEmailAlert = false;
                });
              }),
            ])));
  }

  Future<void> loadData() async {
    List<Future> arrFut = List();
    arrFut.add(UserManager.getString(UserManager.OUTLET_OBJ).then((value) {
      if (value != null && value != "") {
        outlet = BOutlet.parseObject(json.decode(value));
        showEmailAlert = outlet.company.owner.status == "need confirmation";
      }
    }));
    arrFut.add(UserManager.getString(UserManager.OPERATOR_OBJ).then((value) {
      if (value != null && value != "")
        op = BOperator.parseObject(json.decode(value));
    }));
    arrFut.add(UserManager.getString(UserManager.DEVICE_OBJ).then((value) {
      if (value != null && value != "")
        device = BDevice.parseObject(json.decode(value));
    }));
    arrFut.add(UserManager.getString(UserManager.BILLING_OBJ).then((value) {
      if (value != null && value != "") {
        billings = BBillings.fromJson(json.decode(value));
      }
    }));
    arrFut.add(
        UserManager.getString(UserManager.LOGIN_EMAIL_SIMPAN).then((value) {
      if (value != null && value != "") {
        emailLogin = value;
      }
    }));
    arrFut.add(
        UserManager.getString(UserManager.SETTING_NOMOR_PERTAMA).then((value) {
      if (value != null && value != "")
        contNomorPertama.text = value;
      else
        contNomorPertama.text = "1";
    }));

    await Future.wait(arrFut);
    await getIP();
    loader.isLoading = false;
    setState(() {});
  }

  Future getIP() async {
    if (await Helper.hasInternet()) {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          ip = "${addr.address}";
          await UserManager.saveString(UserManager.SETTING_IP, ip);
        }
      }
    } else {
      ip = await UserManager.getString(UserManager.SETTING_IP);
    }
  }

/* -------------------------------------------------------------------------- */
/*                                 PANEL KIRI                                 */
/* -------------------------------------------------------------------------- */
  Widget panelKiri() {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
              child: Wgt.text(context, "Pengaturan", color: Colors.grey)),
          Wgt.separator(),
          cellSetting(
              img: "ic_flip_to_front_24_px.png",
              text: "Posisi Produk",
              tag: SettingIndex.product),
          Wgt.separator(),
          cellSetting(
              img: "ic_printer_icon_blue.png",
              text: "Printer",
              tag: SettingIndex.printer),
          Wgt.separator(),
          cellSetting(
              img: "ic_build_24_px.png",
              text: "Lainnya",
              tag: SettingIndex.others),
          Wgt.separator(),
          cellSetting(
              img: "ic_info_outline_24_px_blue.png",
              text: "Informasi",
              tag: SettingIndex.info),
        ]));
  }

  Widget cellSetting({img, text, tag}) {
    bool active = activeTag == tag;
    return Expanded(
        child: Material(
            color: active ? Cons.COLOR_PRIMARY : Colors.transparent,
            child: InkWell(
                onTap: () => doClickSetting(tag),
                child: Row(children: [
                  Wgt.spaceLeft(20),
                  Image.asset("assets/$img",
                      height: 35,
                      color: active ? Colors.white : Cons.COLOR_PRIMARY),
                  Wgt.spaceLeft(20),
                  Expanded(
                      child: Wgt.text(context, "$text",
                          color: active ? Colors.white : Colors.grey[700],
                          size: Wgt.FONT_SIZE_NORMAL_2)),
                  Wgt.spaceLeft(20),
                ]))));
  }

  void doClickSetting(tag) {
    activeTag = tag;
    setState(() {});
  }

/* -------------------------------------------------------------------------- */
/*                                 PANEL KANAN                                */
/* -------------------------------------------------------------------------- */
  Widget panelKanan() {
    Widget wgt = Container();
    switch (activeTag) {
      case SettingIndex.others:
        wgt = panelAdmin();
        break;

      case SettingIndex.info:
        wgt = panelInformasi();
        break;

      case SettingIndex.product:
        wgt = settingPosisi;
        break;

      case SettingIndex.printer:
        wgt = PrinterView();
        break;

      default:
        wgt = Container();
        break;
    }

    return Container(
        child: Column(children: [
      Expanded(child: wgt),
    ]));
  }

/* -------------------------------------------------------------------------- */
/*                                    ADMIN                                   */
/* -------------------------------------------------------------------------- */
  bool nomorStruk = false;
  bool saldoRekap = false;
  bool stok = false;
  bool orderOnline = false;
  bool strukOnline = false;
  Future<void> loadSettings() async {
    List<Future> arrFut = List();
    arrFut.add(UserManager.getBool(UserManager.SETTING_NOMOR_STRUK)
        .then((value) => nomorStruk = value ?? false));
    arrFut.add(UserManager.getBool(UserManager.SETTING_SALDO_REKAP)
        .then((value) => saldoRekap = value ?? false));
    arrFut.add(UserManager.getBool(UserManager.SETTING_STOK)
        .then((value) => stok = value ?? false));
    arrFut.add(UserManager.getBool(UserManager.SETTING_ONLINE_ORDER)
        .then((value) => orderOnline = value ?? false));
    arrFut.add(UserManager.getBool(UserManager.SETTING_ONLINE_STRUK)
        .then((value) => strukOnline = value ?? false));

    await Future.wait(arrFut);

    await checkOrderOnlineActive();

    setState(() {});
  }

  void saveNoOrder() {
    String no = contNomorPertama.text;
    Order.shouldRefreshOrderid = true;

    UserManager.saveString(UserManager.SETTING_NOMOR_PERTAMA, no);
  }

  Future<void> doUpdateData() async {
    // Helper.closePage(context);

    // if (listenerUpdateData != null) listenerUpdateData();
    if (!await Helper.validateInternet(context)) return;

    SyncData.syncing = true;
    setState(() {});
    Helper.showProgress(context);
    await SyncData.syncTransactions(Base.context);
    await SyncData.syncMasterData(Base.context, force: false);
    Helper.toastSuccess(Base.context, "Data berhasil diperbarui");
    Helper.hideProgress(context);
    setState(() {});
  }

  Widget panelAdmin() {
    bool owner = op.type == "owner";
    BoxDecoration decor =
        BoxDecoration(border: Border.all(color: Colors.grey[200]));
    EdgeInsets padding =
        EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20);
    return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wgt.text(context, "Administrator"),
              Wgt.spaceTop(15),
              Container(
                  decoration: decor,
                  child: Column(children: [
                    if (owner)
                      Container(
                          padding: padding,
                          child: Row(children: [
                            Wgt.text(context, "Cetak nomor order di struk"),
                            Expanded(child: Container()),
                            CupertinoSwitch(
                                activeColor: Cons.COLOR_PRIMARY,
                                value: nomorStruk,
                                onChanged: (val) {
                                  nomorStruk = !nomorStruk;
                                  setState(() {});
                                  UserManager.saveBool(
                                      UserManager.SETTING_NOMOR_STRUK,
                                      nomorStruk);
                                }),
                          ])),
                    Wgt.separator(),
                    if (nomorStruk && owner)
                      Column(children: [
                        Container(
                            padding: padding,
                            child: Row(children: [
                              Wgt.text(context, "Nomor order pertama"),
                              Expanded(child: Container()),
                              Container(
                                  width: 70,
                                  child: CustomInput(
                                      controller: contNomorPertama,
                                      hint: "No. order",
                                      type: TextInputType.number)),
                            ])),
                        Wgt.separator(),
                      ]),
                    if (owner)
                      Container(
                          padding: padding,
                          child: Row(children: [
                            Wgt.text(context,
                                "Tampilkan saldo tercatat saat rekap kas"),
                            Expanded(child: Container()),
                            CupertinoSwitch(
                                activeColor: Cons.COLOR_PRIMARY,
                                value: saldoRekap,
                                onChanged: (val) {
                                  saldoRekap = !saldoRekap;
                                  setState(() {});
                                  UserManager.saveBool(
                                      UserManager.SETTING_SALDO_REKAP,
                                      saldoRekap);
                                }),
                          ])),
                    Wgt.separator(),
                    Container(
                        padding: padding,
                        child: Row(children: [
                          Wgt.text(context, "Aktifkan modul stock"),
                          Expanded(child: Container()),
                          CupertinoSwitch(
                              activeColor: Cons.COLOR_PRIMARY,
                              value: stok,
                              onChanged: (val) {
                                stok = !stok;
                                Order.displayStock = stok;
                                setState(() {});
                                UserManager.saveBool(
                                    UserManager.SETTING_STOK, stok);
                              }),
                        ])),
                    Wgt.separator(),
                    layoutOrderOnline(),
                    InkWell(
                        onTap: () => doUpdateData(),
                        child: Container(
                            padding: padding,
                            child: Row(children: [
                              Expanded(
                                  child: Wgt.text(context, "Perbarui data")),
                            ]))),
                  ])),
            ])));
  }

  Widget layoutOrderOnline() {
    bool enableOrderOnline = false;
    if (outlet != null &&
        outlet.company != null &&
        outlet.company.integrations != null) {
      for (var item in outlet.company.integrations) {
        if (item.method == "online-order") enableOrderOnline = true;
      }
    }
    if (!enableOrderOnline) return Container();

    EdgeInsets padding =
        EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20);
    return Container(
        child: Column(children: [
      Container(
          padding: padding,
          child: Row(children: [
            Wgt.text(context, "Terima Order Online"),
            Expanded(child: Container()),
            CupertinoSwitch(
                activeColor: Cons.COLOR_PRIMARY,
                value: orderOnline,
                onChanged: (val) async {
                  if (!await Helper.validateInternet(context))
                    return;
                  else
                    // setState(() {});
                    await activateOrderOnline();
                }),
          ])),
      Wgt.separator(),
      Container(
          padding: padding,
          child: Row(children: [
            Wgt.text(context, "Cetak Struk Order Online"),
            Expanded(child: Container()),
            CupertinoSwitch(
                activeColor: Cons.COLOR_PRIMARY,
                value: strukOnline,
                onChanged: (val) async {
                  strukOnline = !strukOnline;
                  await UserManager.saveBool(
                      UserManager.SETTING_ONLINE_STRUK, strukOnline);

                  setState(() {});
                }),
          ])),
      Wgt.separator(),
    ]));
  }

  Future activateOrderOnline({val}) async {
    Helper.showProgress(context);
    bool value = val ?? !orderOnline;
    if (value)
      return Logic(context)
          .grabActivate(
              outletid: outlet.id,
              cashierid: op.id,
              activate: val ?? !orderOnline,
              success: (json) async {
                orderOnline = true;

                await UserManager.saveBool(
                    UserManager.SETTING_ONLINE_ORDER, true);
                setState(() {});
              })
          .then((value) => Helper.hideProgress(context));
    else
      Logic(context)
          .grabOff(
              outletid: outlet.id,
              cashierid: op.id,
              activate: val ?? !orderOnline,
              success: (json) async {})
          .then((value) async {
        Helper.hideProgress(context);

        orderOnline = false;

        await UserManager.saveBool(UserManager.SETTING_ONLINE_ORDER, false);
        setState(() {});
      });
  }

  Future checkOrderOnlineActive() {
    return Logic(context).grabIsActive(
        outletid: outlet.id,
        success: (json) async {
          if (json["data"] != null) {
            orderOnline = json["data"]["status"];
            await UserManager.saveBool(
                UserManager.SETTING_ONLINE_ORDER, orderOnline);
          }
        });
  }

/* -------------------------------------------------------------------------- */
/*                               PANEL INFORMASI                              */
/* -------------------------------------------------------------------------- */
  Widget panelInformasi() {
    return SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wgt.text(context, "Informasi"),
              Wgt.spaceTop(15),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200])),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        cellInfo(
                            title: "NAMA PERANGKAT", content: "${device.name}"),
                        Wgt.separator(),
                        cellInfo(
                            title: "EMAIL",
                            content: "$emailLogin",
                            listener: () => doOpenEmail()),
                        Wgt.separator(),
                        cellInfo(
                            title: "TIPE AKUN",
                            content:
                                "${billings.tier.toString().toUpperCase()}"),
                        Wgt.separator(),
                        cellInfo(title: "ALAMAT IP", content: "$ip"),
                        Wgt.separator(),
                        cellInfo(
                            title: "CUSTOMER SUPPORT",
                            content: "support@pawoon.com",
                            trailing: InkWell(
                                onTap: () => doOpenEmail(),
                                child: Container(
                                    padding: EdgeInsets.only(
                                        top: 5, bottom: 5, left: 20, right: 20),
                                    child: Icon(Icons.email,
                                        size: 30, color: Cons.COLOR_PRIMARY)))),
                        Wgt.separator(),
                        cellInfo(
                            title: "VERSI PAWOON", content: "${Logic.VERSION}"),
                      ])),
              Wgt.spaceTop(40),
              Row(children: [
                Expanded(
                    child: InkWell(
                        onTap: () => doLogout(),
                        child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.red[700])),
                            child: Wgt.text(context, "Keluar Aplikasi",
                                color: Colors.red[700],
                                align: TextAlign.center))))
              ])
            ]));
  }

  Widget cellInfo({title, content, Widget trailing, listener}) {
    return InkWell(
      onTap: () {
        if (listener != null) listener();
      },
      child: Container(
          padding: EdgeInsets.all(20),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Wgt.textSecondary(context, "$title", color: Colors.grey),
                  Wgt.spaceTop(2),
                  Wgt.text(context, "$content"),
                ])),
            trailing != null ? trailing : Container(),
          ])),
    );
  }

  Future<void> doOpenEmail() async {
    final MailOptions mailOptions = MailOptions(
      subject: '',
      recipients: ['support@pawoon.com'],
      isHTML: true,
    );

    final MailerResponse response = await FlutterMailer.send(mailOptions);
    String platformResponse;

    switch (response) {
      case MailerResponse.saved:

        /// ios only
        platformResponse = 'mail was saved to draft';
        break;
      case MailerResponse.sent:

        /// ios only
        platformResponse = 'mail was sent';
        break;
      case MailerResponse.cancelled:

        /// ios only
        platformResponse = 'mail was cancelled';
        break;
      case MailerResponse.android:
        platformResponse = 'intent was successful';
        break;
      default:
        platformResponse = 'unknown';
        break;
    }
    // print(platformResponse);
  }

  void confirmTurnOffOrderOnline() {
    Helper.confirm(context, "",
        "Jika anda menonaktifkan perangkat ini, fitur Terima Order Online juga akan nonaktif pada perangkat ini, apakah anda yakin?",
        () async {
      if (!await Helper.validateInternet(context))
        return;
      else {
        await activateOrderOnline(val: false);
        lanjutLogout();
      }
    }, () {}, textCancel: "TIDAK", textOk: "YA");
  }

  Future<void> doLogout() async {
    if (SyncData.unsyncCount > 0) {
      Helper.popupDialog(context,
          text:
              "Terdapat data yang belum diunggah.\nSilakan pilih menu update terlebih dulu untuk menggungahnya.");
    } else {
      if (!await Helper.validateInternet(context,
          text: "Koneksi internet sedang tidak aktif")) return;
      var orderOnline =
          await UserManager.getBool(UserManager.SETTING_ONLINE_ORDER);
      if (orderOnline != null && orderOnline) {
        confirmTurnOffOrderOnline();
      } else {
        lanjutLogout();
      }
    }
  }

  void lanjutLogout() {
    Helper.confirm(
        context, "Logout", "Anda yakin menonaktifkan perangkat kasir ini?",
        () async {
      Helper.showProgress(context);

      Logic(context)
          .logout(
              deviceid: device.id,
              assignid: Logic.ASSIGNMENT_TOKEN,
              success: (json) async {
                // print(json);
              })
          .then((value) async {
        Helper.hideProgress(context);

        List<Future> arrFut = List();
        // arrFut.add(DBPawoon().clearDb());
        // arrFut.add(UserManager.clearData());
        UserManager.saveBool(UserManager.IS_LOGGED_IN, false);

        await Future.wait(arrFut);

        // Helper.closePage(context);
        Helper.openPageNoNav(context, Base());
      });
    }, () {});
  }
}

enum SettingIndex {
  product,
  printer,
  others,
  info,
}
