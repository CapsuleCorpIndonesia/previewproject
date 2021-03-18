import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Bean/BPelanggan.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/Wgt.dart';

import 'Order.dart';

class PopupPelanggan extends StatefulWidget {
  BPelanggan customer;
  BOutlet outlet;
  var listenerPilih;
  PopupPelanggan({this.customer, this.listenerPilih, this.outlet});

  @override
  _PopupPelangganState createState() => _PopupPelangganState();
}

class _PopupPelangganState extends State<PopupPelanggan> {
  Loader2 loader = Loader2();
  @override
  void initState() {
    super.initState();
    getPoint();
  }

  @override
  Widget build(BuildContext context) {
    double width = min(650.0, MediaQuery.of(context).size.width / 2);

    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: width,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  padding: EdgeInsets.all(15),
                  child: Row(children: [
                    InkWell(
                        onTap: () => Helper.closePage(context),
                        child: Icon(Icons.clear)),
                    Wgt.spaceLeft(10),
                    Wgt.text(context, "Detil Pelanggan"),
                  ])),
              Wgt.separator(),
              loader.isLoading
                  ? loader
                  : Expanded(
                      child: Column(children: [
                      Expanded(child: detail()),
                      Container(
                          padding:
                              EdgeInsets.only(left: 15, right: 15, bottom: 15),
                          child: Row(children: [
                            Expanded(child: btnUbah()),
                            Wgt.spaceLeft(15),
                            Expanded(child: btnPilih()),
                          ]))
                    ]))
            ])));
  }

  Widget detail() {
    return SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Details customer
          Row(children: [
            // Initial
            Container(
                height: 80,
                width: 80,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Cons.COLOR_PRIMARY,
                    borderRadius: BorderRadius.circular(50)),
                child: FittedBox(
                  child: Wgt.text(
                      context, "${doGetInitials(widget.customer.name)}",
                      color: Colors.white, weight: FontWeight.w600),
                )),
            Wgt.spaceLeft(15),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wgt.text(context, "${widget.customer.name}",
                  size: Wgt.FONT_SIZE_NORMAL_2, weight: FontWeight.w600),
              Wgt.spaceTop(5),
              Wgt.textSecondary(context,
                  "${widget.customer.phone ?? "No. hp tidak terdaftar"}",
                  color: Colors.grey[600]),
              Wgt.spaceTop(5),
              Wgt.textSecondary(context,
                  "${widget.customer.email ?? "Email tidak terdaftar"}",
                  color: Colors.grey[600]),
            ]),
          ]),
          Wgt.spaceTop(30),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
                child: Container(
                    padding: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Cons.COLOR_PRIMARY, width: 3))),
                    child: Wgt.text(context, "Informasi",
                        color: Colors.grey[800], align: TextAlign.center))),
            Expanded(
                child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: Colors.grey, width: 0.5))),
                    child: Wgt.text(context, "", align: TextAlign.center)))
          ]),
          cellDetails(
              judul: "ID Member",
              content: "${widget.customer.member_id ?? ""}"),
          cellDetails(
              judul: "Jenis Kelamin",
              content:
                  "${widget.customer.gender == "male" ? "Pria" : "Wanita"}"),
          cellDetails(
              judul: "Tanggal Lahir",
              content: "${widget.customer.birth_date ?? ""}"),
          cellDetails(
              judul: "Alamat", content: "${widget.customer.address ?? ""}"),
          cellDetails(
              judul: "Catatan", content: "${widget.customer.note ?? ""}"),
        ]));
  }

  Widget btnUbah() {
    return InkWell(
        onTap: () => doUbah(),
        child: Container(
            padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            decoration:
                BoxDecoration(border: Border.all(color: Cons.COLOR_ACCENT)),
            child: Center(
                child: Wgt.text(
              context,
              "Ubah Pelanggan",
              color: Cons.COLOR_ACCENT,
            ))));
  }

  Widget cellDetails({judul = "", content = ""}) {
    return Container(
        padding: EdgeInsets.only(top: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wgt.text(context, "${judul ?? ""}",
              weight: FontWeight.bold, color: Colors.grey[800]),
          Wgt.text(context, "${content ?? ""}", color: Colors.grey[600]),
        ]));
  }

  Widget btnPilih() {
    return Wgt.btn(context, "Pilih Pelanggan",
        color: Cons.COLOR_ACCENT, onClick: () => doPilih());
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

  void doPilih() {
    if (widget.listenerPilih != null) widget.listenerPilih();
    Helper.closePage(context);
  }

  Future<void> getPoint() async {
    await Logic(context).customerPoint(
        outletid: widget.outlet.id,
        userid: widget.customer.id,
        success: (json) {
        });

    loader.isLoading = false;
    setState(() {});
  }

  void doUbah() {
     if (!Order.permissions.contains("manage_customer")) {
      Helper.toastError(
          context, "Anda tidak memiliki hak untuk mengakses fitur ini");
      return;
    }
    showDialog(
        context: context, builder: (_)=> PopupPelangganAdd(customer: widget.customer));
  }
}

