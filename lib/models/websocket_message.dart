import 'dart:convert';

/// Base class for all WebSocket messages
abstract class WebSocketMessage {
  final String command;

  const WebSocketMessage({
    required this.command,
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
      case 'ifconfig_status':
        return IfconfigStatusMessage.fromJson(json);
      case 'thread_status':
        return ThreadStatusMessage.fromJson(json);
      case 'wifi_sta_status':
        return WifiStaStatusMessage.fromJson(json);
      case 'temperature_set':
        return TemperatureSetMessage.fromJson(json);

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
  }) : super(command: 'error');

  factory ErrorMessage.fromJson(Map<String, dynamic> json) {
    return ErrorMessage(
      error: json['payload'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': error,
  };
}

/// Message for info responses
class InfoMessage extends WebSocketMessage {
  final String info;

  const InfoMessage({
    required this.info,
  }) : super(command: 'info');

  factory InfoMessage.fromJson(Map<String, dynamic> json) {
    return InfoMessage(
      info: json['payload'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': info,
  };
}

/// Message for thread dataset active
class ThreadDatasetActiveMessage extends WebSocketMessage {
  final Map<String, dynamic> dataset;

  const ThreadDatasetActiveMessage({
    required this.dataset,
  }) : super(command: 'thread_dataset_active');

  factory ThreadDatasetActiveMessage.fromJson(Map<String, dynamic> json) {
    return ThreadDatasetActiveMessage(
      dataset: json['payload'] as Map<String, dynamic>,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': dataset,
  };
}

/// Message for getting thread role
class ThreadRoleMessage extends WebSocketMessage {
  final String role;

  const ThreadRoleMessage({
    required this.role,
  }) : super(command: 'thread_role_set');

  factory ThreadRoleMessage.fromJson(Map<String, dynamic> json) {
    return ThreadRoleMessage(
      role: json['payload'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': role,
  };
}

class IfconfigStatusMessage extends WebSocketMessage {
  final String status;

  const IfconfigStatusMessage({
    required this.status,
  }) : super(command: 'ifconfig_status');

  factory IfconfigStatusMessage.fromJson(Map<String, dynamic> json) {
    return IfconfigStatusMessage(
      status: json['payload'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': status,
  };
}

class ThreadStatusMessage extends WebSocketMessage {
  final String status;

  const ThreadStatusMessage({
    required this.status,
  }) : super(command: 'thread_status');

  factory ThreadStatusMessage.fromJson(Map<String, dynamic> json) {
    return ThreadStatusMessage(
      status: json['payload'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': status,
  };
}

class WifiStaStatusMessage extends WebSocketMessage {
  final String status;

  const WifiStaStatusMessage({
    required this.status,
  }) : super(command: 'wifi_sta_status');

  factory WifiStaStatusMessage.fromJson(Map<String, dynamic> json) {
    return WifiStaStatusMessage(
      status: json['payload'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': status,
  };
}

class TemperatureSetMessage extends WebSocketMessage {
  final String temperature;

  const TemperatureSetMessage({
    required this.temperature,
  }) : super(command: 'temperature_set');

  factory TemperatureSetMessage.fromJson(Map<String, dynamic> json) {
    return TemperatureSetMessage(
      temperature: json['payload'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': temperature,
  };
}



/// Message for result responses
class ResultMessage extends WebSocketMessage {
  final String result;
  final DateTime timestamp;

  const ResultMessage({
    required this.result,
    required this.timestamp,
  }) : super(command: 'result');

  factory ResultMessage.fromJson(Map<String, dynamic> json) {
    return ResultMessage(
      result: json['payload']['result'] as String,
      timestamp: DateTime.parse(json['payload']['timestamp'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': {
      'result': result,
      'timestamp': timestamp.toIso8601String(),
    },
  };
}



/// Fallback message for unknown types
class GenericMessage extends WebSocketMessage {
  final dynamic payload;

  const GenericMessage({
    required String command,
    required this.payload,
  }) : super(command: command);

  factory GenericMessage.fromJson(Map<String, dynamic> json) {
    return GenericMessage(
      command: json['command'] as String,
      payload: json['payload'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    'payload': payload,
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
