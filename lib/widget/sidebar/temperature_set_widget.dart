import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/blocs/temperature_set/temperature_set_bloc.dart';

class TemperatureSetWidget extends StatelessWidget {
  const TemperatureSetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemperatureSetBloc, TemperatureSetState>(
      builder: (context, state) {
        if (state is TemperatureSetUpdated) {
          final temperature = state.temperature;
          return _buildTemperatureCard(temperature);
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildTemperatureCard(String temperature) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff202020),
            Color(0xff303030),
          ],
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
          const Text(
            'Temperature',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13.0,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            '${temperature.substring(0, temperature.length - 2)}.${temperature.substring(temperature.length - 2)} °C',
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

    );
  }
}
