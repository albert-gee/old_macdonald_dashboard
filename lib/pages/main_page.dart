import 'package:flutter/material.dart';
import 'package:dashboard/widget/content/dashboard/dashboard_widget.dart';
import 'package:dashboard/widget/content/page_header.dart';
import 'package:dashboard/widget/content/messsage_log_widget.dart';

class MainPage extends StatelessWidget {
  final String title;

  const MainPage({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Header
              PageHeaderWidget(
                title: title,
              ),
              const SizedBox(height: 20.0),

              // Message Log
              const SizedBox(
                height: 150,
                child: MessageLogWidget(),
              ),
              const SizedBox(height: 20.0),

              // Dashboard
              const DashboardWidget(),
            ]),
          ),
        ),
      ],
    );
  }
}
