class BCategory{
  var id;
  var name;
  BCategory.kosongan(){
    id = "kosongan";
    name = "Tanpa Kategori";
  }
  BCategory.fromJson(Map json){
    id = json["id"];
    name = json["name"];
  }

  BCategory.fromMap(Map map){
    id = map["id"];
    name = map["name"];
  }

  Map toMap(){
    Map map = Map();
    map["id"] = id;
    map["name"] = name;

    return map;
  }
}