import 'package:equatable/equatable.dart';

class ThreadAttachmentStatusState extends Equatable {
  final bool isAttached;

  const ThreadAttachmentStatusState({required this.isAttached});

  factory ThreadAttachmentStatusState.initial() => const ThreadAttachmentStatusState(isAttached: false);

  ThreadAttachmentStatusState copyWith({bool? isAttached}) {
    return ThreadAttachmentStatusState(
      isAttached: isAttached ?? this.isAttached,
    );
  }

  @override
  List<Object> get props => [isAttached];
}
