import 'package:dartz/dartz.dart';
import 'package:appmanga/core/error/error_handler.dart';
import 'package:appmanga/core/error/failures.dart';
import 'package:appmanga/features/manga/domain/entities/home_data_entity.dart';
import 'package:appmanga/features/manga/domain/entities/manga_list_entity.dart';
import 'package:appmanga/features/manga/domain/repositories/manga_repository.dart';
import '../datasources/manga_remote_datasource.dart';

class MangaRepositoryImpl implements MangaRepository {
  final MangaRemoteDataSource _remote;

  MangaRepositoryImpl(this._remote);

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
  Future<Either<Failure, MangaListEntity>> searchManga({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    return getMangaList(page: page, limit: limit, search: query);
  }
}
