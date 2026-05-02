import 'package:bloc/bloc.dart';
import 'package:dashboard/services/i_thread_command_service.dart';
import 'package:get_it/get_it.dart';

import 'thread_command_event.dart';
import 'thread_command_state.dart';

class ThreadCommandBloc extends Bloc<ThreadCommandEvent, ThreadCommandState> {
  final IThreadCommandService _threadCommandService;

  ThreadCommandBloc({IThreadCommandService? threadCommandService})
      : _threadCommandService =
            threadCommandService ?? GetIt.I<IThreadCommandService>(),
        super(const ThreadCommandInitial()) {
    on<ThreadEnableRequested>(
      (event, emit) => _run(
        emit,
        _threadCommandService.sendThreadEnableCommand,
        'Thread enable command sent.',
      ),
    );
    on<ThreadDisableRequested>(
      (event, emit) => _run(
        emit,
        _threadCommandService.sendThreadDisableCommand,
        'Thread disable command sent.',
      ),
    );
    on<ThreadStatusRefreshRequested>(
      (event, emit) => _run(
        emit,
        _threadCommandService.sendThreadStatusGetCommand,
        'Thread status refresh command sent.',
      ),
    );
    on<ThreadAttachmentRefreshRequested>(
      (event, emit) => _run(
        emit,
        _threadCommandService.sendThreadAttachedGetCommand,
        'Thread attachment refresh command sent.',
      ),
    );
    on<ThreadRoleRefreshRequested>(
      (event, emit) => _run(
        emit,
        _threadCommandService.sendThreadRoleGetCommand,
        'Thread role refresh command sent.',
      ),
    );
    on<ThreadActiveDatasetRefreshRequested>(
      (event, emit) => _run(
        emit,
        _threadCommandService.sendThreadActiveDatasetGetCommand,
        'Thread active dataset refresh command sent.',
      ),
    );
    on<ThreadUnicastAddressesRefreshRequested>(
      (event, emit) => _run(
        emit,
        _threadCommandService.sendThreadUnicastAddressesGetCommand,
        'Thread unicast addresses refresh command sent.',
      ),
    );
    on<ThreadMulticastAddressesRefreshRequested>(
      (event, emit) => _run(
        emit,
        _threadCommandService.sendThreadMulticastAddressesGetCommand,
        'Thread multicast addresses refresh command sent.',
      ),
    );
    on<ThreadBorderRouterInitRequested>(
      (event, emit) => _run(
        emit,
        _threadCommandService.sendThreadBorderRouterInitCommand,
        'Thread Border Router init command sent.',
      ),
    );
    on<ThreadBorderRouterDeinitRequested>(
      (event, emit) => _run(
        emit,
        _threadCommandService.sendThreadBorderRouterDeinitCommand,
        'Thread Border Router deinit command sent.',
      ),
    );
  }

  Future<void> _run(
    Emitter<ThreadCommandState> emit,
    Future<void> Function() command,
    String successMessage,
  ) async {
    emit(const ThreadCommandInProgress());
    try {
      await command();
      emit(ThreadCommandSuccess(successMessage));
    } catch (_) {
      emit(const ThreadCommandFailure(
        'Failed to send Thread command. Make sure the WebSocket is connected.',
      ));
    }
  }
}
