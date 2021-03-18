import 'package:flutter/material.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../main.dart';

class Intro extends StatefulWidget {
  Intro({Key key}) : super(key: key);

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  PageController _pageController;
  double heightIndicator = 20;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Wgt.base(context, body: body());
  }

  Widget body() {
    return Container(
        child: Column(children: [
      Container(
          margin: EdgeInsets.only(top: 40),
          height: heightIndicator,
          child: SmoothPageIndicator(
              controller: _pageController,
              count: 5,
              effect: WormEffect(
                  spacing: 8.0,
                  radius: 4.0,
                  dotWidth: 10.0,
                  dotHeight: 10.0,
                  strokeWidth: 1.5,
                  dotColor: Color(0xFFd8d8d8),
                  activeDotColor: Cons.COLOR_PRIMARY),
              onDotClicked: (index) {})),
      Expanded(
        child: Container(
            height: MediaQuery.of(context).size.height - 40 - heightIndicator,
            child: PageView(controller: _pageController, children: [
              page1(),
              page2(),
              page3(),
              page4(),
              page5(),
            ])),
      )
    ]));
  }

  /**
   * PAGE 1
   */
  Widget page1() {
    return SingleChildScrollView(
        child: Column(children: [
      // Expanded(child: Container()),
      Wgt.spaceTop(40),
      Image.asset("assets/logo_pawoon.png", height: 40),
      // Expanded(child: Container()),
      Wgt.spaceTop(40),
      Wgt.textLarge(context, "Selamat Datang di Aplikasi Kasir Pawoon",
          size: 50, align: TextAlign.center),
      Wgt.text(context, "Menglola bisnis jadi lebih mudah", size: 25),
      // Expanded(child: Container()),
      Wgt.spaceTop(40),
      Image.asset("assets/ic_onboard1.png"),
      // Expanded(child: Container()),
      Wgt.spaceTop(40),
      Wgt.btn(context, "Buat akun baru gratis",
          onClick: () => navSignup(),
          fontSize: 25,
          padding: EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15)),
      Wgt.spaceTop(20),
      InkWell(
          onTap: () => navLogin(),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Wgt.text(context, "Sudah punya akun Pawoon?",
                size: 18, color: Colors.grey),
            Wgt.spaceLeft(5),
            Wgt.text(context, "Masuk di sini",
                size: 18, color: Cons.COLOR_PRIMARY, weight: FontWeight.w600)
          ])),
      Wgt.spaceTop(40),
      // Expanded(child: Container()),
    ]));
  }

  /**
   * Page 1 actions
   */
  void navSignup() {
    Helper.openPage(context, Main.SIGNUP);
  }

  void navLogin() {
    Helper.openPage(context, Main.LOGIN);
  }

  Widget page2() {
    return SingleChildScrollView(
        child: Column(children: [
      Wgt.spaceTop(40),
      Wgt.textLarge(context, "Bertransaksi hanya dengan tiga klik",
          size: 50, align: TextAlign.center),
      Wgt.text(context,
          "Buat pelanggan Anda puas dengan proses transaksi yang cepat",
          size: 25, align: TextAlign.center),
      Wgt.spaceTop(40),
      Image.asset("assets/ic_onboard2.png",
          width: MediaQuery.of(context).size.width / 2),
      Wgt.spaceTop(40),
      Wgt.btn(context, "Buat akun baru gratis",
          onClick: () => navSignup(),
          fontSize: 25,
          padding: EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15)),
      Wgt.spaceTop(20),
      InkWell(
          onTap: () => navLogin(),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Wgt.text(context, "Sudah punya akun Pawoon?",
                size: 18, color: Colors.grey),
            Wgt.spaceLeft(5),
            Wgt.text(context, "Masuk di sini",
                size: 18, color: Cons.COLOR_PRIMARY, weight: FontWeight.w600)
          ])),
      Wgt.spaceTop(40),
    ]));
  }

  Widget page3() {
    return SingleChildScrollView(
        child: Column(children: [
      Wgt.spaceTop(40),
      Wgt.textLarge(context, "Bertransaksi hanya dengan tiga klik",
          size: 50, align: TextAlign.center),
      Wgt.text(context, "Pawoon mendukung beragam jenis metode pembayaran",
          maxlines: 10, align: TextAlign.center, size: 25),
      Wgt.spaceTop(40),
      Image.asset("assets/ic_onboard3.png",
          width: MediaQuery.of(context).size.width / 2),
      Wgt.spaceTop(40),
      Wgt.btn(context, "Buat akun baru gratis",
          onClick: () => navSignup(),
          fontSize: 25,
          padding: EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15)),
      Wgt.spaceTop(20),
      InkWell(
          onTap: () => navLogin(),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Wgt.text(context, "Sudah punya akun Pawoon?",
                size: 18, color: Colors.grey),
            Wgt.spaceLeft(5),
            Wgt.text(context, "Masuk di sini",
                size: 18, color: Cons.COLOR_PRIMARY, weight: FontWeight.w600)
          ])),
      Wgt.spaceTop(40),
    ]));
  }

  Widget page4() {
    return SingleChildScrollView(
        child: Column(children: [
      Wgt.spaceTop(40),
      Wgt.textLarge(context, "Kelola bisnis dari mana saja", size: 50),
      Wgt.text(context,
          "Lihat laporan penjualan, inventori dan pelanggan Anda, semua terekam di Pawoon",
          size: 25, maxlines: 10, align: TextAlign.center),
      Wgt.spaceTop(40),
      Image.asset("assets/ic_onboard4.png",
          width: MediaQuery.of(context).size.width / 2),
      Wgt.spaceTop(40),
      Wgt.btn(context, "Buat akun baru gratis",
          onClick: () => navSignup(),
          fontSize: 25,
          padding: EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15)),
      Wgt.spaceTop(20),
      InkWell(
          onTap: () => navLogin(),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Wgt.text(context, "Sudah punya akun Pawoon?",
                size: 18, color: Colors.grey),
            Wgt.spaceLeft(5),
            Wgt.text(context, "Masuk di sini",
                size: 18, color: Cons.COLOR_PRIMARY, weight: FontWeight.w600)
          ])),
      Wgt.spaceTop(40),
    ]));
  }

  Widget page5() {
    return SingleChildScrollView(
        child: Column(children: [
      Wgt.spaceTop(40),
      Image.asset("assets/logo_pawoon.png", height: 40),
      Wgt.spaceTop(40),
      Wgt.textLarge(context, "Coba sekarang!", size: 50),
      Wgt.text(context, "Rasakan kemudahan mengelola bisnis mulai hari ini.",
          size: 23),
      Wgt.spaceTop(40),
      Wgt.btn(context, "Buat akun baru gratis",
          onClick: () => navSignup(),
          fontSize: 25,
          padding: EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15)),
      Wgt.spaceTop(20),
      InkWell(
          onTap: () => navLogin(),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Wgt.text(context, "Sudah punya akun Pawoon?",
                size: 18, color: Colors.grey),
            Wgt.spaceLeft(5),
            Wgt.text(context, "Masuk di sini",
                size: 18, color: Cons.COLOR_PRIMARY, weight: FontWeight.w600)
          ])),
      Wgt.spaceTop(40),
      Image.asset("assets/ic_onboard1.png"),
    ]));
  }
}
