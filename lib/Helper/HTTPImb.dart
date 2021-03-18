import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:pawoon/Views/Base.dart';

import 'Helper.dart';
import 'UserManager.dart';

typedef ListenerSuccess = void Function(dynamic);
typedef ListenerError = void Function(String);

class HTTPImb {
  Map<String, String> header;
  var postData;
  Map<String, String> postParams;
  Map<String, dynamic> postParamsForm;
  String url;
  ListenerSuccess listenerSuccess;
  ListenerError listenerError;
  bool displayLoader;
  var context;
  bool printAll;
  bool methodPut = false;
  bool popupCheckInternet = true;
  bool closeLoader = true;

  HTTPImb(this.context,
      {this.url,
      this.header,
      this.postParams,
      this.listenerSuccess,
      this.listenerError,
      this.postParamsForm,
      this.postData,
      this.displayLoader = false,
      this.methodPut = false,
      this.popupCheckInternet = true,
      this.printAll = false,
      this.closeLoader = true}) {}

  Future execute() async {
    // printAll = true;
    // if (!await Helper.validateInternet(context, popup: popupCheckInternet)) {
    // Timer(Duration(seconds: 5), () {
    //   print("masuk");
    // Helper.hideProgress(context);
    // });
    // return;
    // } else {
    if (printAll) {
      print("Url : $url");
      print("Header : $header");
      print("Post : $postParams");
      print("PostData : $postData");
    }
    if (displayLoader) Helper.showProgress(context);

    if ((postParams != null && postParams.isNotEmpty) ||
        (postData != null && postData.isNotEmpty))
      return executePost().then((json) {
        if (this.closeLoader) Helper.hideProgress(context);
        if (printAll) print(json);
        if (json != null && json["message"] != null) {
          // Error
          if (listenerError != null)
            listenerError(json["message"]);
          else
            Helper.toastError(context, json["message"]);
        } else if (json != null && json["error"] != null) {
          if (json["error"] == "Unauthorized") {
            UserManager.saveBool(UserManager.IS_LOGGED_IN, false);

            Helper.closePage(context);
            Helper.openPageNoNav(context, Base());
            Helper.toastError(context, "Unauthorized");
            return;
          }
          // Error
          if (listenerError != null) {
            if (json["error"].runtimeType == String)
              listenerError(json["error"] ?? "");
            else if (json["error"]["message"] != null)
              listenerError(json["error"]["message"] ?? "");
          } else
            try {
              Helper.toastError(context,
                  json["error"]["message"].toString() ?? json["error"] ?? "Error");
            } catch (e) {
              print(json);
              Helper.toastError(context, "$json");
            }
        } else if (json != null) {
          // Success
          if (listenerSuccess != null) listenerSuccess(json);
        }
      });
    else
      return executeGet().then((json) {
        if (this.closeLoader) Helper.hideProgress(context);
        if (printAll) print(json);
        if (json != null && json["message"] != null) {
          // Error
          if (listenerError != null) {
            listenerError(json["message"] ?? json["error"]);
          } else {
            if (json["error"] == "Unauthorized") {
              UserManager.saveBool(UserManager.IS_LOGGED_IN, false);

              Helper.closePage(context);
              Helper.openPageNoNav(context, Base());
              Helper.toastError(context, "Unauthorized");
              return;
            }

            Helper.toastError(context, json["message"] ?? json["error"]);
          }
        } else if (json != null) {
          // Success
          if (listenerSuccess != null) listenerSuccess(json);
        }
      });
    // }
  }

  Future executeGet() async {
    final response = await http.get(url, headers: header);
    if (printAll) print(response.body);
    if (printAll) print("respond : ${response.body}");

    try {
      return json.decode(response.body);
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future executePost() async {
    var data;
    if (postParams != null)
      data = postParams;
    else if (postData != null) data = postData;
    var response;
    if (methodPut) {
      response = await http.put(url, headers: header, body: data);
      if (printAll) print(response.body);
      if (printAll) print("respond : ${response.body}");
      if (printAll) print(response.statusCode);
    } else {
      response = await http.post(url,
          headers: header, body: data, encoding: Encoding.getByName("utf-8"));
      if (printAll) print(response.body);
      if (printAll) print("respond : ${response.body}");
      if (printAll) print(response.statusCode);
    }

    if (response != null && response.statusCode == "204") {
      return {"message": "success"};
    }

    try {
      return json.decode(response.body);
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<void> test({data, url}) async {
    // var response = await post(url,
    //     headers: {
    //       "Accept": "application/json",
    //       "Content-Type": "application/x-www-form-urlencoded"
    //     },
    //     body: json.encode(data),
    //     encoding: Encoding.getByName("utf-8"));
    // print(response);
    Dio()
        .post("$url",
            data: {"id": 5},
            options: Options(contentType: Headers.formUrlEncodedContentType))
        .then((value) => print(value));

    // Dio()
    //     .post(url,
    //         data: data,
    //         options:
    //             dio.Options(contentType: Headers.formUrlEncodedContentType))
    //     .then((value) => print(value));
  }

  Future executeDelete() async {
    if (printAll) print(url);
    if (printAll) print(header);
    if (printAll) print("DELETE");
    final response = await http.delete(url, headers: header);
    if (printAll) print(response.body);
    if (printAll) print("respond : ${response.body}");

    try {
      return json.decode(response.body);
    } catch (e) {
      return "$response";
    }
  }

  Future executeForm() async {
    var response;
    if (printAll) print(postParamsForm);
    response = await http.post(url, headers: header, body: postParamsForm);
    if (printAll) print(response.body);

    if (response != null && response.statusCode == "204") {
      return {"message": "success"};
    }

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // If that response was not OK, throw an error.
      if (printAll) print("respond : ${response.body}");
      try {
        return json.decode(response.body);
      } catch (e) {
        return "$response";
      }
    }
  }

  // Future<HttpClientResponse> foo({jsonMap}) async {

  //   String jsonString = json.encode(jsonMap); // encode map to json
  //   String paramName = 'param'; // give the post param a name
  //   String formBody = paramName + '=' + Uri.encodeQueryComponent(jsonString);
  //   List<int> bodyBytes = utf8.encode(formBody); // utf8 encode
  //   HttpClientRequest request =
  //       await HttpClient..post(url);
  //   // it's polite to send the body length to the server
  //   request.headers.set('Content-Length', bodyBytes.length.toString());
  //   // todo add other headers here
  //   request.add(bodyBytes);
  //   return await request.close();
  // }

  Future<String> apiRequest() async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    if (header != null && header.isNotEmpty) {
      header.forEach((key, value) {
        request.headers.set("$key", "$value");
      });
    }
    // request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(postParams)));

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();

    if (response.statusCode == 200) {
      return json.decode(reply);
    } else {
      if (printAll) print("respond : ${reply}");
      return reply;
    }
  }
}

abstract class ListenerHTTP {
  void onSuccess(json);

  void onFail(err);
}
