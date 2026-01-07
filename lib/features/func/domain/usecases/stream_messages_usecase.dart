import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:resq/core/error/failures.dart';
import 'package:resq/features/func/domain/entities/message.dart';
import 'package:resq/features/func/domain/repositories/community_repository.dart';

@injectable
class StreamMessagesUseCase {
  final CommunityRepository repository;

  StreamMessagesUseCase(this.repository);

  Stream<Either<Failure, List<Message>>> call() {
    return repository.streamMessages();
  }
}

