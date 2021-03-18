import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pawoon/Views/Base.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'Api.dart';
import 'Cons.dart';
import 'Helper.dart';
import 'ThreeSizeDot.dart';

typedef Listener = void Function();

// ignore: camel_case_types
class Wgt {
  static const double FONT_SIZE_NORMAL = 18;
  static const double FONT_SIZE_SMALL = 15;
  static const double FONT_SIZE_NORMAL_2 = 22;
  static const double FONT_SIZE_LARGE = 30;
  static const double FONT_SIZE_LARGE_X = 40;
  static const double FONT_SIZE_SMALL_2 = 11;

  static Widget edittext(context,
      {String hint,
      bool displayTopHint = true,
      bool displayLeftHint = false,
      hintColor = Colors.grey,
      String textvalue,
      String imageName = "",
      icon,
      TextInputType type = TextInputType.text,
      bool isPassword = false,
      extraText,
      displayUnderline = true,
      color = Colors.black,
      enabled = true,
      bordered = false,
      maxlines = 1,
      borderColor,
      double borderRadius = 5.0,
      double borderPaddingX = 10.0,
      double borderPaddingY = 7.0,
      TextEditingController controller,
      onchange}) {
    if (controller != null && textvalue != "") controller.text = textvalue;
    if (controller == null && textvalue != "") {
      controller = TextEditingController();
      controller.text = textvalue;
    }

    var border = null;
    if (bordered) {
      if (borderColor == null) borderColor = Colors.grey[300];
      border = BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(borderRadius));
      displayTopHint = false;
      displayUnderline = false;
    } else {
      borderPaddingX = 0;
      borderPaddingY = 0;
    }
    return Container(
      padding: EdgeInsets.only(
          left: borderPaddingX,
          right: borderPaddingX,
          top: borderPaddingY,
          bottom: borderPaddingY),
      decoration: border,
      child: Container(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
            Container(
                child: displayTopHint
                    ? textSecondary(context, hint)
                    : SizedBox(height: 0)),
            Row(children: <Widget>[
              Container(
                  child: displayLeftHint
                      ? Container(
                          margin:
                              EdgeInsets.only(bottom: displayUnderline ? 0 : 0),
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width / 3.5,
                              child: text(context, hint,
                                  color: hintColor, maxlines: 1)))
                      : text(context, "")),
              imageName != ""
                  ? Image.asset('assets/$imageName',
                      width: imageName == "" ? 0 : 16)
                  : icon != null
                      ? icon
                      : SizedBox(width: 0, height: 0),
              SizedBox(width: imageName == "" ? 0 : 10),
              Expanded(
                  child: TextField(
                maxLines: maxlines,
                obscureText: isPassword,
                keyboardType: type,
                enabled: enabled,
                controller: controller,
                minLines: 1,
                onChanged: onchange,
//                 onTap: () {
//                   // Enable textfield buat bisa pindah cursor ke blkg kalo dia field nya password
// //            controller.selection = TextSelection.collapsed(offset: controller.text.length);
//                 },
                style: TextStyle(color: color, fontSize: 15),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 1,
                        right: 1,
                        bottom: displayUnderline ? 5 : 5,
                        top: 5),
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(color: Cons.COLOR_TEXT_HINT)),
                autofocus: false,
              )),
              isPassword
                  ? smallBtn(context,
                      icon: Icons.clear,
                      size: 12,
                      iconColor: Colors.grey,
                      bgColor: Colors.transparent, onClick: () {
                      controller.clear();
                    })
                  : Container(),
              Container(
                  child: extraText != null
                      ? Container(
                          margin:
                              EdgeInsets.only(bottom: displayUnderline ? 0 : 0),
                          child: text(context, extraText,
                              color: color, maxlines: 1))
                      : text(context, "")),
            ]),
            displayUnderline
                ? separator(
                    color: Cons.COLOR_TEXT_HINT,
                    marginleft: displayLeftHint
                        ? MediaQuery.of(context).size.width / 3.5
                        : 0)
                : Container()
          ])),
    );
  }

  static Widget edittextSmall(context,
      {String hint,
      bool displayTopHint = true,
      bool displayLeftHint = false,
      String textvalue,
      String imageName = "",
      icon,
      TextInputType type = TextInputType.text,
      bool isPassword = false,
      extraText,
      displayUnderline = true,
      color = Colors.black,
      TextEditingController controller}) {
    if (controller != null && textvalue != "") controller.text = textvalue;

    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
      Container(
          child: displayTopHint
              ? textSecondarySmall(context, hint)
              : SizedBox(height: 0)),
      Row(
        children: <Widget>[
          Container(
              child: displayLeftHint
                  ? Container(
                      margin: EdgeInsets.only(bottom: displayUnderline ? 5 : 0),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3.5,
                          child: textSecondary(context, hint,
                              color: Colors.grey, maxlines: 1)))
                  : textSecondary(context, "")),
          imageName != ""
              ? Image.asset('assets/$imageName',
                  width: imageName == "" ? 0 : 25)
              : icon != null
                  ? icon
                  : SizedBox(width: 0, height: 0),
          SizedBox(
            width: imageName == "" ? 0 : 10,
          ),
          Flexible(
              child: TextField(
            obscureText: isPassword,
            keyboardType: type,
            controller: controller == null
                ? TextEditingController(text: textvalue)
                : controller,
            style: TextStyle(color: color, fontSize: FONT_SIZE_NORMAL),
            decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                    left: 1,
                    right: 1,
                    bottom: displayUnderline ? 10 : 5,
                    top: 5),
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(color: Cons.COLOR_TEXT_HINT)),
            autofocus: false,
          )),
          Container(
              child: extraText != null
                  ? Container(
                      margin: EdgeInsets.only(bottom: displayUnderline ? 5 : 0),
                      child: textSecondary(context, extraText,
                          color: color, size: 18, maxlines: 1))
                  : textSecondary(context, "")),
        ],
      ),
      displayUnderline
          ? separator(
              color: Cons.COLOR_TEXT_HINT,
              marginleft:
                  displayLeftHint ? MediaQuery.of(context).size.width / 3.5 : 0)
          : Container()
    ]));
  }

  static Widget btn(context, text,
      {Color color,
      double radius = 0,
      Listener onClick,
      bool transparent = false,
      Color textcolor = Colors.white,
      TextAlign align = TextAlign.center,
      double height = 50,
      bool enabled = true,
      disabledColor,
      double fontSize = FONT_SIZE_NORMAL,
      disabledTextColor = Colors.white,
      padding,
      borderColor,
      weight = FontWeight.w600,
      shadow = false}) {
    if (color == null) color = Cons.COLOR_PRIMARY;
    if (disabledColor == null) disabledColor = Colors.grey[400];
    var decorationShadow;
    if (shadow)
      decorationShadow = BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.grey[350],
          blurRadius: 3.0,
          offset: Offset(0.0, 2.0),
        )
      ]);
    if (transparent) {
      if (borderColor == null) borderColor = Colors.transparent;
      return Container(
          height: padding == null ? height : null,
          decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(radius)),
          child: ClipRRect(
              child: FlatButton(
                  padding: padding,
                  height: padding == null ? height : null,
                  color: Colors.transparent,
                  child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Container(
                        child: Text(text,
                            textAlign: align,
                            style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: weight,
                                color: textcolor)))
                  ]),
                  onPressed: () {
                    if (onClick != null) onClick();
                  })));
    } else {
      if (!enabled) {
        color = disabledColor;
        textcolor = disabledTextColor;
      }

      return Container(
          height: padding == null ? height : null,
          decoration: decorationShadow,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: RaisedButton(
                  padding: padding,
                  color: color,
                  child: Text(
                    text,
                    textAlign: align,
                    style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: weight,
                        color: textcolor),
                  ),
                  onPressed: enabled
                      ? () {
                          if (onClick != null) onClick();
                        }
                      : null)));
    }
  }

  static Widget btnProgress(context, text,
      {Color color,
      bool rounded = false,
      Listener onClick,
      bool transparent = false,
      Color textcolor = Colors.white,
      double radius = 5.0,
      shadow = true}) {
    if (color == null) color = Cons.COLOR_PRIMARY;
    if (rounded) radius = 40;

    var decorationShadow = null;
    if (shadow)
      decorationShadow = BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.grey[350],
          blurRadius: 3.0,
          offset: Offset(0.0, 2.0),
        )
      ]);
    return SafeArea(
      child: Row(children: <Widget>[
        Expanded(
            child: Container(
                height: 40,
                decoration: decorationShadow,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: ProgressButton(
                      defaultWidget: Text(
                        text,
                        style: TextStyle(
                            fontSize: FONT_SIZE_NORMAL,
                            fontWeight: FontWeight.w600,
                            color: textcolor),
                      ),
                      progressWidget: ThreeSizeDot(
                        color_1: Colors.white,
                        color_2: Colors.white,
                        color_3: Colors.white,
                      ),
                      color: color,
                      onPressed: onClick != null ? onClick : () {},
                      // How to use :
                      /*
              onClick: () async {
                            await *return HTTPImb*;
                          }
               */
                    ))))
      ]),
    );
  }

  static Widget textureBackground(context, {name = "bg.png"}) {
    return Container(
      color: Cons.COLOR_BG,
    );
//    return Container(
//        width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: Image.asset("assets/$name", fit: BoxFit.cover));
  }

  // Kalau kasih custom leftIcon, harus kasih sama onpressed nya
  static AppBar appbar(context,
      {name,
      bool elevation = true,
      color,
      displayLeft = false,
      displayRight = false,
      leftIcon,
      rightIcon,
      rightText,
      rightTextColor,
      arrIconButtons,
      onLeftClick,
      onRightClick,
      bottom,
      double titleSpacing = 0.0,
      itemOnRightTitle,
      heroTitleTag,
      bool displayPawoonLogo = true,
      textColor}) {
    if (color == null) color = Cons.COLOR_APP_BAR;
    if (textColor == null) textColor = Colors.white;
    if (itemOnRightTitle == null) itemOnRightTitle = Container();
    return displayLeft
        ?
        // ---- AppBar DENGAN custom left icon ----
        // Menghilangkan tombol back
        AppBar(
            bottom: bottom,
            backgroundColor: color,
            brightness: Brightness.light,
            titleSpacing: titleSpacing,
            title: Row(children: <Widget>[
              Hero(
                  tag: heroTitleTag != null
                      ? heroTitleTag
                      : "${DateTime.now().millisecondsSinceEpoch}",
                  child: Text(name == null ? "" : name,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: FONT_SIZE_NORMAL,
                          color:
                              textColor == null ? Colors.black : textColor))),
              Expanded(child: Container()),
              displayPawoonLogo
                  ? Image.asset("assets/pawoon_transparant_white.png",
                      height: 25)
                  : Container(),
              Expanded(child: Container()),
            ]),
            elevation: elevation ? 3 : 0,
            iconTheme: IconThemeData(color: Colors.white),
            automaticallyImplyLeading: true,
            leading: IconButton(
                icon: displayLeft
                    ? leftIcon != null
                        ? leftIcon
                        : IconButton(
                            icon: Icon(Icons.menu, color: Colors.white),
                            onPressed: onLeftClick,
                            iconSize: 30)
                    : SizedBox()),
            actions: displayRight && arrIconButtons == null
                ? <Widget>[
                    displayRight
                        ? rightIcon != null
                            ? IconButton(
                                icon: rightIcon,
                                iconSize: 30,
                                onPressed: onRightClick)
                            : rightText != null
                                ? InkWell(
                                    onTap: onRightClick,
                                    child: Container(
                                        margin: EdgeInsets.only(right: 15),
                                        child: Center(
                                            child: text(context, rightText,
                                                weight: FontWeight.w600,
                                                color: rightTextColor == null
                                                    ? Colors.grey[700]
                                                    : rightTextColor,
                                                size: 13))))
                                : SizedBox()
                        : SizedBox()
                  ]
                : displayRight && arrIconButtons != null
                    ? arrIconButtons
                    : <Widget>[])
        // ---- AppBar tanpa custom left icon ----
        : AppBar(
            bottom: bottom,
            backgroundColor: color,
            titleSpacing: titleSpacing,
            brightness: Brightness.light,
            iconTheme: IconThemeData(color: Colors.white),
            title: Row(children: <Widget>[
              Expanded(
                child: Text(name == null ? "" : name,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: FONT_SIZE_NORMAL,
                        color: textColor == null ? Colors.white : textColor)),
              ),
              displayPawoonLogo
                  ? Container(
                      child: Image.asset("assets/pawoon_transparant_white.png",
                          height: 25),
                    )
                  : Container(),
              Expanded(
                  child: Container(
                height: 55,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: displayRight && arrIconButtons != null
                        ? arrIconButtons
                        : displayRight && rightIcon != null
                            ? <Widget>[
                                IconButton(
                                    icon: rightIcon,
                                    iconSize: 30,
                                    onPressed: onRightClick),
                              ]
                            : displayRight && rightText != null
                                ? <Widget>[
                                    InkWell(
                                        onTap: onRightClick,
                                        child: Container(
                                            margin: EdgeInsets.only(right: 15),
                                            child: Center(
                                                child: text(context, rightText,
                                                    weight: FontWeight.w600,
                                                    color:
                                                        rightTextColor == null
                                                            ? Colors.grey[700]
                                                            : rightTextColor,
                                                    size: 13)))),
                                  ]
                                : <Widget>[]),
              )),
            ]),
            elevation: elevation ? 3 : 0,
            automaticallyImplyLeading: true,
            actions: [Container()],
          );
  }

  static Widget base(context,
      {appbar,
      background,
      body,
      drawer,
      rightDrawer,
      GlobalKey<ScaffoldState> key,
      FloatingActionButton floatingActionButton,
      bottomNavBar,
      page_tag = "",
      broadcast}) {
    if (background == null) background = Wgt.textureBackground(context);
    try {
      if (page_tag == "")
        Base.context = context;
      else
        Base.context2 = context;

      Base.page_tag = page_tag;
      Base.broadcast = broadcast;
    } catch (e) {
      print(e);
    }
    return OrientationBuilder(builder: (context, orientation) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      return Material(
          child: Stack(children: <Widget>[
        background,
        AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              // For Android.
              // Use [light] for white status bar and [dark] for black status bar.
              statusBarIconBrightness: Brightness.dark,
              // For iOS.
              // Use [dark] for white status bar and [light] for black status bar.
              statusBarBrightness: Brightness.light,
            ),
            child: Scaffold(
              appBar: appbar,
              backgroundColor: Colors.transparent,
              body: body,
              drawer: drawer,
              key: key,
              endDrawer: rightDrawer,
              floatingActionButton: floatingActionButton,
              bottomNavigationBar: bottomNavBar,
            )),
//      Positioned(
//        bottom: 0,
//        child: Container(
//          padding: EdgeInsets.only(top: 5, bottom: 5),
//          width: MediaQuery.of(context).size.width,
//          color: Colors.red,
//          alignment: Alignment(0, 0),
//          child: textSecondarySmall(context, "Please complete payment to activate membership", color: Colors.white, size: 13, italic: true),
//        ),
//      )
      ]));
    });
  }

  // ---- TEXT ----
  static Text title1(context, text,
      {color, TextAlign align, maxlines, italic = false}) {
    return Text(text,
        maxLines: maxlines != null ? maxlines : null,
        textAlign: align == null ? TextAlign.start : align,
        style: TextStyle(
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: color == null ? Colors.black : color,
            fontSize: FONT_SIZE_LARGE,
            fontWeight: FontWeight.bold,
            fontFamily: 'Avenir'));
  }

  static Text title1Note(context, text,
      {color, TextAlign align, maxlines, italic = false}) {
    return Text(text,
        maxLines: maxlines != null ? maxlines : null,
        textAlign: align == null ? TextAlign.start : align,
        style: TextStyle(
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: color == null ? Colors.grey[500] : color,
            fontSize: FONT_SIZE_SMALL,
            fontFamily: 'Avenir'));
  }

  static Text title2(context, text,
      {color, TextAlign align, maxlines, italic = false}) {
    return Text(text,
        maxLines: maxlines != null ? maxlines : null,
        textAlign: align == null ? TextAlign.start : align,
        style: TextStyle(
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: color == null ? Colors.grey[700] : color,
            fontSize: FONT_SIZE_NORMAL,
            fontWeight: FontWeight.bold,
            fontFamily: 'Avenir'));
  }

  static Text textSecondary(context, text,
      {color,
      FontWeight weight,
      TextAlign align,
      maxlines,
      double size,
      italic = false,
      TextDecoration decoration}) {
    return Text(text,
        maxLines: maxlines != null ? maxlines : null,
        textAlign: align == null ? TextAlign.start : align,
        overflow: maxlines != null ? TextOverflow.ellipsis : null,
        style: TextStyle(
            decoration: decoration,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: color == null ? Colors.grey : color,
            fontSize: size == null ? FONT_SIZE_SMALL : size,
            fontWeight: weight == null ? FontWeight.normal : weight,
            fontFamily: 'Avenir'));
  }

  static Text textSecondarySmall(context, text,
      {color,
      FontWeight weight,
      TextAlign align,
      maxlines,
      double size,
      italic = false,
      TextDecoration decoration}) {
    if (weight == null) weight = FontWeight.w300;
    return Text(text,
        maxLines: maxlines != null ? maxlines : null,
        textAlign: align == null ? TextAlign.start : align,
        overflow: maxlines != null ? TextOverflow.ellipsis : null,
        style: TextStyle(
            decoration: decoration,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: color == null ? Colors.grey : color,
            fontSize: size == null ? FONT_SIZE_SMALL_2 : size,
            fontWeight: weight == null ? FontWeight.normal : weight,
            fontFamily: 'Avenir'));
  }

  static Text text(context, text,
      {color,
      FontWeight weight,
      TextAlign align,
      maxlines,
      double size,
      italic = false,
      TextDecoration decoration,
      TextOverflow overflow}) {
    return Text(text,
        maxLines: maxlines != null ? maxlines : null,
        textAlign: align == null ? TextAlign.start : align,
        overflow: maxlines != null
            ? overflow != null
                ? overflow
                : TextOverflow.ellipsis
            : null,
        softWrap: false,
        style: TextStyle(
            decoration: decoration,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: color == null ? Colors.black : color,
            fontSize: size == null ? FONT_SIZE_NORMAL : size,
            fontWeight: weight == null ? FontWeight.normal : weight,
            fontFamily: 'Avenir'));
  }

  static Text textLarge(context, text,
      {color,
      FontWeight weight,
      TextAlign align,
      maxlines,
      italic = false,
      double size}) {
    if (size == null) size = FONT_SIZE_LARGE;

    return Text(text,
        maxLines: maxlines != null ? maxlines : null,
        textAlign: align == null ? TextAlign.start : align,
        style: TextStyle(
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: color == null ? Colors.black : color,
            fontSize: size,
            fontWeight: weight == null ? FontWeight.normal : weight,
            fontFamily: 'Avenir'));
  }

  static Text textAction(context, text,
      {color,
      FontWeight weight = FontWeight.w600,
      TextAlign align,
      maxlines,
      double size,
      italic = false}) {
    return Text(text,
        maxLines: maxlines != null ? maxlines : null,
        textAlign: align == null ? TextAlign.start : align,
        overflow: maxlines != null ? TextOverflow.ellipsis : null,
        style: TextStyle(
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: color == null ? Colors.grey : color,
            fontSize: size == null ? FONT_SIZE_SMALL : size,
            fontWeight: weight == null ? FontWeight.w600 : weight,
            fontFamily: 'Avenir'));
  }

  static Widget textPct(context, text,
      {color,
      FontWeight weight,
      TextAlign align,
      maxlines,
      double size = FONT_SIZE_SMALL,
      italic = false,
      TextDecoration decoration,
      decimalPlace = 2}) {
    if (text == null) return Container();
    return Text("${double.parse(text).toStringAsFixed(decimalPlace)}%",
        maxLines: maxlines != null ? maxlines : null,
        textAlign: align == null ? TextAlign.start : align,
        overflow: maxlines != null ? TextOverflow.ellipsis : null,
        style: TextStyle(
            decoration: decoration,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: double.parse(text) >= 0 ? Cons.COLOR_GREEN : Colors.red[600],
            fontSize: size,
            fontWeight: weight == null ? FontWeight.normal : weight,
            fontFamily: 'Avenir'));
  }

  static Widget textDollarValue(context, text,
      {color = Colors.grey,
      FontWeight weight,
      TextAlign align,
      maxlines,
      double size,
      italic = false,
      TextDecoration decoration,
      decimalPlace = 2,
      displayAsBox = true,
      neutral = false}) {
    if (num.tryParse(text) == null) return Container();
    if (text.toString().contains("e"))
      text = text.toString().substring(0, text.toString().indexOf("e") - 1);
    final formatter = NumberFormat("#,###.##");
    if (displayAsBox) {
      var value = num.parse(text);
      return ConstrainedBox(
        constraints: BoxConstraints(minWidth: 60),
        child: Container(
//          width: 60,
            height: 25,
            alignment: Alignment(0, 0),
            padding: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
                color: neutral
                    ? Colors.blueGrey[100]
                    : value > 0
                        ? Cons.COLOR_GREEN
                        : value == 0
                            ? Colors.blueGrey[100]
                            : Cons.COLOR_RED,
                borderRadius: BorderRadius.circular(5)),
//      child: Wgt.text(context, '$val %', color: Colors.white, weight: FontWeight.w700, size: !displaySmall ? 15 : 12),
            child: Text(
              '\$ ${formatter.format(value)}',
              maxLines: 1,
//            minFontSize: 8,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            )),
      );
    }
    return Text("\$ ${double.parse(text).toStringAsFixed(decimalPlace)}",
        maxLines: maxlines != null ? maxlines : null,
        textAlign: align == null ? TextAlign.start : align,
        overflow: maxlines != null ? TextOverflow.ellipsis : null,
        style: TextStyle(
            decoration: decoration,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: neutral
                ? color
                : double.parse(text) > 0
                    ? Cons.COLOR_GREEN
                    : double.parse(text) == 0
                        ? color
                        : Colors.red[600],
            fontSize: size == null ? 15 : size,
            fontWeight: weight == null ? FontWeight.normal : weight,
            fontFamily: 'Avenir'));
  }

  static Widget spaceTop(double size) {
    return SizedBox(height: size);
  }

  static Widget spaceLeft(double size) {
    return SizedBox(width: size);
  }

  static Widget separator(
      {double marginleft = 0,
      double marginright = 0,
      double margintop = 0,
      double marginbot = 0,
      color}) {
    return Container(
      margin: EdgeInsets.only(left: marginleft, right: marginright),
      child: SizedBox(
          height: 1 + margintop + marginbot,
          child: Container(
              margin: EdgeInsets.only(top: margintop, bottom: marginbot),
              color: color == null ? Colors.grey[200] : color)),
    );
  }

  static Widget card(context, child,
      {double radius = 5.0, EdgeInsets margin, color, double blurRadius = 3}) {
    if (color == null) color = Colors.grey[350];
    return Container(
      child: child,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color,
              blurRadius: blurRadius,
              offset: Offset(0.0, 2.0),
            )
          ]),
      margin: margin == null ? EdgeInsets.all(5.0) : margin,
    );
  }

  static Widget currentPrice(context, double value, {isPlus = true}) {
    return Container(
      child: Wgt.text(context, '\$ $value',
          color: isPlus ? Cons.COLOR_GREEN : Colors.red, size: 18),
    );
  }

  static Widget linedata(context, title, value, {onclick}) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Wgt.text(context, "$title",
                color: Colors.grey[700], maxlines: 1)),
        Wgt.text(context, ": "),
        onclick != null
            ? Expanded(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: onclick,
                        child: Wgt.text(context, "$value",
                            color: Colors.grey[700], maxlines: 1))))
            : Expanded(
                child: Wgt.text(context, "$value",
                    color: Colors.grey[700], maxlines: 1))
      ]),
    );
  }

  static Widget notificationBullet(context, int value) {
    if (value <= 0) return Container();

    return Container(
        width: 17,
        height: 17,
        alignment: Alignment(0, 0),
        decoration: BoxDecoration(
            color: Colors.red[300],
            border: Border.all(color: Colors.red[300]),
            borderRadius: BorderRadius.circular(20)),
        child: text(context, "$value", size: 10, color: Colors.white));
  }

  static Widget smallBtn(context,
      {bgColor = Colors.grey,
      icon = Icons.close,
      iconColor = Colors.grey,
      onClick,
      double size = 20}) {
    return InkWell(
      onTap: onClick,
      child: Container(
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: bgColor)),
          child: Icon(icon, color: iconColor, size: size)),
    );
  }

  static Widget sv(context, child) {
    return LayoutBuilder(builder: (context, constraint) {
      return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(child: child)));
    });
  }

  static Widget lv(context, child) {
    return LayoutBuilder(builder: (context, constraint) {
      return ListView(children: <Widget>[
        ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraint.maxHeight),
            child: IntrinsicHeight(child: child))
      ], physics: AlwaysScrollableScrollPhysics());
    });
  }

  static Widget emptySpace(context) {
    return Expanded(child: Container());
  }

  static Widget image(
      {url,
      placeholder = "logo.png",
      double width,
      double height,
      fit = BoxFit.cover,
      rounded = false,
      square = false,
      double roundedRadius = 0}) {
    if (url != null && !url.toString().startsWith("http")) url = "" + url;
    if (square) {
      if (height != null && width == null) {
        width = height;
      }
      if (width != null && height == null) {
        height = width;
      }
    }
    if (rounded) {
      if (width != null)
        roundedRadius = width;
      else if (height != null) roundedRadius = height;
    }
    return ClipRRect(
        borderRadius: BorderRadius.circular(roundedRadius),
        child: url != null && url != ""
            ? CachedNetworkImage(
                fit: fit,
                height: height,
                width: width,
                imageUrl: url,
                placeholder: (context, url) => Container(
                    child: CupertinoActivityIndicator(),
                    height: height,
                    width: width),
                errorWidget: (context, url, error) => Image.asset(
                    "assets/$placeholder",
                    fit: fit,
                    height: height,
                    width: width))
            : FadeInImage(
                fit: fit,
                height: height,
                width: width,
                image: AssetImage("assets/$placeholder"),
                placeholder: AssetImage("assets/$placeholder"),
              ));
  }

  static Widget noRecord(context) {
    return Column(children: <Widget>[
      Wgt.spaceTop(10),
      Center(
          child: Wgt.textSecondary(context, "No records found",
              align: TextAlign.center, italic: true)),
    ]);
  }

  static Widget logoLevel(context, {level, double width = 35}) {
    var img = "gold";
    if (level == "1") {
      img = "silver";
    } else if (level == "2") {
      img = "gold";
    }
    return Image.asset("assets/ic_$img.png", width: width);
  }

  static Widget pair(context,
      {pair,
      double size = 15,
      double textSize = 11,
      textColor = Colors.black,
      double spacetop = 1,
      FontWeight weight = FontWeight.normal,
      displayJenisText = true,
      displayText = true,
      double marginright = 0,
      double marginleft = 0}) {
    if (pair == null || pair == "") pair = "BTC";
    pair = pair
        .toString()
        .replaceAll("-USDT", "")
        .replaceAll("_BOTH", "")
        .replaceAll("_LONG", "")
        .replaceAll("_SHORT", "")
        .replaceAll("USDT", "");
    if (pair.toString().contains("-") && pair.toString().split("-").length > 2)
      pair =
          "${pair.toString().split("-")[0]}-${pair.toString().split("-")[1]}";
    Widget jenis = Container();
    if (pair != null &&
        pair != "" &&
        pair.toString().contains("-") &&
        pair.toString().split("-")[1] == "USDT")
      jenis = Row(children: <Widget>[
        Wgt.spaceLeft(5),
        Image.asset("assets/usdt.png", width: size)
      ]);
    else
      jenis = Container();
    return Row(children: <Widget>[
      Wgt.spaceLeft(marginleft),
      Stack(children: <Widget>[
        Image.asset(
            "assets/${pair.toString().contains("-") ? pair.toString().split("-")[0].toLowerCase() : pair.toLowerCase()}.png",
            width: size),
        Padding(padding: EdgeInsets.only(left: size / 3), child: jenis)
      ]),
      Wgt.spaceLeft(5),
      Column(children: <Widget>[
        Wgt.spaceTop(spacetop),
        displayJenisText
            ? Wgt.text(context, "${pair.toString().replaceAll("-", " / ")}",
                size: textSize, color: textColor, weight: weight)
            : displayText
                ? Wgt.text(context, "${pair.toString().split("-")[0]}",
                    size: textSize, color: textColor, weight: weight)
                : Container(),
      ]),
      Wgt.spaceLeft(marginright),
    ]);
  }

  static Widget buysell(context,
      {buysell = "BUY", double marginright = 0, double marginleft = 0}) {
    bool isbuy = buysell == "BUY" || buysell == "LONG";
    var color = isbuy ? Colors.green[400] : Colors.red[400];
    var text = isbuy ? "B" : "S";
    return Container(
        margin: EdgeInsets.only(right: marginright, left: marginleft),
        width: 12,
        height: 12,
        child: Center(
            child: Wgt.text(context, text,
                size: 8, weight: FontWeight.w700, color: Colors.white)),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(3)));
  }

  static Widget timeframe(context,
      {timeframe, double marginLeft = 0.0, double marginRight = 0.0}) {
    Color color = Colors.pink[400];
    switch (timeframe) {
      case "h1":
        color = Colors.purple[400];
        break;
      case "h2":
        color = Colors.purple[600];
        break;
      case "h4":
        color = Colors.deepPurple[400];
        break;
      case "h6":
        color = Colors.deepPurple[600];
        break;
      case "h12":
        color = Colors.indigo[400];
        break;
      case "1d":
        color = Colors.indigo[600];
        break;
      default:
        timeframe = "$timeframe";
        break;
    }

    return Container(
        padding: EdgeInsets.only(left: 2, right: 2, top: 0),
        margin: EdgeInsets.only(left: marginLeft, right: marginRight),
        height: 12,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(2.5)),
        child: Center(
            child: text(context, "${timeframe.toString().toUpperCase()}",
                size: 7,
                weight: FontWeight.w600,
                color: Colors.white,
                align: TextAlign.center)));
  }

  static Widget icon(context,
      {text, double marginLeft = 0.0, double marginRight = 0.0, color}) {
    if (color == null) color = Colors.red[400];
    if (text == null) return Container();
    return Container(
        margin: EdgeInsets.only(right: 3),
        padding: EdgeInsets.only(left: 2, right: 2, top: 1, bottom: 2),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: color)),
        child: Wgt.textSecondarySmall(context, "$text",
            size: 6, color: Colors.white));
  }

  // ========================= CUSTOM =========================
  static Widget smallSeparatorColored(context,
      {double width = 30,
      double height = 3.0,
      double margintop = 0,
      double marginbot = 0,
      double marginleft = 0,
      double marginright = 0}) {
    return Container(
        margin: EdgeInsets.only(
            left: marginleft,
            right: marginright,
            top: margintop,
            bottom: marginbot),
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: Cons.COLOR_PRIMARY, borderRadius: BorderRadius.circular(5)));
  }
}

