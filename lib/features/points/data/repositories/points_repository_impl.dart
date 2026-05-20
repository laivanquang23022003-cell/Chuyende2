import 'package:dartz/dartz.dart';
import 'package:appmanga/core/error/error_handler.dart';
import 'package:appmanga/core/error/failures.dart';
import 'package:appmanga/features/points/domain/entities/task_entity.dart';
import 'package:appmanga/features/points/domain/entities/point_transaction_entity.dart';
import 'package:appmanga/features/points/domain/repositories/points_repository.dart';
import '../datasources/points_remote_datasource.dart';

abstract class PointsRepositoryImpl implements PointsRepository {
  final PointsRemoteDataSource _remote;

  PointsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    try {
      final result = await _remote.getTasks();
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, CompleteTaskResponse>> completeTask(String taskId, {Map<String, dynamic>? proof}) async {
    try {
      final result = await _remote.completeTask(taskId, proof: proof);
      return Right(CompleteTaskResponse(
        pointsEarned: (result['points_earned'] ?? 0) as int,
        newBalance: (result['new_balance'] ?? 0) as int,
        completion: result['completion'],
      ));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<PointTransactionEntity>>> getPointHistory({int page = 1, int limit = 20}) async {
    try {
      final result = await _remote.getPointHistory(page: page, limit: limit);
      return Right(result.map((e) => PointTransactionEntity(
        id: e['id']?.toString() ?? '',
        amount: (e['amount'] ?? 0) as int,
        reason: e['reason']?.toString() ?? '',
        createdAt: DateTime.parse(e['createdAt'] ?? e['created_at']),
      )).toList());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
