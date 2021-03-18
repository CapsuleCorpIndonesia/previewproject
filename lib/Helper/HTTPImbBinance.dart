import 'dart:convert';

import 'package:http/http.dart' as http;

import 'HTTPImb.dart';
import 'Helper.dart';

class HTTPImbBinance {
  Map<String, String> header;
  var postParams;
  String url;
  ListenerSuccess listenerSuccess;
  ListenerError listenerError;
  bool displayLoader;
  var context;
  bool printAll;

  HTTPImbBinance(this.context,
      {this.url, this.header, this.postParams, this.listenerSuccess, this.listenerError, this.displayLoader = false, this.printAll = false});

  Future execute() {
    if (printAll) {
      print("Url : $url");
      print("Header : $header");
      print("Post : $postParams");
    }
    if (displayLoader) Helper.showProgress(context);

    if (postParams != null && postParams.isNotEmpty)
      return executePost().then((json) {
        Helper.hideProgress(context);
        if (printAll) print(json);
        if (json != null) {
          // Success
          if (listenerSuccess != null) listenerSuccess(json);
        } else {
          // Error
          if (listenerError != null) {
            if (json["error_message"] != "")
              listenerError(json["error_message"]);
            else if (json["error_message"] != "")
              listenerError(json["status_message"]);
            else if (json["status"] != "")
              listenerError(json["status"]);
            else
              listenerError("Error");
          } else {
            var errMessage;
            if (json["error_message"].runtimeType == String && json["error_message"] != "")
              errMessage = json["error_message"];
            else if (json["status_message"].runtimeType == String && json["status_message"] != "")
              errMessage = json["status_message"];
            else if (json["status"].runtimeType == String && json["status"] != "") errMessage = json["status"];

            if (errMessage == null) {
              List<dynamic> errList;
              errList = json["error_message"];
              if (errList == null) errList = json["status_message"];

//              for (var err in errList) {
              Helper.toastError(context, errList.toString());
//                return;
//              }
            } else {
              Helper.toastError(context, errMessage);
            }
          }
        }
      });
    else
      return executeGet().then((json) {
        Helper.hideProgress(context);
        if (printAll) print(json);
        if (json != null) {
          // Success
          if (listenerSuccess != null) listenerSuccess(json);
        } else {
          // Error
          if (listenerError != null) {
            if (json["error_message"].runtimeType == String && json["error_message"] != "")
              listenerError(json["error_message"]);
            else if (json["status_message"].runtimeType == String && json["status_message"] != "")
              listenerError(json["status_message"]);
            else if (json["status"].runtimeType == String && json["status"] != "")
              listenerError(json["status"]);
            else
              listenerError("Error");
          } else {
            var errMessage;
            if (json["error_message"].runtimeType == String && json["error_message"] != "")
              errMessage = json["error_message"];
            else if (json["status_message"].runtimeType == String && json["status_message"] != "")
              errMessage = json["status_message"];
            else if (json["status"].runtimeType == String && json["status"] != "") errMessage = json["status"];

            if (errMessage == null) {
              List<dynamic> errList;
              errList = json["error_message"];
              if (errList == null) errList = json["status_message"];

              for (var err in errList) {
                Helper.toastError(context, err);
                return;
              }
            } else {
              Helper.toastError(context, errMessage);
            }
          }
        }
      });
  }

  Future executeGet() async {
    final response = await http.get(url, headers: header);
    if (printAll) print(response.body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // If that response was not OK, throw an error.
      print(response.body);
      throw Exception('Failed to load post');
    }
  }

  Future executePost() async {
    final response = await http.post(url, headers: header, body: postParams);
    if (printAll) print(response.body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // If that response was not OK, throw an error.
      if (printAll) print("respond : ${response.body}");
      throw Exception('Failed to load post');
    }
  }
}

abstract class ListenerHTTP {
  void onSuccess(json);

  void onFail(err);
}
