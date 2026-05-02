import 'package:equatable/equatable.dart';

abstract class ThreadCommandEvent extends Equatable {
  const ThreadCommandEvent();

  @override
  List<Object?> get props => [];
}

class ThreadEnableRequested extends ThreadCommandEvent {
  const ThreadEnableRequested();
}

class ThreadDisableRequested extends ThreadCommandEvent {
  const ThreadDisableRequested();
}

class ThreadStatusRefreshRequested extends ThreadCommandEvent {
  const ThreadStatusRefreshRequested();
}

class ThreadAttachmentRefreshRequested extends ThreadCommandEvent {
  const ThreadAttachmentRefreshRequested();
}

class ThreadRoleRefreshRequested extends ThreadCommandEvent {
  const ThreadRoleRefreshRequested();
}

class ThreadActiveDatasetRefreshRequested extends ThreadCommandEvent {
  const ThreadActiveDatasetRefreshRequested();
}

class ThreadUnicastAddressesRefreshRequested extends ThreadCommandEvent {
  const ThreadUnicastAddressesRefreshRequested();
}

class ThreadMulticastAddressesRefreshRequested extends ThreadCommandEvent {
  const ThreadMulticastAddressesRefreshRequested();
}

class ThreadBorderRouterInitRequested extends ThreadCommandEvent {
  const ThreadBorderRouterInitRequested();
}

class ThreadBorderRouterDeinitRequested extends ThreadCommandEvent {
  const ThreadBorderRouterDeinitRequested();
}