class PopupPelangganAdd extends StatefulWidget {
  BPelanggan customer;
  PopupPelangganAdd({this.customer});

  @override
  _PopupPelangganAddState createState() => _PopupPelangganAddState();
}

class _PopupPelangganAddState extends State<PopupPelangganAdd> {
  CustomInput inputNama;
  CustomInput inputPhone;
  CustomInput inputMemberID;
  CustomInput inputEmail;
  CustomInput inputAlamat;
  CustomInput inputKota;
  CustomInput inputPostal;
  CustomInput inputNote;
  DateTimePicker inputDob;

  TextEditingController contNama = TextEditingController();
  TextEditingController contPhone = TextEditingController();
  TextEditingController contMemberID = TextEditingController();
  TextEditingController contEmail = TextEditingController();
  TextEditingController contAlamat = TextEditingController();
  TextEditingController contKota = TextEditingController();
  TextEditingController contPostal = TextEditingController();
  TextEditingController contNote = TextEditingController();
  TextEditingController contDob = TextEditingController();
  RadioButton radioGender;
  bool openAll = false;
  Loader2 loaderAdd = Loader2(isLoading: false);
  bool inputValid1 = false;
  bool inputValid2 = false;
  @override
  void initState() {
    super.initState();
    inputNama = CustomInput(
        hint: "Nama*",
        controller: contNama,
        validator: (text) {
          inputValid1 = false;
          if (text == "") return "*Nama wajib diisi";
          if (text.length < 5) return "*Terlalu pendek";
          if (text.length > 15) return "*Terlalu panjang";
          inputValid1 = true;
          setState(() {});
          return "";
        });
    inputPhone = CustomInput(
        hint: "Nomor Telepon*",
        controller: contPhone,
        validator: (text) {
          inputValid2 = false;
          if (text == "") return "*Tidak boleh kosong";
          if (num.tryParse(text) == null) return "Format salah";
          if (!text.startsWith("0")) return "*Harus diawali dengan angka 0";
          if (text.length <= 9) return "*Terlalu pendek";
          if (text.length > 15) return "*Terlalu panjang";

          inputValid2 = true;
          setState(() {});
          return "";
        });
    inputMemberID = CustomInput(hint: "Member ID", controller: contMemberID);
    inputEmail = CustomInput(hint: "Email", controller: contEmail);
    inputAlamat = CustomInput(hint: "Alamat", controller: contAlamat);
    inputKota = CustomInput(hint: "Kota", controller: contKota);
    inputPostal = CustomInput(hint: "Kode pos", controller: contPostal);
    inputNote = CustomInput(hint: "Catatan", controller: contNote);
    // inputDob = CustomInput(hint: "Tanggal Lahir", controller: contDob);
    inputDob = DateTimePicker(hint: "Tanggal Lahir");

    fillData();

    int valGender = widget.customer.gender == "female" ? 1 : 0 ?? 0;
    radioGender = RadioButton({0: "Pria", 1: "Wanita"}, value: valGender);
  }

