import 'package:intl/intl.dart';

class MessageLogRecord {
  final String command;
  final String payload;
  final String time;

  MessageLogRecord({required this.command, required this.payload})
      : time = DateFormat('hh:mm:ss').format(DateTime.now());


  factory MessageLogRecord.fromJson(Map<String, dynamic> json) {
    return MessageLogRecord(
      command: json['command'],
      payload: json['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'command': command,
      'payload': payload,
    };
  }
}