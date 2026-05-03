import 'package:equatable/equatable.dart';

class SideMenuState extends Equatable {
  final int selectedIndex;

  const SideMenuState({required this.selectedIndex});

  @override
  List<Object> get props => [selectedIndex];
}
