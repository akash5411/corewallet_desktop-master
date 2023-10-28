import 'dart:convert';

List<NewsModel> newsModelFromJson(String str) => List<NewsModel>.from(json.decode(str).map((x) => NewsModel.fromJson(x)));


class NewsModel {
  NewsModel({
    required this.source,
    required this.author,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.content,
  });

  Source source;
  String author;
  String title;
  String description;
  String url;
  String urlToImage;
  DateTime publishedAt;
  String content;

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
    source: Source.fromJson(json["source"]),
    author: json["author"] == null ? "" : json["author"],
    title: json["title"],
    description: json["description"] ?? "",
    url: json["url"],
    urlToImage: json["urlToImage"] ?? "",
    publishedAt: DateTime.parse(json["publishedAt"]),
    content: json["content"],
  );

}

class Source {
  Source({
    required this.id,
    required this.name,
  });

  String id;
  String name;

  factory Source.fromJson(Map<String, dynamic> json) => Source(
    id: json["id"] == null ? "" : json["id"],
    name: json["name"],
  );

}
