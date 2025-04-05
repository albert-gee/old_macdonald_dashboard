part of 'subscribe_attribute_command_bloc.dart';

abstract class SubscribeAttributeCommandState extends Equatable {
  const SubscribeAttributeCommandState();

  @override
  List<Object?> get props => [];
}

class SubscribeAttributeCommandInitial extends SubscribeAttributeCommandState {}

class SubscribeAttributeCommandSuccess extends SubscribeAttributeCommandState {
  final Map<String, dynamic> payload;

  const SubscribeAttributeCommandSuccess({required this.payload});

  @override
  List<Object?> get props => [payload];
}

class SubscribeAttributeCommandFailure extends SubscribeAttributeCommandState {
  final String error;

  const SubscribeAttributeCommandFailure(this.error);

  @override
  List<Object?> get props => [error];
}
