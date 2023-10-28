// To parse this JSON data, do
//
//     final searchTokenModel = searchTokenModelFromJson(jsonString);

import 'dart:convert';

SearchTokenModel searchTokenModelFromJson(String str) => SearchTokenModel.fromJson(json.decode(str));

String searchTokenModelToJson(SearchTokenModel data) => json.encode(data.toJson());

class SearchTokenModel {
  SearchTokenModel({
    required this.status,
    required this.searchtokenList,
  });

  bool status;
  List<SearchtokenList> searchtokenList;

  factory SearchTokenModel.fromJson(Map<String, dynamic> json) => SearchTokenModel(
    status: json["status"],
    searchtokenList: List<SearchtokenList>.from(json["SearchtokenList"].map((x) => SearchtokenList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "SearchtokenList": List<dynamic>.from(searchtokenList.map((x) => x.toJson())),
  };
}

class SearchtokenList {
  SearchtokenList({
    required this.id,
    required this.marketId,
    required this.networkId,
    required this.networkName,
    required this.name,
    required this.type,
    required this.address,
    required this.symbol,
    required this.decimals,
    required this.logo,
  });

  int id;
  int marketId;
  int networkId;
  String networkName;
  String name;
  String type;
  String address;
  String symbol;
  int decimals;
  String logo;

  factory SearchtokenList.fromJson(Map<String, dynamic> json) => SearchtokenList(
    id: json["id"],
    marketId: json["market_id"],
    networkId: json["network_id"],
    networkName: json["network_name"],
    name: json["name"],
    type: json["type"],
    address: json["address"],
    symbol: json["symbol"],
    decimals: json["decimals"],
    logo: json["logo"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "market_id": marketId,
    "network_id": networkId,
    "network_name": networkName,
    "name": name,
    "type": type,
    "address": address,
    "symbol": symbol,
    "decimals": decimals,
    "logo": logo,
  };
}

