class ExchangeModel {
  ExchangeModel({
    required this.fromTokenName,
    required this.fromTokenIcon,
    required this.fromSymbol,
    required this.toTokenName,
    required this.toTokenIcon,
    required this.toSymbol,
    required this.fromAmount,
    required this.toAmount,
    required this.hexLink,
    required this.dataTime,
  });

  String fromTokenName;
  String fromTokenIcon;
  String fromSymbol;
  String toTokenName;
  String toTokenIcon;
  String toSymbol;
  String fromAmount;
  String toAmount;
  String hexLink;
  String dataTime;

  factory ExchangeModel.fromJson(Map<String, dynamic> json) => ExchangeModel(
    fromTokenName: json["from_token_name"],
    fromTokenIcon: json["from_token_icon"],
    fromSymbol: json["from_symbol"],
    toTokenName: json["to_token_name"],
    toTokenIcon: json["to_token_icon"],
    toSymbol: json["to_symbol"],
    fromAmount: json["from_amount"],
    toAmount: json["to_amount"],
    hexLink: json["hex_link"],
    dataTime: json["dataTime"],
  );

  Map<String, dynamic> toJson() => {
    "from_token_name": fromTokenName,
    "from_token_icon": fromTokenIcon,
    "from_symbol": fromSymbol,
    "to_token_name": toTokenName,
    "to_token_icon": toTokenIcon,
    "to_symbol": toSymbol,
    "from_amount": fromAmount,
    "to_amount": toAmount,
    "hex_link": hexLink,
    "dataTime": dataTime,
  };
}
