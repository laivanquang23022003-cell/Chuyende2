import 'package:appmanga/features/manga/domain/entities/chapter_entity.dart';

class ChapterModel extends ChapterEntity {
  ChapterModel({
    required super.id,
    required super.mangaId,
    required super.chapterNumber,
    super.title,
    required super.pageCount,
    required super.isLocked,
    required super.unlockCost,
    required super.isPremiumOnly,
    required super.publishedAt,
    super.hasAccess,
    super.isRead,
    super.lastPage,
  });

  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static bool toBool(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    final str = value.toString().toLowerCase();
    return str == 'true' || str == '1';
  }

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id']?.toString() ?? '',
      mangaId: (json['mangaId'] ?? json['manga_id'])?.toString() ?? '',
      chapterNumber: toInt(json['chapterNumber'] ?? json['chapter_number']),
      title: json['title']?.toString(),
      pageCount: toInt(json['pageCount'] ?? json['page_count']),
      isLocked: toBool(json['isLocked'] ?? json['is_locked'], false),
      unlockCost: toInt(json['unlockCost'] ?? json['unlock_cost']),
      isPremiumOnly: toBool(json['isPremiumOnly'] ?? json['is_premium_only'], false),
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt']) 
          : (json['published_at'] != null ? DateTime.parse(json['published_at']) : DateTime.now()),
      hasAccess: toBool(json['hasAccess'] ?? json['has_access'], true),
      isRead: toBool(json['isRead'] ?? json['is_read'], false),
      lastPage: (json['lastPage'] != null || json['last_page'] != null)
          ? toInt(json['lastPage'] ?? json['last_page'])
          : null,
    );
  }
}
