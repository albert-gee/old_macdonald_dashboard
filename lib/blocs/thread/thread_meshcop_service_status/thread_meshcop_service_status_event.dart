import 'package:equatable/equatable.dart';

abstract class ThreadMeshcopServiceStatusEvent extends Equatable {
  const ThreadMeshcopServiceStatusEvent();

  @override
  List<Object> get props => [];
}

class ThreadMeshcopServiceStatusUpdated extends ThreadMeshcopServiceStatusEvent {
  final bool isPublished;

  const ThreadMeshcopServiceStatusUpdated(this.isPublished);

  @override
  List<Object> get props => [isPublished];
}
