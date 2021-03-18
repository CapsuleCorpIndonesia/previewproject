class BLaporanKas {
  var id;
  var device_timestamp;
  BLaporanKas.fromJson(Map json)
      : id = json["id"],
        device_timestamp = json["device_timestamp"];
}
