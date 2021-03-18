import 'package:pawoon/Bean/BModifierData.dart';

class BModifier {
  var id;
  var name;
  var is_one_option;
  var has_recipe;
  List<BModifierData> modifiers = List();

  BModifier.clone(BModifier mod) {
    this.id = mod.id;
    this.name = mod.name;
    this.is_one_option = mod.is_one_option;
    this.has_recipe = mod.has_recipe;

    this.modifiers.clear();
    for (BModifierData data in mod.modifiers) {
      this.modifiers.add(BModifierData.clone(data));
    }
  }

  BModifier.fromJson(Map json)
      : id = json["id"],
        name = json["name"],
        is_one_option = json["is_one_option"],
        has_recipe = json["has_recipe"] {
    if (json["modifiers"] != null && json["modifiers"]["data"] != null) {
      modifiers.clear();
      for (var item in json["modifiers"]["data"]) {
        modifiers.add(BModifierData.fromJson(item));
      }
    }
  }

/* -------------------------------------------------------------------------- */
/*                                     DB                                     */
/* -------------------------------------------------------------------------- */
  Map toMap() {
    Map map = Map();
    map['id'] = id;
    map['name'] = name;
    map['is_one_option'] = is_one_option;
    map['has_recipe'] = has_recipe;
    List<Map> arr = List();
    if (modifiers != null)
      for (BModifierData data in modifiers) {
        arr.add(data.toMap());
      }
    map['modifiers'] = arr;
    return map;
  }

  BModifier.fromMap(Map map) {
    id = map['id'];
    name = map['name'];
    is_one_option = map['is_one_option'];
    has_recipe = map['has_recipe'];

    if (map["modifiers"] != null) {
      for (Map data in map["modifiers"]) {
        modifiers.add(BModifierData.fromMap(data));
      }
    }
  }
}