class Dropdown {
  Map<String, String> _list = {"1": "A", "2": "B"}; // Option 2
  String selected;

  Dropdown setList(Map<String, String> l) {
    this._list = l;
    return this;
  }

  String getSelected() {
    return selected;
  }

  // Need to refresh state
  Widget generate(context,
      {hint = "Pilih", onRefreshState, isExpanded = false}) {
    return DropdownButton(
      elevation: 1,
      isDense: false,
      iconSize: 30,
      isExpanded: true,
      hint: Container(
          padding: EdgeInsets.all(10),
          child: Wgt.text(context, hint, color: Colors.grey)),
      // Not necessary for Option 1
      value: selected,
      onChanged: (newValue) {
        selected = newValue;
        onRefreshState(newValue);
      },
      items: _list.entries
          .map<DropdownMenuItem<String>>(
              (MapEntry<String, String> e) => DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(e.value),
                  ))
          .toList(),
    );
  }
}

class Dropdown2 extends StatefulWidget {
  Map<String, String> list = {"1": "A", "2": "B"};
  Map<String, String> listImage = Map();
  String selected, hint;
  bool isExpanded;
  bool showUnderline = true;
  var textColor;
  var onValueChanged;

  Dropdown2(
      {this.list,
      this.hint = "Select",
      this.isExpanded = false,
      this.showUnderline = true,
      this.onValueChanged,
      this.textColor,
      this.selected});

