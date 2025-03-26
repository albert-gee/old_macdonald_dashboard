import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dashboard/network/websocket.dart';

part 'thread_dataset_init_event.dart';
part 'thread_dataset_init_state.dart';

class ThreadDatasetInitBloc extends Bloc<ThreadDatasetInitEvent, ThreadDatasetInitState> {
  final Websocket websocket;

  ThreadDatasetInitBloc({required this.websocket}) : super(const ThreadDatasetInitInitialState()) {

    on<ThreadDatasetInitSendEvent>((event, emit) async {
      emit(const ThreadDatasetInitLoadingState());
      try {
        bool success = await websocket.sendJsonMessage(event.dataset);
        if (success) {
          emit(const ThreadDatasetInitSuccessState());
        } else {
          emit(const ThreadDatasetInitFailureState("Failed to send dataset."));
        }
      } catch (e) {
        emit(ThreadDatasetInitFailureState(e.toString()));
      }
    });
  }
}
