import 'package:dartz/dartz.dart';
import 'package:appmanga/core/error/failures.dart';
import '../entities/home_data_entity.dart';
import '../entities/manga_list_entity.dart';
import '../entities/manga_detail_entity.dart';
import '../entities/chapter_pages_entity.dart';

abstract class MangaRepository {
  Future<Either<Failure, HomeDataEntity>> getHomeData();
  
  Future<Either<Failure, MangaListEntity>> getMangaList({
    int page = 1,
    int limit = 20,
    String? genre,
    String? status,
    String sort = 'latest',
    String? search,
  });

  Future<Either<Failure, MangaDetailEntity>> getMangaDetail(String mangaId);

  Future<Either<Failure, ChapterPagesEntity>> getChapterPages(String chapterId);

  Future<Either<Failure, void>> likeManga(String mangaId);

  Future<Either<Failure, void>> unlikeManga(String mangaId);

  Future<Either<Failure, void>> followManga(String mangaId);

  Future<Either<Failure, void>> unfollowManga(String mangaId);

  Future<Either<Failure, void>> updateReadingHistory(String chapterId, int lastPage);

  Future<Either<Failure, Map<String, dynamic>>> unlockChapter(String chapterId);

  Future<Either<Failure, int>> getPointBalance();
}