  @override
  State<StatefulWidget> createState() {
    return _Dropdown2();
  }

  String getSelectedText() {
    if (selected != null) return list[selected];
    return "";
  }

  String getText(key) {
    return list[key];
  }
}

class _Dropdown2 extends State<Dropdown2> {
  String getSelected() {
    return widget.selected;
  }

  @override
  void initState() {
    super.initState();
    if (widget.textColor == null) {
      widget.textColor = Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
//    if (widget.selected == null) widget.selected = "";
    if (widget.list == null ||
        widget.list.length == 0 ||
        widget.list.entries == null ||
        widget.list.entries.length == 0)
      return Container(child: Wgt.text(context, "-"));
    if (widget.selected != null && widget.list[widget.selected] == null)
      widget.selected = null;

    return DropdownButton(
        elevation: 1,
        isDense: false,
        iconSize: 30,
        isExpanded: true,
        // style: TextStyle(color: widget.textColor, fontSize: Wgt.FONT_SIZE_NORMAL),
        underline: widget.showUnderline ? null : Container(),
        hint: Container(
            padding: EdgeInsets.all(0),
            child: Wgt.text(context, widget.hint, color: Colors.grey)),
        // Not necessary for Option 1
        value: widget.selected,
        iconEnabledColor: widget.textColor,
        onChanged: (newValue) {
          widget.selected = newValue;
          setState(() {});

          if (widget.onValueChanged != null) widget.onValueChanged();
        },
        items: widget.list.entries
            .map<DropdownMenuItem<String>>((MapEntry<dynamic, String> e) =>
                DropdownMenuItem<String>(
                    value: e.key,
                    child: Wgt.text(context, e.value,
                        color: e.key == widget.selected
                            ? widget.textColor
                            : Colors.black)))
            .toList());
  }
}

class Loader {
  bool isLoading = true;
  Widget child;
  EdgeInsets margin;
  EdgeInsets padding;
  var bgColor;

