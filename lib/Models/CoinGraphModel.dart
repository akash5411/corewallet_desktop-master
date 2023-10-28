import 'package:corewallet_desktop/Values/utils.dart';
import 'dart:convert';

CoinGraphModel coinGraphModelFromJson(String str) => CoinGraphModel.fromJson(json.decode(str));

String coinGraphModelToJson(CoinGraphModel data) => json.encode(data.toJson());

class CoinGraphModel {
  CoinGraphModel({
    required this.quotes,
    required this.id,
    required this.name,
    required this.symbol,
    required this.isActive,
    required this.isFiat,
  });

  List<QuoteElement> quotes;
  int id;
  String name;
  String symbol;
  int isActive;
  int isFiat;

  factory CoinGraphModel.fromJson(Map<String, dynamic> json) => CoinGraphModel(
    quotes: List<QuoteElement>.from(json["quotes"].map((x) => QuoteElement.fromJson(x))),
    id: json["id"],
    name: json["name"],
    symbol: json["symbol"],
    isActive: json["is_active"],
    isFiat: json["is_fiat"],
  );

  Map<String, dynamic> toJson() => {
    "quotes": List<dynamic>.from(quotes.map((x) => x.toJson())),
    "id": id,
    "name": name,
    "symbol": symbol,
    "is_active": isActive,
    "is_fiat": isFiat,
  };
}

class QuoteElement {
  QuoteElement({
    required this.timestamp,
    required this.quote,
  });

  DateTime timestamp;
  QuoteQuote quote;

  factory QuoteElement.fromJson(Map<String, dynamic> json) => QuoteElement(
    timestamp: DateTime.parse(json["timestamp"]),
    quote: QuoteQuote.fromJson(json["quote"]),
  );

  Map<String, dynamic> toJson() => {
    "timestamp": timestamp.toIso8601String(),
    "quote": quote.toJson(),
  };
}

class QuoteQuote {
  QuoteQuote({
    required this.usd,
  });

  Usd usd;

  factory QuoteQuote.fromJson(Map<String, dynamic> json) => QuoteQuote(
    usd: Usd.fromJson(json["${Utils.convertType}"]),
  );

  Map<String, dynamic> toJson() => {
    "USD": usd.toJson(),
  };
}

class Usd {
  Usd({
    required this.price,
    required this.volume24H,
    required this.marketCap,
    required this.totalSupply,
    required this.circulatingSupply,
    required this.timestamp,
  });

  double price;
  double volume24H;
  double marketCap;
  double totalSupply;
  double circulatingSupply;
  DateTime timestamp;

  factory Usd.fromJson(Map<String, dynamic> json) => Usd(
    price: json["price"].toDouble(),
    volume24H: json["volume_24h"].toDouble(),
    marketCap: json["market_cap"].toDouble(),
    totalSupply: json["total_supply"].toDouble(),
    circulatingSupply: json["circulating_supply"].toDouble(),
    timestamp: DateTime.parse(json["timestamp"]),
  );

  Map<String, dynamic> toJson() => {
    "price": price,
    "volume_24h": volume24H,
    "market_cap": marketCap,
    "total_supply": totalSupply,
    "circulating_supply": circulatingSupply,
    "timestamp": timestamp.toIso8601String(),
  };
}
