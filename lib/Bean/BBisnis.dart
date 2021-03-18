import 'package:pawoon/Bean/BBisnisSub.dart';

class BBisnis {
  var id;
  var name;
  var alias;
  List<BBisnisSub> arrSub = List();

  BBisnis.fromJson(Map json)
      : id = json["id"],
        name = json["name"],
        alias = json["alias"] {
    if (json["sub_business_types"] != null &&
        json["sub_business_types"]["data"] != null) {
      arrSub.clear();
      for (var item in json["sub_business_types"]["data"]) {
        arrSub.add(BBisnisSub.fromJson(item));
      }
    }
  }
}
