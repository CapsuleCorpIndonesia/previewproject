import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/main.dart';

class Signup extends StatefulWidget {
  Signup({Key key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController contNama = TextEditingController();
  TextEditingController contEmail = TextEditingController();
  TextEditingController contTelp = TextEditingController();
  TextEditingController contPass = TextEditingController();
  bool btnEnabled = false;
  bool inputValid1 = false,
      inputValid2 = false,
      inputValid3 = false,
      inputValid4 = false;
  bool tncChecked = false;
  bool emailExisted = false;
  bool boleherror = false;
  bool shoulderror = false;
  // boleherror && shoulderror)

  CustomInput inputName, inputEmail, inputTelp, inputPass;
  @override
  void initState() {
    super.initState();
    initInputs();
  }

  void initInputs() {
    inputName = CustomInput(
      hint: "Nama Lengkap",
      displayUnderline: false,
      bordered: true,
      controller: contNama,
      validator: (text) {
        inputValid1 = false;
        setState(() {});
        if (text == "") return "*Tidak boleh kosong";
        if (text.length <= 3) return "*Terlalu pendek";

        inputValid1 = true;
        setState(() {});
        return "";
      },
    );

    inputEmail = CustomInput(
      hint: "Email",
      displayUnderline: false,
      bordered: true,
      // errText: emailExisted ? "Email ini sudah terpakai" : null,
      type: TextInputType.emailAddress,
      controller: contEmail,
      validator: (text) {
        inputValid2 = false;
        setState(() {});
        // if (emailExisted) return "Email ini sudah terpakai";
        if (text == "") return "*Tidak boleh kosong";
        if (text.length < 6) return "*Terlalu pendek";
        if (!Helper.validateEmail(text)) return "*Format salah";

        inputValid2 = true;
        setState(() {});
        return "";
      },
    );

    inputPass = CustomInput(
      hint: "Password",
      displayUnderline: false,
      bordered: true,
      isPassword: true,
      type: TextInputType.visiblePassword,
      controller: contPass,
      validator: (text) {
        inputValid4 = false;
        setState(() {});
        if (text == "") return "*Tidak boleh kosong";
        if (text.length < 6) return "*Terlalu pendek";

        inputValid4 = true;
        setState(() {});
        return "";
      },
    );

    inputTelp = CustomInput(
      hint: "No. telepon",
      displayUnderline: false,
      bordered: true,
      type: TextInputType.phone,
      controller: contTelp,
      validator: (text) {
        inputValid3 = false;
        setState(() {});
        if (text == "") return "*Tidak boleh kosong";
        if (num.tryParse(text) == null) return "Format salah";
        if (!text.startsWith("0")) return "*Harus diawali dengan angka 0";
        if (text.length <= 9) return "*Terlalu pendek";
        if (text.length > 15) return "*Terlalu panjang";

        inputValid3 = true;
        setState(() {});
        return "";
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Daftar"), body: body());
  }

  Widget body() {
    return Container(
      child: Row(children: [
        Expanded(child: xBanner()),
        Expanded(child: form()),
      ]),
    );
  }

  Widget xBanner() {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      child:
          Image.asset("assets/x_banner_register_1.jpg", fit: BoxFit.fitWidth),
    );
  }

  Widget form() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wgt.spaceTop(30),
        Wgt.textLarge(context, "Daftar Akun", weight: FontWeight.bold),
        Wgt.text(context, "Daftar sekarang, dapatkan gratis 14 hari",
            color: Colors.grey[700]),
        Wgt.spaceTop(20),
        inputName,
        Wgt.spaceTop(20),
        inputEmail,
        Wgt.spaceTop(20),
        inputTelp,
        Wgt.spaceTop(20),
        inputPass,
        Wgt.spaceTop(30),
        Row(children: [
          Checkbox(
              value: tncChecked,
              onChanged: (val) {
                tncChecked = val;
                setState(() {
                  boleherror = true;
                  shoulderror = val == false;
                });
              },
              activeColor: Cons.COLOR_ACCENT),
          Expanded(
              child: Wrap(children: [
            Wgt.text(context, "Saya menyetujui "),
            InkWell(
                onTap: () => navSyaratKetentuan(),
                child: Wgt.text(context, "Syarat dan Ketentuan ",
                    color: Cons.COLOR_PRIMARY)),
            Wgt.text(context, ", serta "),
            InkWell(
                onTap: () => navPrivacy(),
                child: Wgt.text(context, "Kebijakan Privasi ",
                    color: Cons.COLOR_PRIMARY)),
            Wgt.text(context, "Pawoon."),
          ]))
        ]),
        if (boleherror && shoulderror)
          Wgt.textSecondary(context, "*Tidak boleh kosong", color: Colors.red),
        Wgt.spaceTop(30),
        Row(children: [
          Expanded(
              child: Wgt.btn(context, "BUAT AKUN SAYA",
                  enabled: inputValid1 &&
                      inputValid2 &&
                      inputValid3 &&
                      inputValid4 &&
                      tncChecked,
                  onClick: () => doSignup())),
        ]),
        Wgt.spaceTop(20),
        InkWell(
            onTap: () => navLogin(),
            child: Row(children: [
              Expanded(child: Container()),
              Wgt.text(context, "Sudah punya akun?"),
              Wgt.spaceLeft(5),
              Wgt.text(context, "Masuk di sini", color: Cons.COLOR_PRIMARY),
              Expanded(child: Container()),
            ])),
        Wgt.spaceTop(10),
        Center(
            child: Wgt.text(context, "\u00a9 2020, Pawoon",
                weight: FontWeight.w300)),
        Wgt.spaceTop(30),
      ])),
    );
  }

  Widget wrapEdittext(edt) {
    return Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]),
            borderRadius: BorderRadius.circular(5)),
        child: edt);
  }

  void navLogin() {
    Helper.openPage(context, Main.LOGIN);
  }

  void navInfoBisnis() {
    Helper.openPage(context, Main.INFO_BISNIS, arg: {
      "data": {
        "email": contEmail.text,
        "name": contNama.text,
        "password": contPass.text,
        "phone": contTelp.text,
        "phone_country_code": "+62",
        "from": "ios",
        "source": "ios",
        // "client_id":
      }
    });
  }

  void navSyaratKetentuan() {
    Helper.openWebview(context,
        url: "https://www.pawoon.com/syarat-dan-ketentuan-layanan/");
  }

  void navPrivacy() {
    Helper.openWebview(context,
        url: "https://www.pawoon.com/kebijakan-privasi/");
  }

  Future<void> doSignup() async {
    if (!Helper.validateInputs(context,
        arr: [contNama, contEmail, contTelp, contPass])) {
      Helper.toastError(context, "Please provide all data");
      return;
    }

    if (!await Helper.validateInternet(context)) return;

    Helper.showProgress(context);
    Logic(context)
        .checkEmail(
            email: contEmail.text,
            success: (json) {
              if (!json["existed"]) {
                // Move to next step
                navInfoBisnis();
              } else {
                // Helper.toastError(context, "Email already exists");
                Helper.popupDialog(context, text: "Email ini sudah terpakai");
                // emailExisted = true;
                // setState(() {});
              }
            })
        .then((value) => Helper.hideProgress(context));
  }
}
