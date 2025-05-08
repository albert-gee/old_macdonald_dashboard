import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef StatusSelector<T> = String Function(T state);
typedef StatusFilter<T> = bool Function(T state);
typedef StatusColorResolver = Color Function(String status);
typedef StatusFormatter = String Function(String status);

class StatusCardWidget<T> extends StatelessWidget {
  final BlocBase<T> bloc;
  final StatusFilter<T> isUpdated;
  final StatusSelector<T> extractStatus;
  final String title;
  final StatusColorResolver colorResolver;
  final StatusFormatter? formatter;

  const StatusCardWidget({
    super.key,
    required this.bloc,
    required this.isUpdated,
    required this.extractStatus,
    required this.title,
    required this.colorResolver,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlocBase<T>, T>(
      bloc: bloc,
      builder: (context, state) {
        if (!isUpdated(state)) return const SizedBox.shrink();

        final status = extractStatus(state);
        final formatted = formatter?.call(status) ?? status;

        return _buildCard(title, formatted, colorResolver(status));
      },
    );
  }

  Widget _buildCard(String title, String status, Color color) {
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
            status,
            style: TextStyle(color: color, fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
