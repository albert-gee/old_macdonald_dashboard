import 'package:dashboard/blocs/message_log/message_log_bloc.dart';
import 'package:dashboard/models/message_log_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageLogWidget extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;

  const MessageLogWidget({
    Key? key,
    this.backgroundColor = const Color(0xFF212121),
    this.borderColor = const Color(0xFF424242),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MessageLogBloc messageLogBloc =
    BlocProvider.of<MessageLogBloc>(context);

    return Container(
      height: 150.0,  // Reduced height here
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: backgroundColor,
        border: Border.all(color: borderColor),
      ),
      child: BlocBuilder<MessageLogBloc, MessageLogState>(
        bloc: messageLogBloc,
        builder: (context, state) {
          if (state is MessageLogUpdatedState) {
            List<MessageLogRecord> messages = state.messages;
            return _buildMessages(
                messages, context, messageLogBloc.messagesScrollController);
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  /// Build the messages
  Widget _buildMessages(List<MessageLogRecord> messages, BuildContext context,
      ScrollController messagesScrollController) {

    return SizedBox(
        height: 150.0, // Reduced height here
        width: double.infinity,
        child: ListView(
          controller: messagesScrollController,
          children: <Widget>[
            for (final message in messages)
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: '[',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16.0,
                        ),
                      ),
                      TextSpan(
                        text: message.time,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16.0,
                        ),
                      ),
                      const TextSpan(
                        text: ']',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16.0,
                        ),
                      ),
                      const TextSpan(
                        text: ' \$   ',
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 16.0,
                        ),
                      ),
                      TextSpan(
                        text: '${message.command}: ${message.payload}',
                        style: TextStyle(
                          color: message.command == 'error' ? Colors.red
                              : (message.command == 'info' ? Colors.lightGreen : Colors.amber),
                          fontSize: 16.0,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ));
  }
}
