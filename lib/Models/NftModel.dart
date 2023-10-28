import 'package:meta/meta.dart';
import 'dart:convert';

List<NtfList> ntfListFromJson(String str) => List<NtfList>.from(json.decode(str).map((x) => NtfList.fromJson(x)));

String ntfListToJson(List<NtfList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NtfList {
  NtfList({
    required this.tokenAddress,
    required this.tokenId,
    required this.amount,
    required this.ownerOf,
    required this.tokenHash,
    required this.blockNumberMinted,
    required this.blockNumber,
    required this.contractType,
    required this.name,
    required this.symbol,
    required this.tokenUri,
    required this.metadata,
  });

  String tokenAddress;
  String tokenId;
  String amount;
  String ownerOf;
  String tokenHash;
  String blockNumberMinted;
  String blockNumber;
  String contractType;
  String name;
  String symbol;
  String tokenUri;
  String metadata;

  factory NtfList.fromJson(Map<String, dynamic> json) => NtfList(
    tokenAddress: json["token_address"],
    tokenId: json["token_id"],
    amount: json["amount"],
    ownerOf: json["owner_of"],
    tokenHash: json["token_hash"],
    blockNumberMinted: json["block_number_minted"],
    blockNumber: json["block_number"],
    contractType: json["contract_type"],
    name: json["name"] ?? "",
    symbol: json["symbol"] ?? "",
    tokenUri: json["token_uri"] ?? "",
    metadata: json["metadata"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "token_address": tokenAddress,
    "token_id": tokenId,
    "amount": amount,
    "owner_of": ownerOf,
    "token_hash": tokenHash,
    "block_number_minted": blockNumberMinted,
    "block_number": blockNumber,
    "contract_type": contractType,
    "name": name,
    "symbol": symbol,
    "token_uri": tokenUri,
    "metadata": metadata,
  };
}
