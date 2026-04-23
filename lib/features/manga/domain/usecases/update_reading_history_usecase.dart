import 'package:dartz/dartz.dart';
import 'package:appmanga/core/error/failures.dart';
import '../repositories/manga_repository.dart';

class UpdateReadingHistoryUseCase {
  final MangaRepository repository;
  UpdateReadingHistoryUseCase(this.repository);

  Future<Either<Failure, void>> call(String chapterId, int lastPage) {
    return repository.updateReadingHistory(chapterId, lastPage);
  }
}
