part of 'read_attribute_command_bloc.dart';

abstract class ReadAttributeCommandState extends Equatable {
  const ReadAttributeCommandState();

  @override
  List<Object> get props => [];
}

class ReadAttributeCommandInitial extends ReadAttributeCommandState {}

class ReadAttributeCommandSuccess extends ReadAttributeCommandState {
  final Map<String, dynamic> payload;

  const ReadAttributeCommandSuccess({required this.payload});

  @override
  List<Object> get props => [payload];
}

class ReadAttributeCommandFailure extends ReadAttributeCommandState {
  final String error;

  const ReadAttributeCommandFailure(this.error);

  @override
  List<Object> get props => [error];
}
