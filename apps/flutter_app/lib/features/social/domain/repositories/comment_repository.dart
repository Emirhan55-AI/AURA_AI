import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/comment.dart';

abstract class CommentRepository {
  Future<Either<Failure, List<Comment>>> getCommentsForEntity(
    String entityId,
    String entityType,
  );

  Future<Either<Failure, List<Comment>>> getCommentsForOutfit(String outfitId);

  Future<Either<Failure, Comment>> addComment({
    required String entityId,
    required String entityType,
    required String content,
  });

  Future<Either<Failure, Comment>> updateComment(
    String commentId,
    String newContent,
  );

  Future<Either<Failure, void>> deleteComment(String commentId);

  Future<Either<Failure, int>> getCommentCount(
    String entityId,
    String entityType,
  );
}