  Widget generate({child, EdgeInsets margin, bgColor = Colors.white}) {
    this.child = child;
    this.margin = margin;
    this.padding = padding;
    this.bgColor = bgColor;

    return isLoading ? show() : hide();
  }

  Widget show() {
    // Returns loader
    return Container(
      child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(child: CircularProgressIndicator(), height: 30, width: 30)
          ]),
      padding: padding == null ? EdgeInsets.all(20) : padding,
      margin: margin == null ? EdgeInsets.all(0) : margin,
      color: bgColor,
    );
  }

  Widget hide() {
    return child;
  }
}

class Loader2 extends StatefulWidget {
  bool isLoading = true;
  Widget child;
  EdgeInsets margin;
  EdgeInsets padding;
  double size;
  var bgColor;
  var tintColor;
  _Loader2 details;

  Loader2(
      {this.isLoading = true,
      this.child,
      this.margin,
      this.padding,
      this.tintColor,
      this.bgColor,
      this.size = 30});

  @override
  State<StatefulWidget> createState() {
    details = _Loader2(child: child);
    return details;
  }

  void hide() {
    details.hide();
  }

  void show() {
    details.show();
  }
}

class _Loader2 extends State<Loader2> {
  Widget child;

  _Loader2({this.child});

  void hide() {
    widget.isLoading = false;
    setState(() {});
  }