  @override
  Widget build(BuildContext context) {
    double width = min(650.0, MediaQuery.of(context).size.width / 2);

    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: width,
            child: SingleChildScrollView(
              child: Column(children: [
                Container(
                    padding: EdgeInsets.all(15),
                    child: Row(children: [
                      InkWell(
                          onTap: () => Helper.closePage(context),
                          child: Icon(Icons.clear, color: Colors.grey)),
                      Wgt.spaceLeft(10),
                      Wgt.text(
                          context,
                          widget.customer == null || widget.customer.id == null
                              ? "Tambah Pelanggan"
                              : "Ubah Pelanggan",
                          size: Wgt.FONT_SIZE_NORMAL_2,
                          weight: FontWeight.bold),
                      Expanded(child: Container()),
                      loaderAdd.isLoading
                          ? loaderAdd
                          : Wgt.btn(context, " SIMPAN ",
                              onClick: () => doSimpan(),
                              enabled: inputValid1 && inputValid2,
                              color: Cons.COLOR_ACCENT,
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, top: 10, bottom: 10))
                    ])),
                Wgt.separator(),
                Container(
                    padding: EdgeInsets.all(20),
                    child: Column(children: [
                      inputNama,
                      Wgt.spaceTop(30),
                      inputPhone,
                      Wgt.spaceTop(30),
                      inputMemberID,
                      Wgt.spaceTop(30),
                      inputEmail,
                    ])),
                if (!openAll)
                  Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Row(children: [
                        Expanded(child: Container()),
                        InkWell(
                            onTap: () {
                              openAll = !openAll;
                              setState(() {});
                            },
                            child: Container(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 10),
                                child: Row(children: [
                                  Wgt.text(context, "Data Lengkap",
                                      color: Cons.COLOR_PRIMARY),
                                  Icon(Icons.arrow_drop_down_outlined,
                                      color: Cons.COLOR_PRIMARY),
                                ]))),
                        Wgt.spaceLeft(20),
                      ])),
                if (openAll)
                  Container(
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: Column(children: [
                        inputAlamat,
                        Wgt.spaceTop(30),
                        inputKota,
                        Wgt.spaceTop(30),
                        inputPostal,
                        Wgt.spaceTop(30),
                        inputNote,
                        Wgt.spaceTop(30),
                        inputDob,
                        Wgt.spaceTop(30),
                        Row(children: [
                          Wgt.text(context, "Jenis Kelamin",
                              color: Colors.grey[600]),
                          Wgt.spaceLeft(20),
                          Expanded(child: radioGender),
                          Wgt.spaceLeft(20),
                          InkWell(
                              onTap: () {
                                openAll = !openAll;
                                setState(() {});
                              },
                              child: Container(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Row(children: [
                                    Wgt.text(context, "Data Singkat",
                                        color: Cons.COLOR_PRIMARY),
                                    Icon(Icons.arrow_drop_up,
                                        color: Cons.COLOR_PRIMARY),
                                  ]))),
                        ]),
                        Wgt.spaceTop(20),
                      ])),
              ]),
            )));
  }

  void fillData() {
    if (widget.customer == null) widget.customer = BPelanggan();
    contNama.text = widget.customer.name;
    contPhone.text = widget.customer.phone;
    contMemberID.text = widget.customer.member_id;
    contEmail.text = widget.customer.email;
    contAlamat.text = widget.customer.address;
    contKota.text = widget.customer.cityName;
    inputDob.date = Helper.parseDate(dateString: widget.customer.birth_date);
    contPostal.text = widget.customer.postal_code;
  }

  void isiData() {
    widget.customer.address = contAlamat.text;
    widget.customer.birth_date =
        Helper.toDate(datetime: inputDob.date, parseToFormat: "yyyy-MM-dd");
    widget.customer.email = contEmail.text;
    // widget.customer.gender = cont.text;
    // widget.customer.genderType = cont.text;
    widget.customer.name = contNama.text;
    widget.customer.note = contNote.text;
    widget.customer.phone = contPhone.text;
    widget.customer.postal_code = contPostal.text;
    widget.customer.cityName = contKota.text;
    widget.customer.isActive = 1;
    widget.customer.registeredTimestamp = Helper.formatISOTime(Helper.toDate(
        parseToFormat: "yyyy-MM-dd'T'HH:mm:ss", datetime: DateTime.now()));
  }

  Future<void> doSimpan() async {
    if (!inputValid1 || !inputValid2) {
      return;
    }

    isiData();
    loaderAdd.isLoading = true;
    setState(() {});

    if (widget.customer.serverId != null && widget.customer.serverId == "") {
      await doUpdate();
      await DBPawoon().insertOrUpdate(
          tablename: DBPawoon.DB_CUSTOMERS, data: widget.customer.toMap());

      loaderAdd.isLoading = false;
      setState(() {});
      Helper.closePage(context, payload: true);
    } else {
      await doAddBaru();
      await DBPawoon().insertOrUpdate(
          tablename: DBPawoon.DB_CUSTOMERS, data: widget.customer.toMap());

      loaderAdd.isLoading = false;
      setState(() {});
      Helper.closePage(context, payload: true);
    }
  }

  Future doAddBaru() {
    return Logic(context).customerAdd(
        data: widget.customer.toJson(),
        success: (json) async {
          if (json["data"] == null) {
            Helper.toastError(context, "Gagal menambah pelanggan");
            return;
          }

          var data = json["data"];
          widget.customer.loyalty_user_id = data["loyalty_user_id"];
          widget.customer.serverId = data["id"];
        });
  }

  Future doUpdate() {
    return Logic(context).customerUpdate(
        serverid: widget.customer.serverId,
        data: widget.customer.toJson(),
        success: (json) {
          if (json["data"] == null) {
            Helper.toastError(context, "Gagal update");
            return;
          }
        });
  }
}
