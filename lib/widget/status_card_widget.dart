import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/blocs/status_card/status_card_bloc.dart';
import 'package:dashboard/blocs/status_card/status_card_state.dart';

class StatusCardWidget<T> extends StatelessWidget {
  final String title;
  final StatusCardBloc<T> bloc;
  final bool Function(StatusCardState<T>) isUpdated;
  final T Function(StatusCardState<T>) extractStatus;
  final Color Function(String) colorResolver;
  final String Function(String)? formatter;

  const StatusCardWidget({
    super.key,
    required this.title,
    required this.bloc,
    required this.isUpdated,
    required this.extractStatus,
    required this.colorResolver,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return _buildBloc(context);
  }

  Widget _buildBloc(BuildContext context) {
    // 🧠 Critical: extract BlocBuilder into a method — works around Dart's inference bug
    return BlocBuilder<StatusCardBloc<T>, StatusCardState<T>>(
      bloc: bloc,
      builder: (context, state) {
        if (!isUpdated(state)) return const SizedBox.shrink();

        final raw = extractStatus(state);
        final display = formatter?.call(raw.toString()) ?? raw.toString();
        final color = colorResolver(raw.toString());

        return _buildCard(display, color);
      },
    );
  }

  Widget _buildCard(String display, Color color) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff202020), Color(0xff303030)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 7.0,
            spreadRadius: 2.5,
            offset: const Offset(0, 1.0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13.0)),
          const SizedBox(height: 5.0),
          Text(
            display,
            style: TextStyle(
              color: color,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
