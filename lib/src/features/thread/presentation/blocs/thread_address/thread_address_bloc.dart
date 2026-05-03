import 'package:flutter_bloc/flutter_bloc.dart';
import 'thread_address_event.dart';
import 'thread_address_state.dart';

class ThreadAddressBloc extends Bloc<ThreadAddressEvent, ThreadAddressState> {
  ThreadAddressBloc() : super(ThreadAddressState.initial()) {
    on<ThreadUnicastAddressesUpdated>((event, emit) {
      emit(state.copyWith(unicastAddresses: event.addresses));
    });

    on<ThreadMulticastAddressesUpdated>((event, emit) {
      emit(state.copyWith(multicastAddresses: event.addresses));
    });
  }
}
