class FiatModel {
  bool status;
  List<Data> data;

  FiatModel({
    required this.status,
    required this.data,
  });

  factory FiatModel.fromJson(Map<String, dynamic> json) => FiatModel(
    status: json["status"],
    data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Data {
  int id;
  String name;
  String sign;
  String symbol;

  Data({
    required this.id,
    required this.name,
    required this.sign,
    required this.symbol,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    sign: json["sign"] ?? "",
    symbol: json["symbol"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "sign": sign,
    "symbol": symbol,
  };
}
