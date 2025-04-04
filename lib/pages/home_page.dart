import 'package:dashboard/widget/dashboard/dashboard_widget.dart';
import 'package:dashboard/widget/header/header_widget.dart';
import 'package:dashboard/widget/message_log/messsage_log_widget.dart';
import 'package:dashboard/widget/sidebar/sidebar_widget.dart';
import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  final String title;
  final String subTitle;

  const HomePage({
    super.key,
    required this.title, required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff121212),
        body: Row(children: [
          // Sidebar
          const SideBarWidget(
            backgroundColor: Color(0xff202020),
            width: 130.0,
          ),

          // Main Content
          Expanded(
              child: _buildMainSection()
          ),
        ])
    );
  }

  Widget _buildMainSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff1e1e1e),
            Color(0xff2c2c2c),
          ],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header
                HeaderWidget(
                  title: title,
                  subtitle: subTitle,
                  titleColor: Colors.white,
                  subTitleColor: Colors.white70,
                  shadowColor: Colors.lightBlueAccent,
                ),
                const SizedBox(height: 20.0),

                // Message Log
                const SizedBox(
                  height: 150,
                  child: MessageLogWidget(),
                ),
                const SizedBox(height: 20.0),


                DashboardWidget()
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