  void show() {
    widget.isLoading = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoading
        ? Container(
            child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              widget.tintColor ?? Colors.blue)),
                      height: widget.size,
                      width: widget.size)
                ]),
            padding:
                widget.padding == null ? EdgeInsets.all(20) : widget.padding,
            margin: widget.margin == null ? EdgeInsets.all(0) : widget.margin,
            color: widget.bgColor,
          )
        : widget.child;
  }
}

class PullToRefresh {
  RefreshController refreshController;
  var enableRefresh = true;
  var enableLoading = true;

  PullToRefresh() {}

  Future stopRefresh() async {
    await Future.delayed(Duration(milliseconds: 100));
    if (refreshController != null) {
      refreshController.refreshCompleted();
      refreshController.loadComplete();
    }
  }

  Widget generate({child, onRefresh, onLoading}) {
    this.refreshController = RefreshController(initialRefresh: false);

    return SmartRefresher(
        enablePullDown: enableRefresh && onRefresh != null,
        enablePullUp: enableLoading && onLoading != null,
        header: WaterDropMaterialHeader(
            color: Colors.white, backgroundColor: Cons.COLOR_PRIMARY),
        footer: CustomFooter(builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (onLoading == null || !enableLoading) return Container();

          if (mode == LoadStatus.idle) {
            body = Wgt.text(context, "pull up load");
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Wgt.text(context, "Load Failed!Click retry!");
          } else {
            body = Wgt.text(context, "No more Data");
          }
          return Container(height: 40.0, child: Center(child: body));
        }),
        controller: refreshController,
        onRefresh: onRefresh,
        onLoading: onLoading,
        child: child);
  }
}

