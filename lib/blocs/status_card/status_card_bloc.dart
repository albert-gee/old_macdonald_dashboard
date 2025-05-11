import 'package:bloc/bloc.dart';
import 'status_card_event.dart';
import 'status_card_state.dart';

class StatusCardBloc<T> extends Bloc<StatusCardEvent<T>, StatusCardState<T>> {
  StatusCardBloc(T initialValue) : super(StatusCardInitial(initialValue)) {
    on<StatusCardChanged<T>>((event, emit) {
      emit(StatusCardUpdated(event.value));
    });
  }
}
