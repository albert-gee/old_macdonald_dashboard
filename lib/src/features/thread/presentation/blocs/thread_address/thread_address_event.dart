import 'package:equatable/equatable.dart';

abstract class ThreadAddressEvent extends Equatable {
  const ThreadAddressEvent();

  @override
  List<Object> get props => [];
}

class ThreadUnicastAddressesUpdated extends ThreadAddressEvent {
  final List<String> addresses;

  const ThreadUnicastAddressesUpdated(this.addresses);

  @override
  List<Object> get props => [addresses];
}

class ThreadMulticastAddressesUpdated extends ThreadAddressEvent {
  final List<String> addresses;

  const ThreadMulticastAddressesUpdated(this.addresses);

  @override
  List<Object> get props => [addresses];
}
