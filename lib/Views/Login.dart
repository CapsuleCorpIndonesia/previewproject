import 'package:flutter/material.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';

import '../main.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController contEmail = TextEditingController();
  TextEditingController contPass = TextEditingController();
  bool inputValid1 = false, inputValid2 = false;
  CustomInput inputEmail, inputPass;
  @override
  void initState() {
    super.initState();
    initInputs();
  }

  void initInputs() {
    inputEmail = CustomInput(
      hint: "Email",
      displayUnderline: false,
      bordered: true,
      type: TextInputType.emailAddress,
      controller: contEmail,
      validator: (text) {
        inputValid1 = false;
        if (text == "") return "*Tidak boleh kosong";
        if (!Helper.validateEmail(text)) return "*Format salah";

        inputValid1 = true;
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
        inputValid2 = false;
        if (text == "") return "*Tidak boleh kosong";
        if (text.length < 6) return "*Terlalu pendek";

        inputValid2 = true;
        setState(() {});
        return "";
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Log In"), body: body());
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
    return Column(children: [
      Expanded(
          child: Container(
              width: MediaQuery.of(context).size.width / 2,
              // height: MediaQuery.of(context).size.height - 70,
              child: Image.asset("assets/login_1.jpg", fit: BoxFit.fill)))
    ]);
  }

  Widget form() {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wgt.spaceTop(30),
          Wgt.textLarge(context, "Selamat datang kembali",
              weight: FontWeight.bold),
          Wgt.text(context, "Silahkan login dengan akun anda",
              color: Colors.grey[700]),
          Wgt.spaceTop(20),
          inputEmail,
          Wgt.spaceTop(20),
          inputPass,
          Wgt.spaceTop(30),
          Row(children: [
            Expanded(
                child: Wgt.btn(context, "MASUK",
                    enabled: inputValid1 && inputValid2,
                    onClick: () => doLogin())),
          ]),
          Wgt.spaceTop(20),
          InkWell(
              onTap: () => navForgot(),
              child: Wgt.text(context, "Lupa Password?",
                  color: Cons.COLOR_PRIMARY)),
          Wgt.spaceTop(40),
          InkWell(
              onTap: () => navSignup(),
              child: Row(children: [
                Expanded(child: Container()),
                Wgt.text(context, "Belum punya akun?"),
                Wgt.spaceLeft(5),
                Wgt.text(context, "Daftar di sini", color: Cons.COLOR_PRIMARY),
                Expanded(child: Container()),
              ])),
          Wgt.spaceTop(10),
          Center(
              child: Wgt.text(context, "\u00a9 2020, Pawoon",
                  weight: FontWeight.w300)),
          Wgt.spaceTop(20),
        ])));
  }

  Future<void> doLogin() async {
    if (!inputValid1) {
      Helper.toastError(context, "Email tidak boleh kosong");
      return;
    }

    if (!inputValid2) {
      Helper.toastError(context, "Password tidak boleh kosong");
      return;
    }

    if (!await Helper.validateInternet(context)) return;

    Helper.showProgress(context);
    Logic(context).login(
        email: contEmail.text,
        password: contPass.text,
        success: (json) async {
          Helper.hideProgress(context);
          Logic.ACCESS_TOKEN = json["access_token"];
          await UserManager.saveString(UserManager.LOGIN_EMAIL, contEmail.text);

          navOutlet();
        },
        error: (err) {
          Helper.hideProgress(context);
          Helper.popupDialog(context,
              text: "Email atau password yang Anda masukkan salah");
        });
  }

  void navSignup() {
    Helper.openPage(context, Main.SIGNUP);
  }

  void navForgot() {
    Helper.openPage(context, Main.FORGOT);
  }

  void navOutlet() {
    Helper.openPage(context, Main.OUTLET);
  }
}
