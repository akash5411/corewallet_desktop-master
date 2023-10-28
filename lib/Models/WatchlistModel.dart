import 'dart:convert';

List<WatchListModel> productFromJson(String str) =>
    List<WatchListModel>.from(json.decode(str).map((x) => WatchListModel.fromJson(x)));

class WatchListModel {
  WatchListModel({
    required this.marketId,
    required this.symbol,
    required this.name,
    required this.price,
    required this.volume,
    required this.marketCap,
    required this.percent_change_24h
  });

  String marketId;
  String symbol;
  String name;
  String marketCap;
  String volume;
  double percent_change_24h;
  double price;

  factory WatchListModel.fromJson(Map<String, dynamic> json) => WatchListModel(
    marketId: json["market_id"],
    symbol: json["symbol"],
    marketCap: json["marketCap"],
    volume: json["volume"],
    price: json["price"],
    percent_change_24h: json["percent_change_24h"],
    name: json["name"],
  );

}
