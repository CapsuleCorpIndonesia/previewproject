class BLogPesanan {
  var local_id;
  var timestamp;

  BLogPesanan.fromMap(Map map) {
    this.local_id = map["local_id"];
    this.timestamp = map["timestamp"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map["local_id"] = this.local_id;
    map["timestamp"] = this.timestamp;
    return map;
  }
}
