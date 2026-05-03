import 'package:flutter_bloc/flutter_bloc.dart';
import 'side_menu_state.dart';

class SideMenuCubit extends Cubit<SideMenuState> {
  SideMenuCubit() : super(const SideMenuState(selectedIndex: 0));

  void select(int index) {
    if (index != state.selectedIndex) {
      emit(SideMenuState(selectedIndex: index));
    }
  }
}
