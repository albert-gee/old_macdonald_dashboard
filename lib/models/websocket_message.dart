import 'dart:convert';

/// Base class for all WebSocket messages
abstract class WebSocketMessage {
  final String command;
  final String? token;

  const WebSocketMessage({
    required this.command,
    this.token,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    final command = json['command'] as String;

    print("WebSocketMessage: factory WebSocketMessage.fromJson: command: $command, json: $json");

    switch (command) {
      case 'info':
        return InfoMessage.fromJson(json);
      case 'error':
        return ErrorMessage.fromJson(json);
      case 'thread_dataset_active':
        return ThreadDatasetActiveMessage.fromJson(json);
      case 'thread_role_set':
        return ThreadRoleMessage.fromJson(json);

      default:
        return GenericMessage.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

/// Message for error responses
class ErrorMessage extends WebSocketMessage {
  final String error;

  const ErrorMessage({
    required this.error,
    String? token,
  }) : super(command: 'error', token: token);

  factory ErrorMessage.fromJson(Map<String, dynamic> json) {
    return ErrorMessage(
      error: json['payload'] as String,
      token: json['token'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': error,
    if (token != null) 'token': token,
  };
}

/// Message for info responses
class InfoMessage extends WebSocketMessage {
  final String info;

  const InfoMessage({
    required this.info,
    String? token,
  }) : super(command: 'info', token: token);

  factory InfoMessage.fromJson(Map<String, dynamic> json) {
    return InfoMessage(
      info: json['payload'] as String,
      token: json['token'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': info,
    if (token != null) 'token': token,
  };
}

/// Message for thread dataset active
class ThreadDatasetActiveMessage extends WebSocketMessage {
  final Map<String, dynamic> dataset;

  const ThreadDatasetActiveMessage({
    required this.dataset,
    String? token,
  }) : super(command: 'thread_dataset_active', token: token);

  factory ThreadDatasetActiveMessage.fromJson(Map<String, dynamic> json) {
    return ThreadDatasetActiveMessage(
      dataset: json['payload'] as Map<String, dynamic>,
      token: json['token'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': dataset,
    if (token != null) 'token': token,
  };
}

/// Message for getting thread role
class ThreadRoleMessage extends WebSocketMessage {
  final String role;

  const ThreadRoleMessage({
    required this.role,
    String? token,
  }) : super(command: 'thread_role_set', token: token);

  factory ThreadRoleMessage.fromJson(Map<String, dynamic> json) {
    return ThreadRoleMessage(
      role: json['payload'] as String,
      token: json['token'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': role,
    if (token != null) 'token': token,
  };
}



/// Message for result responses
class ResultMessage extends WebSocketMessage {
  final String result;
  final DateTime timestamp;

  const ResultMessage({
    required this.result,
    required this.timestamp,
    String? token,
  }) : super(command: 'result', token: token);

  factory ResultMessage.fromJson(Map<String, dynamic> json) {
    return ResultMessage(
      result: json['payload']['result'] as String,
      timestamp: DateTime.parse(json['payload']['timestamp'] as String),
      token: json['token'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': {
      'result': result,
      'timestamp': timestamp.toIso8601String(),
    },
    if (token != null) 'token': token,
  };
}



/// Fallback message for unknown types
class GenericMessage extends WebSocketMessage {
  final dynamic payload;

  const GenericMessage({
    required String command,
    required this.payload,
    String? token,
  }) : super(command: command, token: token);

  factory GenericMessage.fromJson(Map<String, dynamic> json) {
    return GenericMessage(
      command: json['command'] as String,
      payload: json['payload'],
      token: json['token'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': payload,
    if (token != null) 'token': token,
  };
}

/// Parser for converting raw WebSocket messages to typed objects
class WebSocketMessageParser {

  /// Parse websocket message
  WebSocketMessage parse(String message) {
    try {
      final json = jsonDecode(message) as Map<String, dynamic>;
      return WebSocketMessage.fromJson(json);
    } on FormatException catch (e) {
      throw MessageParseException('Invalid JSON format: $e');
    } on TypeError catch (e) {
      throw MessageParseException('Invalid message structure: $e');
    } catch (e) {
      throw MessageParseException('Unexpected error: $e');
    }
  }
}

/// Exception thrown when message parsing fails
class MessageParseException implements Exception {
  final String message;
  const MessageParseException(this.message);

  @override
  String toString() => 'MessageParseException: $message';
}