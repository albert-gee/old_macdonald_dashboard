import 'package:dashboard/widget/header/header_widget.dart';
import 'package:dashboard/widget/command_form/command_form_widget.dart';
import 'package:dashboard/widget/sidebar/sidebar_widget.dart';
import 'package:dashboard/widget/thread_dataset/thread_dataset_active_widget.dart';
import 'package:dashboard/widget/thread_dataset/thread_dataset_init_form_widget.dart';
import 'package:dashboard/widget/sidebar/thread_role_widget.dart';
import 'package:flutter/material.dart';
import '../widget/message_log/messsage_log_widget.dart';

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      body: Row(
        children: [
          // Sidebar
          const SideBarWidget(
            backgroundColor: Color(0xff202020),
            width: 150.0,
          ),

          // Main Content
          Expanded(
            child: Container(
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
                          subtitle: "Controlled Environment Agriculture System",
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

                        // Message Form
                        CommandFormWidget(),
                        const SizedBox(height: 20.0),

                        // Two-column layout for Thread widgets
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: ThreadDatasetInitFormWidget(),
                            ),
                            const SizedBox(width: 20.0),

                            const Expanded(
                              flex: 1,
                              child: ThreadDatasetActiveWidget(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),

                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}