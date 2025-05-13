import 'package:equatable/equatable.dart';

abstract class ThreadAttachmentStatusEvent extends Equatable {
  const ThreadAttachmentStatusEvent();

  @override
  List<Object> get props => [];
}

class ThreadAttachmentStatusUpdated extends ThreadAttachmentStatusEvent {
  final bool isAttached;

  const ThreadAttachmentStatusUpdated(this.isAttached);

  @override
  List<Object> get props => [isAttached];
}
