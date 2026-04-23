import 'package:dartz/dartz.dart';
import 'package:appmanga/core/error/error_handler.dart';
import 'package:appmanga/core/error/failures.dart';
import 'package:appmanga/features/manga/domain/entities/home_data_entity.dart';
import 'package:appmanga/features/manga/domain/entities/manga_list_entity.dart';
import 'package:appmanga/features/manga/domain/entities/manga_detail_entity.dart';
import 'package:appmanga/features/manga/domain/entities/chapter_pages_entity.dart';
import 'package:appmanga/features/manga/domain/entities/chapter_entity.dart';
import 'package:appmanga/features/manga/domain/entities/page_entity.dart';
import 'package:appmanga/features/manga/domain/repositories/manga_repository.dart';
import 'package:appmanga/features/manga/data/models/chapter_model.dart';
import 'package:appmanga/features/manga/data/models/manga_model.dart';
import '../datasources/manga_remote_datasource.dart';

class MangaRepositoryImpl implements MangaRepository {
  final MangaRemoteDataSource _remote;

  MangaRepositoryImpl(this._remote);

  // Helper để ép kiểu an toàn (tránh lỗi double trên Web)
  int _safeInt(dynamic value) => MangaModel.toInt(value);

  @override
  Future<Either<Failure, HomeDataEntity>> getHomeData() async {
    try {
      final result = await _remote.getHomeData();
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, MangaListEntity>> getMangaList({
    int page = 1,
    int limit = 20,
    String? genre,
    String? status,
    String sort = 'latest',
    String? search,
  }) async {
    try {
      final result = await _remote.getMangaList(
        page: page,
        limit: limit,
        genre: genre,
        status: status,
        sort: sort,
        search: search,
      );
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, MangaDetailEntity>> getMangaDetail(String mangaId) async {
    try {
      final result = await _remote.getMangaDetail(mangaId);
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, ChapterPagesEntity>> getChapterPages(String chapterId) async {
    try {
      final dynamic response = await _remote.getChapterPages(chapterId);
      
      // Trường hợp 1: API trả về trực tiếp mảng các trang (theo log của bạn)
      if (response is List) {
        final List<PageEntity> pages = response.map<PageEntity>((e) => PageEntity(
          id: e['id']?.toString() ?? '',
          // SỬA LỖI: Dùng _safeInt thay vì "as int"
          pageNumber: _safeInt(e['pageNumber'] ?? e['page_number']),
          imageUrl: (e['imageUrl'] ?? e['image_url'] ?? '').toString(),
        )).toList();

        return Right(ChapterPagesEntity(
          chapter: ChapterEntity(
            id: chapterId,
            mangaId: '',
            chapterNumber: 0,
            pageCount: pages.length,
            isLocked: false,
            unlockCost: 0,
            isPremiumOnly: false,
            publishedAt: DateTime.now(),
          ),
          pages: pages,
        ));
      } 
      
      // Trường hợp 2: API trả về Object đầy đủ (theo thiết kế chuẩn)
      final chapter = ChapterModel.fromJson(response['chapter']);
      final List pagesRaw = response['pages'] as List? ?? [];
      final List<PageEntity> pages = pagesRaw.map<PageEntity>((e) => PageEntity(
        id: e['id']?.toString() ?? '',
        pageNumber: _safeInt(e['pageNumber'] ?? e['page_number']),
        imageUrl: (e['imageUrl'] ?? e['image_url'] ?? '').toString(),
      )).toList();
      
      final prevChapter = response['prevChapter'] != null 
          ? ChapterModel.fromJson(response['prevChapter']) 
          : null;
      final nextChapter = response['nextChapter'] != null 
          ? ChapterModel.fromJson(response['nextChapter']) 
          : null;

      return Right(ChapterPagesEntity(
        chapter: chapter,
        pages: pages,
        prevChapter: prevChapter,
        nextChapter: nextChapter,
      ));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> likeManga(String mangaId) async {
    try {
      await _remote.likeManga(mangaId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> unlikeManga(String mangaId) async {
    try {
      await _remote.unlikeManga(mangaId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> followManga(String mangaId) async {
    try {
      await _remote.followManga(mangaId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> unfollowManga(String mangaId) async {
    try {
      await _remote.unfollowManga(mangaId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateReadingHistory(String chapterId, int lastPage) async {
    try {
      await _remote.updateReadingHistory(chapterId, lastPage);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> unlockChapter(String chapterId) async {
    try {
      final result = await _remote.unlockChapter(chapterId);
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, int>> getPointBalance() async {
    try {
      final result = await _remote.getPointBalance();
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