class RadioButton extends StatefulWidget {
  Map<int, String> map = Map();
  int value = 0;
  var listener;

  RadioButton(this.map, {this.listener, this.value});

  @override
  State<StatefulWidget> createState() {
    var radio = _RadioButton(map, listener);
    return radio;
  }
}

class _RadioButton extends State<RadioButton> {
  Map<int, String> _map = Map();
  var listener;

  _RadioButton(this._map, this.listener);

  List<Widget> row = List();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    row.clear();
    _map.forEach((key, value) {
      row.add(Expanded(
        flex: 1,
        child: Row(children: <Widget>[
          Radio(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: key,
              groupValue: widget.value,
              onChanged: _handleRadioValueChange1),
          Expanded(
            child: InkWell(
                onTap: () {
                  _handleRadioValueChange1(key);
                },
                child: Wgt.text(context, value)),
          )
        ]),
      ));
    });
    return Row(children: row);
  }

  void _handleRadioValueChange1(int value) {
    setState(() {
      widget.value = value;
      if (listener != null) listener();
    });
  }
}

class Popup extends StatefulWidget {
  Widget child;

  Popup(this.child);

  @override
  State<StatefulWidget> createState() => _PopupState(child);

  static show(context, child) {
    showDialog(
      context: context,
      builder: (_) => Popup(child),
    );
  }
}

class _PopupState extends State<Popup> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;
  Widget child;

  _PopupState(this.child);

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.linear);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
          child: Material(
              color: Colors.transparent,
              child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Container(
                      decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      child: Container(
                          padding: const EdgeInsets.all(20.0),
                          child: child))))),
    );
  }
}

class ImagePickerImb extends StatefulWidget {
  String url;
  String hint;
  File imageFile;
  bool isProfile;
  double widthProfile;
  double sizeIconProfile;
  var listener;
  _ImagePickerImb model;

  ImagePickerImb(
      {this.url,
      this.imageFile,
      this.listener,
      this.hint = "Upload Image",
      this.isProfile = false,
      this.widthProfile = 90,
      this.sizeIconProfile = 30});

  @override
  State<StatefulWidget> createState() {
    model = _ImagePickerImb();
    return model;
  }

  Future<String> uploadImage({path}) {
    if (model == null) return null;

    return model.uploadImage(path: path);
  }

  void refresh() {
    if (model != null) model.setState(() {});
  }
}

