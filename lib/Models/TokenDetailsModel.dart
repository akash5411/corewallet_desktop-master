// To parse this JSON data, do
//
//     final tokenDetailsChart = tokenDetailsChartFromJson(jsonString);

import 'dart:convert';

TokenDetailsChart tokenDetailsChartFromJson(String str) => TokenDetailsChart.fromJson(json.decode(str));

String tokenDetailsChartToJson(TokenDetailsChart data) => json.encode(data.toJson());

class TokenDetailsChart {
  TokenDetailsChart({
    required this.status,
    required this.tokenDataList,
  });

  bool status;
  List<TokenDataList> tokenDataList;

  factory TokenDetailsChart.fromJson(Map<String, dynamic> json) => TokenDetailsChart(
    status: json["status"],
    tokenDataList: List<TokenDataList>.from(json["tokenDataList"].map((x) => TokenDataList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "tokenDataList": List<dynamic>.from(tokenDataList.map((x) => x.toJson())),
  };
}

class TokenDataList {
  TokenDataList({
    required this.pair,
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.exchangeName,
    required this.exchangeAddress,
    required this.value,
  });

  String pair;
  String baseCurrency;
  String quoteCurrency;
  String exchangeName;
  String exchangeAddress;
  String value;

  factory TokenDataList.fromJson(Map<String, dynamic> json) => TokenDataList(
    pair: json["pair"],
    baseCurrency: json["baseCurrency"],
    quoteCurrency: json["quoteCurrency"],
    exchangeName: json["exchangeName"],
    exchangeAddress: json["exchangeAddress"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "pair": pair,
    "baseCurrency": baseCurrency,
    "quoteCurrency": quoteCurrency,
    "exchangeName": exchangeName,
    "exchangeAddress": exchangeAddress,
    "value": value,
  };
}