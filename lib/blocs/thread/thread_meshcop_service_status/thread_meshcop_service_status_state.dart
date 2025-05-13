import 'package:equatable/equatable.dart';

class ThreadMeshcopServiceStatusState extends Equatable {
  final bool isPublished;

  const ThreadMeshcopServiceStatusState({required this.isPublished});

  factory ThreadMeshcopServiceStatusState.initial() =>
      const ThreadMeshcopServiceStatusState(isPublished: false);

  ThreadMeshcopServiceStatusState copyWith({bool? isPublished}) {
    return ThreadMeshcopServiceStatusState(
      isPublished: isPublished ?? this.isPublished,
    );
  }

  @override
  List<Object> get props => [isPublished];
}
