import 'package:equatable/equatable.dart';

abstract class ThreadDatasetInitFormState extends Equatable {
  const ThreadDatasetInitFormState();

  @override
  List<Object?> get props => [];
}

class ThreadDatasetInitFormInitial extends ThreadDatasetInitFormState {}

class ThreadDatasetInitFormSubmitting extends ThreadDatasetInitFormState {}

class ThreadDatasetInitFormSuccess extends ThreadDatasetInitFormState {}

class ThreadDatasetInitFormFailure extends ThreadDatasetInitFormState {
  final String error;

  const ThreadDatasetInitFormFailure(this.error);

  @override
  List<Object?> get props => [error];
}
