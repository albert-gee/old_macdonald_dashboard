import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subTitleColor;
  final Color shadowColor;

  const HeaderWidget({super.key, required this.title, required this.subtitle, required this.titleColor, required this.subTitleColor, required this.shadowColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.bold,
            color: titleColor,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: shadowColor,
              ),
            ],
          ),
        ),

        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: subTitleColor,
          ),
        ),
      ],
    );
  }
}


