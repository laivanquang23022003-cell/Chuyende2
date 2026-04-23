import 'package:dartz/dartz.dart';
import 'package:appmanga/core/error/failures.dart';
import '../entities/home_data_entity.dart';
import '../entities/manga_list_entity.dart';

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
}
