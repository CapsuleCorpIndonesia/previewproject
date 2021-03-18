class BBisnisSub{
  var id;
  var name;
  var alias;
  BBisnisSub.fromJson(Map json):
  id = json["id"],
  name = json["name"],
  alias = json["alias"];
}