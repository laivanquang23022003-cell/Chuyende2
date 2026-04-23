import 'package:appmanga/features/manga/domain/entities/manga_entity.dart';

class AuthorModel extends AuthorEntity {
  AuthorModel({
    required super.id,
    required super.username,
    super.avatarUrl,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
    };
  }
}
