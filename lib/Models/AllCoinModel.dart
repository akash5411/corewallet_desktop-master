import 'dart:convert';

import 'package:corewallet_desktop/Values/utils.dart';

AllCoinModel allCoinModelFromJson(String str) => AllCoinModel.fromJson(json.decode(str));

class AllCoinModel {
  AllCoinModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.slug,
    required this.numMarketPairs,
    required this.dateAdded,
    required this.tags,
    required this.maxSupply,
    required this.circulatingSupply,
    required this.totalSupply,
    required this.cmcRank,
    required this.selfReportedCirculatingSupply,
    required this.selfReportedMarketCap,
    required this.tvlRatio,
    required this.lastUpdated,
    required this.quote,
  });

  int id;
  String name;
  String symbol;
  String slug;
  int numMarketPairs;
  DateTime dateAdded;
  List<String> tags;
  int maxSupply;
  double circulatingSupply;
  double totalSupply;
  int cmcRank;
  double selfReportedCirculatingSupply;
  double selfReportedMarketCap;
  double tvlRatio;
  DateTime lastUpdated;
  Quote quote;

  factory AllCoinModel.fromJson(Map<String, dynamic> json) => AllCoinModel(
    id: json["id"],
    name: json["name"],
    symbol: json["symbol"],
    slug: json["slug"],
    numMarketPairs: json["num_market_pairs"],
    dateAdded: DateTime.parse(json["date_added"]),
    tags: List<String>.from(json["tags"].map((x) => x)),
    maxSupply: json["max_supply"] == null ? 0 : json["max_supply"],
    circulatingSupply: json["circulating_supply"].toDouble(),
    totalSupply: json["total_supply"].toDouble(),
    cmcRank: json["cmc_rank"],
    selfReportedCirculatingSupply: json["self_reported_circulating_supply"] == null ? 0.0 : json["self_reported_circulating_supply"].toDouble(),
    selfReportedMarketCap: json["self_reported_market_cap"] == null ? 0.0 : json["self_reported_market_cap"].toDouble(),
    tvlRatio: json["tvl_ratio"] == null ? 0.0 : json["tvl_ratio"].toDouble(),
    lastUpdated: DateTime.parse(json["last_updated"]),
    quote: Quote.fromJson(json["quote"]),
  );

}

class Platform {
  Platform({
    required this.id,
    required this.name,
    required this.symbol,
    required this.slug,
    required this.tokenAddress,
  });

  int id;
  String name;
  Symbol symbol;
  String slug;
  String tokenAddress;

  factory Platform.fromJson(Map<String, dynamic> json) => Platform(
    id: json["id"],
    name: json["name"],
    symbol: json["symbol"],
    slug: json["slug"],
    tokenAddress: json["token_address"],
  );

}


class Quote {
  Quote({
    required this.usd,
  });

  Usd usd;

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
    usd: Usd.fromJson(json["${Utils.convertType}"]),
  );
}

class Usd {
  Usd({
    required this.price,
    required this.volume24H,
    required this.volumeChange24H,
    required this.percentChange1H,
    required this.percentChange24H,
    required this.percentChange7D,
    required this.percentChange30D,
    required this.percentChange60D,
    required this.percentChange90D,
    required this.marketCap,
    required this.marketCapDominance,
    required this.fullyDilutedMarketCap,
    required this.lastUpdated,
  });

  double price;
  double volume24H;
  double volumeChange24H;
  double percentChange1H;
  double percentChange24H;
  double percentChange7D;
  double percentChange30D;
  double percentChange60D;
  double percentChange90D;
  double marketCap;
  double marketCapDominance;
  double fullyDilutedMarketCap;
  DateTime lastUpdated;

  factory Usd.fromJson(Map<String, dynamic> json) => Usd(
    price: json["price"].toDouble(),
    volume24H: json["volume_24h"].toDouble(),
    volumeChange24H: json["volume_change_24h"].toDouble(),
    percentChange1H: json["percent_change_1h"].toDouble(),
    percentChange24H: json["percent_change_24h"].toDouble(),
    percentChange7D: json["percent_change_7d"].toDouble(),
    percentChange30D: json["percent_change_30d"].toDouble(),
    percentChange60D: json["percent_change_60d"].toDouble(),
    percentChange90D: json["percent_change_90d"].toDouble(),
    marketCap: json["market_cap"].toDouble(),
    marketCapDominance: json["market_cap_dominance"].toDouble(),
    fullyDilutedMarketCap: json["fully_diluted_market_cap"].toDouble(),
    lastUpdated: DateTime.parse(json["last_updated"]),
  );

}

