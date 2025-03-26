part of 'message_log_bloc.dart';

sealed class MessageLogState extends Equatable {
  const MessageLogState();

  @override
  List<Object?> get props => [];
}

final class MessageLogInitialState extends MessageLogState {
  const MessageLogInitialState();

  @override
  List<Object> get props => [];
}

final class MessageLogUpdatedState extends MessageLogState {
  final List<MessageLogRecord> messages;

  const MessageLogUpdatedState(this.messages);

  @override
  List<Object> get props => [messages];
}