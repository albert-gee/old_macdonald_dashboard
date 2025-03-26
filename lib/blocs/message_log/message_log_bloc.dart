import 'package:bloc/bloc.dart';
import 'package:dashboard/models/message_log_record.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'message_log_event.dart';

part 'message_log_state.dart';

class MessageLogBloc extends Bloc<MessageLogEvent, MessageLogState> {
  late final Function(String) onMessageReceived;
  late final Function(String, String) onMessageSent;

  final ScrollController messagesScrollController = ScrollController();
  final List<MessageLogRecord> _messages = [];

  MessageLogBloc({required this.onMessageReceived, required this.onMessageSent})
      : super(const MessageLogInitialState()) {
    
    /// MessageLogSentMessageEvent
    on<MessageLogSentMessageEvent>((event, emit) async {
      String command = event.command;
      String payload = event.payload;
      bool isSent = await onMessageSent(command, payload);
      if (!isSent) {
        command = "error";
        payload = "WebSocket is not connected";
      }

      _addMessageToLog(command, payload, emit);
    });

    /// MessageLogReceivedMessageEvent
    on<MessageLogReceivedMessageEvent>((event, emit) {
      print("MessageLogBloc: MessageLogReceivedMessageEvent: event: $event");
      _addMessageToLog(event.command, event.payload, emit);
    });
  }

  void _addMessageToLog(String command, String payload, emit) {
    print("MessageLogBloc: _addMessageToLog: command: $command, payload: $payload");

    MessageLogRecord message = MessageLogRecord(command: command, payload: payload);
    _messages.add(message);

    List<MessageLogRecord> updatedMessages = List.from(_messages);
    emit(MessageLogUpdatedState(updatedMessages));

    // Scroll to the bottom of the messages list
    if (messagesScrollController.hasClients) {
      messagesScrollController.animateTo(
        messagesScrollController.position.maxScrollExtent + 50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