class _ImagePickerImb extends State<ImagePickerImb> {
  @override
  Widget build(BuildContext context) {
    Widget imgChild;
    Widget remove = Container();

    bool _validURL = widget.url != null && Uri.parse(widget.url).isAbsolute;
    if (!_validURL) widget.url = "";

    if (widget.imageFile != null) {
      if (widget.isProfile) {
        imgChild = Stack(children: <Widget>[
          Center(
              child: Container(
                  width: widget.widthProfile,
                  height: widget.widthProfile,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]),
                      borderRadius: BorderRadius.circular(widget.widthProfile)),
                  child: CircleAvatar(
                      backgroundImage: FileImage(widget.imageFile)))),
        ]);
      } else {
        imgChild = Stack(children: <Widget>[
          Center(
              child: Image.file(widget.imageFile,
                  width: MediaQuery.of(context).size.width - 40)),
        ]);
      }
      remove = Icon(Icons.clear, color: Colors.red);
    } else if (widget.url != null && widget.url != "") {
      if (widget.isProfile) {
        imgChild = Center(
            child: Container(
                child: Wgt.image(
                    url: widget.url,
                    width: widget.widthProfile,
                    height: widget.widthProfile,
                    roundedRadius: widget.widthProfile)));
      } else {
        imgChild = Center(
            child: Wgt.image(
                url: widget.url,
                width: MediaQuery.of(context).size.width - 40));
      }
      remove = Container();
    } else {
      if (!widget.isProfile)
        imgChild = Container(
            padding: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]),
                borderRadius: BorderRadius.circular(5)),
            child: Column(children: <Widget>[
              Icon(Icons.cloud_upload, color: Colors.grey),
              Wgt.text(context, "${widget.hint}", color: Colors.grey),
            ]));
      else
        imgChild = Column(children: <Widget>[
          Container(
              width: widget.widthProfile,
              height: widget.widthProfile,
              padding:
                  EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]),
                  borderRadius: BorderRadius.circular(widget.widthProfile)),
              child: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.cloud_upload,
                      size: widget.sizeIconProfile, color: Colors.grey[400])
                ],
              ))),
          Wgt.spaceTop(10),
          Wgt.text(context, "${widget.hint}", color: Colors.grey)
        ]);
      remove = Container();
    }

    return Stack(children: <Widget>[
      Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            !widget.isProfile
                ? Expanded(
                    child: Material(
                        color: Colors.transparent,
                        child:
                            InkWell(onTap: () => getImage(), child: imgChild)))
                : Container(
                    child: Material(
                        color: Colors.transparent,
                        child:
                            InkWell(onTap: () => getImage(), child: imgChild)),
                  ),
          ]),
      Positioned(
          right: 0,
          child: InkWell(
              child: remove,
              onTap: () {
                widget.imageFile = null;
                setState(() {});
              }))
    ]);
  }

  Future getImage() async {
    Helper.selection(context, selections: {"1": "Gallery", "2": "Camera"},
        success: (key) async {
      var image = await ImagePicker.pickImage(
          source: key == "1" ? ImageSource.gallery : ImageSource.camera,
          maxWidth: MediaQuery.of(context).size.width);

      if (image != null) {
        setState(() {
          widget.imageFile = image;
          if (widget.listener != null) widget.listener(image);
        });
      }
    });
  }

  Future<String> uploadImage({path}) async {
//    if (widget.imageFile == null || path == null) return null;
//    StorageReference ref = FirebaseStorage.instance.ref().child("$path.jpg");
//    StorageUploadTask uploadTask = ref.putFile(widget.imageFile);
//    var hasil = await (await uploadTask.onComplete).ref.getDownloadURL();

//    return hasil;
    return null;
  }
}

class ImbDialog extends StatelessWidget {
//  final String title, description, buttonText;
  String titleText, descText, btnCancelText, btnConfirmText, btnCloseText;
  var titleWidget,
      descWidget,
      confirmListener,
      cancelListener,
      closeListener,
      descAlignment;
  final Image image;
  var spacingTitle, spacingButton;
  var padding = 20.0;
  var avatarRadius = 16.0;
  var imageBgColor = Colors.white;
  bool cancelable = true;

  ImbDialog({
    this.titleText,
    this.descText,
    this.titleWidget,
    this.descWidget,
    this.btnConfirmText,
    this.btnCancelText,
    this.confirmListener,
    this.cancelListener,
    this.btnCloseText,
    this.closeListener,
    this.spacingTitle,
    this.spacingButton,
    this.image,
    this.imageBgColor,
    this.descAlignment,
    this.cancelable,
  });

  static show(context,
      {titleText,
      descText,
      titleWidget,
      descWidget,
      btnConfirmText = "OK",
      btnCancelText = "Cancel",
      confirmListener,
      cancelListener,
      double spacingTitle = 16.0,
      double spacingButton = 16.0,
      btnCloseText = "Close",
      image = "logo.png",
      descAlignment = TextAlign.center,
      imageBgColor = Colors.white,
      closeListener,
      cancelable = true}) {
    showDialog(
        barrierDismissible: cancelable,
        context: context,
        builder: (BuildContext context) => ImbDialog(
//              title: "Success",
//              description:
//                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
//              buttonText: "CLOSE",
              titleText: titleText,
              descText: descText,
              titleWidget: titleWidget,
              descWidget: descWidget,
              btnConfirmText: btnConfirmText,
              btnCancelText: btnCancelText,
              confirmListener: confirmListener,
              cancelListener: cancelListener,
              btnCloseText: btnCloseText,
              closeListener: closeListener,
              spacingTitle: spacingTitle,
              spacingButton: spacingButton,
              imageBgColor: imageBgColor,
              image: Image.asset("assets/$image"),
              descAlignment: descAlignment,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(padding)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
            top: avatarRadius + padding,
            bottom: padding,
            left: padding,
            right: padding),
        margin: EdgeInsets.only(top: avatarRadius),
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[700],
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0))
            ]),
        child:
            Column(mainAxisSize: MainAxisSize.min, // To make the card compact
                children: <Widget>[
              titleWidget != null
                  ? titleWidget
                  : Container(height: 0, width: 0),
              titleText != null && titleText != ""
                  ? Wgt.text(context, titleText,
                      size: Wgt.FONT_SIZE_LARGE,
                      weight: FontWeight.w700,
                      align: TextAlign.center,
                      maxlines: 100)
                  : Container(height: 0, width: 0),
              Wgt.spaceTop(spacingTitle),
              Flexible(
                child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                  descWidget != null
                      ? descWidget
                      : Container(height: 0, width: 0),
                  descText != null && descText != ""
                      ? Wgt.text(context, descText,
                          maxlines: 1000,
                          size: Wgt.FONT_SIZE_NORMAL,
                          align: descAlignment)
                      : Container(height: 0, width: 0),
                ])),
              ),
              Wgt.spaceTop(spacingButton),
              confirmListener == null
                  ? Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      // Expanded(child: Container()),
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (closeListener != null) closeListener();
                          },
                          child: Wgt.textAction(context, btnCloseText,
                              size: Wgt.FONT_SIZE_NORMAL,
                              color: Cons.COLOR_PRIMARY))
                    ])
                  : Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      // Expanded(child: Container()),
                      btnCancelText != ""
                          ? FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                if (cancelListener != null) cancelListener();
                              },
                              child: Wgt.textAction(context, btnCancelText,
                                  size: Wgt.FONT_SIZE_NORMAL,
                                  color: Colors.grey))
                          : Container(),
                      btnConfirmText != ""
                          ? FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                if (confirmListener != null) confirmListener();
                              },
                              child: Wgt.textAction(context, btnConfirmText,
                                  size: Wgt.FONT_SIZE_NORMAL,
                                  color: Cons.COLOR_PRIMARY))
                          : Container(),
                    ])
            ]));
  }
}

class ImbCheckbox extends StatefulWidget {
  bool checked = false;
  String text = "";

  ImbCheckbox({this.text});

  @override
  State<StatefulWidget> createState() {
    return _ImbCheckbox();
  }
}

class _ImbCheckbox extends State<ImbCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Checkbox(
          checkColor: Colors.white,
          activeColor: Cons.COLOR_PRIMARY,
          value: widget.checked,
          onChanged: (bool value) {
            widget.checked = !widget.checked;
            setState(() {});
          }),
      Expanded(
          child: InkWell(
              onTap: () {
                widget.checked = !widget.checked;
                setState(() {});
              },
              child: Wgt.text(context, widget.text, color: Colors.grey[700])))
    ]);
  }
}

class RightMenu extends StatefulWidget {
  List<Choice> choices = List();

  RightMenu({this.choices});

