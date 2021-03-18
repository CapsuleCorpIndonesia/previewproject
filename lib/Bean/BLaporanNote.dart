class BLaporanNote{
  var title;
  var amount;
  BLaporanNote.fromJson(Map json):
  title = json["title"],
  amount = json["amount"];

  BLaporanNote.fromJson2(Map json):
  title = json["name"],
  amount = json["amount"];
}