import 'dart:convert';

List<SwapProviders> swapprovidersFromJson(String str) => List<SwapProviders>.from(json.decode(str).map((x) => SwapProviders.fromJson(x)));

String swapprovidersToJson(List<SwapProviders> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SwapProviders {
  SwapProviders({
    required this.id,
    required this.name,
    required this.router,
    required this.logo,
    required this.is_active,
  });

  int id;
  String name;
  String router;
  String logo;
  int is_active;

  factory SwapProviders.fromJson(Map<String, dynamic> json) => SwapProviders(
    id: json["id"],
    name: json["name"],
    router: json["Router"],
    logo: json["logo"],
    is_active: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "Router": router,
    "logo": logo,
  };
}
