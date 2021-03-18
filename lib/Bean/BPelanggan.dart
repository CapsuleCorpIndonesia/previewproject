class BPelanggan {
  var id;
  var name;
  var member_id;
  var gender;
  var birth_date;
  var email;
  var phone;
  var address;
  var postal_code;
  var note;
  var order_amount;
  var order_count;
  var first_order;
  var loyalty_user_id;
  var cityName;
  var genderType;
  var isActive;
  var registeredTimestamp;
  var serverId;
  var userId;
  var point;

  BPelanggan() {
    name = "";
    email = "";
    phone = "";
  }

  BPelanggan.clone(BPelanggan item) {
    if (item == null) return;
    this.id = item.id;
    this.name = item.name;
    this.member_id = item.member_id;
    this.gender = item.gender;
    this.birth_date = item.birth_date;
    this.email = item.email;
    this.phone = item.phone;
    this.address = item.address;
    this.postal_code = item.postal_code;
    this.note = item.note;
    this.order_amount = item.order_amount;
    this.order_count = item.order_count;
    this.first_order = item.first_order;
    this.loyalty_user_id = item.loyalty_user_id;
    this.cityName = item.cityName;
    this.genderType = item.genderType;
    this.isActive = item.isActive;
    this.registeredTimestamp = item.registeredTimestamp;
    this.serverId = item.serverId;
    this.userId = item.userId;
    this.point = item.point;
  }

  BPelanggan.fromJson(Map json)
      : serverId = json["id"],
        name = json["name"],
        member_id = json["member_id"],
        gender = json["gender"],
        birth_date = json["birth_date"],
        email = json["email"],
        phone = json["phone"],
        address = json["address"],
        postal_code = json["postal_code"],
        note = json["note"],
        order_amount = json["order_amount"],
        order_count = json["order_count"],
        first_order = json["first_order"],
        loyalty_user_id = json["loyalty_user_id"],
        point = json["point"],
        cityName = json["cityName"],
        genderType = json["genderType"],
        isActive = json["isActive"],
        registeredTimestamp = json["registeredTimestamp"],
        // serverId = json["serverId"],
        userId = json["userId"];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map["id"] = id;
    map["name"] = name;
    map["member_id"] = member_id;
    map["gender"] = gender;
    map["birth_date"] = birth_date;
    map["email"] = email;
    map["phone"] = phone;
    map["address"] = address;
    map["postal_code"] = postal_code;
    map["note"] = note;
    map["order_amount"] = order_amount;
    map["order_count"] = order_count;
    map["first_order"] = first_order;
    map["loyalty_user_id"] = loyalty_user_id;
    map["point"] = point;
    map["cityName"] = cityName;
    map["genderType"] = genderType;
    map["isActive"] = isActive;
    map["registeredTimestamp"] = registeredTimestamp;
    map["serverId"] = serverId;
    map["userId"] = userId;
    return map;
  }

  BPelanggan.fromMap(Map map) {
    id = map["id"];
    name = map["name"];
    member_id = map["member_id"];
    gender = map["gender"];
    birth_date = map["birth_date"];
    email = map["email"];
    phone = map["phone"];
    address = map["address"];
    postal_code = map["postal_code"];
    note = map["note"];
    order_amount = map["order_amount"];
    order_count = map["order_count"];
    first_order = map["first_order"];
    loyalty_user_id = map["loyalty_user_id"];
    point = map["point"];
    cityName = map["cityName"];
    genderType = map["genderType"];
    isActive = map["isActive"];
    registeredTimestamp = map["registeredTimestamp"];
    serverId = map["serverId"];
    userId = map["userId"];
  }

  Map<String, String> toJson() {
    Map<String, String> map = Map();
    map["address"] = "${this.address ?? ""}";
    map["birth_date"] = "${this.birth_date ?? ""}";
    map["email"] = "${this.email ?? ""}";
    map["gender"] = "${this.gender ?? ""}";
    map["member_id"] = "${this.member_id ?? ""}";
    map["name"] = "${this.name ?? ""}";
    map["note"] = "${this.note ?? ""}";
    map["phone"] = "${this.phone ?? ""}";
    map["point"] = "${this.point ?? ""}";
    map["postal_code"] = "${this.postal_code ?? ""}";
    map["cityName"] = "${this.cityName ?? ""}";
    map["genderType"] = "${this.genderType ?? ""}";
    map["isActive"] = "${this.isActive ?? ""}";
    map["registeredTimestamp"] = "${this.registeredTimestamp ?? ""}";
    map["serverId"] = "${this.serverId ?? ""}";
    map["userId"] = "${this.userId ?? ""}";
    return map;
  }
}
