part of 'message_log_bloc.dart';

sealed class MessageLogEvent extends Equatable {
  const MessageLogEvent();
}

final class MessageLogSentMessageEvent extends MessageLogEvent {
  final String command;
  final String payload;

  const MessageLogSentMessageEvent(this.command, this.payload);

  @override
  List<Object> get props => [command, payload];
}

final class MessageLogReceivedMessageEvent extends MessageLogEvent {
  final String command;
  final String payload;

  const MessageLogReceivedMessageEvent(this.command, this.payload);

  @override
  List<Object> get props => [command, payload];
}