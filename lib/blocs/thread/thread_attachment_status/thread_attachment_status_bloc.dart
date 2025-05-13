import 'package:flutter_bloc/flutter_bloc.dart';
import 'thread_attachment_status_event.dart';
import 'thread_attachment_status_state.dart';

class ThreadAttachmentStatusBloc extends Bloc<ThreadAttachmentStatusEvent, ThreadAttachmentStatusState> {
  ThreadAttachmentStatusBloc() : super(ThreadAttachmentStatusState.initial()) {
    on<ThreadAttachmentStatusUpdated>((event, emit) {
      emit(state.copyWith(isAttached: event.isAttached));
    });
  }
}