  @override
  State<StatefulWidget> createState() {
    return _RightMenu();
  }
}

class _RightMenu extends State<RightMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Choice>(onSelected: (choice) {
      if (choice.action != null) choice.action();
      setState(() {});
    }, itemBuilder: (BuildContext context) {
      return widget.choices.map((Choice choice) {
        return PopupMenuItem<Choice>(
          value: choice,
          child: Text(choice.title),
        );
      }).toList();
    });
  }
}

class Choice {
  Choice({this.title, this.icon, this.action});

  var action;
  String title;
  IconData icon;
}

class CustomAutocomplete extends StatefulWidget {
  List<String> suggestions = [];

  var style;
  var keyboardType;
  var decoration;
  var controller;

  CustomAutocomplete(
      {this.suggestions,
      this.style,
      this.keyboardType,
      this.decoration,
      this.controller});

  @override
  _CustomAutocompleteState createState() => _CustomAutocompleteState();
}

class _CustomAutocompleteState extends State<CustomAutocomplete> {
  String currentText = "";
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();

  void initState() {}

  SimpleAutoCompleteTextField textField;

  @override
  Widget build(BuildContext context) {
    textField = SimpleAutoCompleteTextField(
      controller: widget.controller,
      key: key,
      style: widget.style,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      suggestions: widget.suggestions,
      textChanged: (text) => currentText = text,
      // clearOnSubmit: false,
      // onFocusChanged: (focus) {},
      textSubmitted: (text) => setState(() {}),
    );
    // print("data : ${widget.suggestions}");
    return textField;
  }
}

class ImbWebview extends StatefulWidget {
  String url;
  String title;

  ImbWebview({this.url, this.title = ""});

  @override
  State<StatefulWidget> createState() {
    return _ImbWebview();
  }
}

class _ImbWebview extends State<ImbWebview> {
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget.url,
      appBar: Wgt.appbar(context, name: widget.title),
      withZoom: true,
      withLocalStorage: true,
    );
  }
}

typedef ListenerValidator = String Function(String);

class CustomInput extends StatefulWidget {
  String hint = "";
  var displayTopHint = true;
  var displayLeftHint = false;
  Color hintColor = Colors.grey;
  String textvalue;
  String imageName = "";
  TextInputType type = TextInputType.text;
  var isPassword = false;
  var icon;
  var extraText;
  var displayUnderline = true;
  var color = Colors.black;
  var enabled = true;
  var bordered = false;
  var maxlines = 1;
  var borderColor;
  double borderRadius = 5.0;
  double borderPaddingX = 10.0;
  double borderPaddingY = 7.0;
  TextEditingController controller;
  ListenerValidator validator;
  var errText;
  var errStyle;
  var errBorder;
  bool polosan = false;
  bool visible = false;
  bool formatCurrency = false;
  TextAlign textAlign;
  CustomInput({
    this.hint = "",
    this.displayTopHint = true,
    this.displayLeftHint = false,
    this.hintColor = Colors.grey,
    this.textvalue,
    this.imageName = "",
    this.type = TextInputType.text,
    this.isPassword = false,
    this.icon,
    this.extraText,
    this.displayUnderline = true,
    this.color = Colors.black,
    this.enabled = true,
    this.bordered = false,
    this.maxlines = 1,
    this.borderColor,
    this.borderRadius = 5.0,
    this.borderPaddingX = 20.0,
    this.borderPaddingY = 20.0,
    this.controller,
    this.validator,
    this.errText,
    this.errStyle,
    this.errBorder,
    this.polosan = false,
    this.formatCurrency = false,
    this.textAlign = TextAlign.left,
  }) {
    this.visible = this.isPassword;
  }
  @override
  _CustomInputState createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller != null && widget.validator != null) {
      widget.controller.addListener(() {
        String err = widget.validator(widget.controller.text);
        if (err != null && err != "")
          widget.errText = err;
        else
          widget.errText = null;
        setState(() {});
      });
    }

    // Define border
    var border;
    if (widget.bordered && !widget.displayUnderline) {
      if (widget.borderColor == null) widget.borderColor = Colors.grey[400];
      border = OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColor));
      widget.displayTopHint = false;
      widget.displayUnderline = false;
    } else if (widget.displayUnderline) {
      widget.borderPaddingX = 5;
      widget.borderPaddingY = 0;
    } else {
      border = UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(widget.borderRadius));
      widget.borderPaddingX = 0;
      widget.borderPaddingY = 0;
    }

    // Define error style
    if (widget.hint == null) widget.hint = "";

    if (widget.errStyle == null) {
      widget.errStyle = TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: Wgt.FONT_SIZE_NORMAL);
    }

    if (widget.errBorder == null) {
      if (widget.bordered && !widget.displayUnderline) {
        widget.errBorder = OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(widget.borderRadius));
      } else if (widget.displayUnderline) {
        widget.errBorder = UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(widget.borderRadius));
      }
    }

    // Show password
    Widget iconPassword;
    if (widget.isPassword) {
      if (!widget.visible)
        iconPassword = InkWell(
            onTap: () {
              widget.visible = !widget.visible;
              setState(() {});
            },
            child: Icon(Icons.visibility));
      else
        iconPassword = InkWell(
            onTap: () {
              widget.visible = !widget.visible;
              setState(() {});
            },
            child: Icon(Icons.visibility_off));
    }

    return Container(
        child: TextField(
      inputFormatters: [
        if (widget.formatCurrency)
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        if (widget.formatCurrency) CurrencyInputFormatter(),
      ],
      maxLines: widget.maxlines,
      obscureText: widget.visible,
      keyboardType: widget.type,
      enabled: widget.enabled,
      controller: widget.controller,
      textAlign: widget.textAlign,
      minLines: 1,
      // onTap: () {
      //   // Enable textfield buat bisa pindah cursor ke blkg kalo dia field nya password
      // },
      style: TextStyle(color: widget.color, fontSize: Wgt.FONT_SIZE_NORMAL),
      decoration: !widget.polosan
          ? InputDecoration(
              labelText: widget.hint,
              errorText: widget.errText,
              errorBorder: widget.errBorder,
              errorStyle: widget.errStyle,
              suffixIcon: iconPassword != null ? iconPassword : null,
              contentPadding: EdgeInsets.only(
                  left: widget.borderPaddingX,
                  right: widget.borderPaddingX,
                  bottom: widget.polosan
                      ? 0
                      : widget.displayUnderline
                          ? 5
                          : widget.borderPaddingY,
                  top: widget.polosan ? 0 : widget.borderPaddingY),
              border: widget.errText == null ? border : widget.errBorder,
              // hintText: widget.hint,
              hintStyle: TextStyle(color: Cons.COLOR_TEXT_HINT))
          : InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: widget.hint,
              border: OutlineInputBorder(borderSide: BorderSide.none)),
      autofocus: false,
    ));
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text);

    final formatter =
        NumberFormat.simpleCurrency(locale: "id", decimalDigits: 0);

    String newText = formatter.format(value / 1);

    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }
}
