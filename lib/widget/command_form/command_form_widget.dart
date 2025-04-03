import 'package:dashboard/blocs/message_log/message_log_bloc.dart';
import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommandFormWidget extends StatelessWidget {
  final TextEditingController commandController = TextEditingController();
  final TextEditingController payloadController = TextEditingController();

  late final MessageLogBloc messageLogBloc;
  late final WebsocketConnectionBloc websocketConnectionBloc;

  CommandFormWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    messageLogBloc = BlocProvider.of<MessageLogBloc>(context);
    websocketConnectionBloc = BlocProvider.of<WebsocketConnectionBloc>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Added title here
        const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: Text(
            "Commands",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Row(
          children: <Widget>[
            _inputs(),
            const SizedBox(width: 20.0),
            BlocBuilder<WebsocketConnectionBloc, WebsocketConnectionState>(
              bloc: websocketConnectionBloc,
              builder: (context, state) {
                if (state is WebsocketConnectionConnectedState) {
                  return _sendButton(context: context, isDisabled: false);
                } else {
                  return _sendButton(context: context, isDisabled: true);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _inputs() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _dropdownInputField(controller: commandController),
          const SizedBox(height: 8),
          _inputField(labelText: 'Code', controller: payloadController),
        ],
      ),
    );
  }

  Widget _dropdownInputField({required TextEditingController controller}) {
    return DropdownButtonFormField(
      isDense: true,
      dropdownColor: Colors.black54,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.0),
          borderSide: const BorderSide(color: Colors.indigoAccent, width: 2.0),
        ),
        prefixIcon: const Icon(
          Icons.keyboard_command_key,
          color: Colors.indigoAccent,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 55.0),
        filled: true,
        fillColor: Colors.black12,
        label: const Text('Command', style: TextStyle(color: Colors.white)),
      ),
      items: const [
        DropdownMenuItem(
          value: 'auth',
          child: Row(
            children: [
              Icon(Icons.password, color: Colors.tealAccent),
              SizedBox(width: 10.0),
              Text(
                'auth',
                style: TextStyle(color: Colors.tealAccent),
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'ifconfig_up',
          child: Row(
            children: [
              Icon(Icons.password, color: Colors.tealAccent),
              SizedBox(width: 10.0),
              Text(
                'Start IfConfig',
                style: TextStyle(color: Colors.tealAccent),
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'thread_start',
          child: Row(
            children: [
              Icon(Icons.password, color: Colors.tealAccent),
              SizedBox(width: 10.0),
              Text(
                'Start Thread',
                style: TextStyle(color: Colors.tealAccent),
              ),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value == 'auth') {
          commandController.text = value!;
          payloadController.text = 'secret_token_123';
        } else if (value == 'ifconfig_up') {
          commandController.text = value!;
          payloadController.text = 'test';
        } else if (value == 'thread_start') {
          commandController.text = value!;
          payloadController.text = 'test';
        } else {
          commandController.clear();
          payloadController.clear();
        }
      },
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _inputField(
      {required String labelText, required TextEditingController controller}) {
    return SizedBox(
      height: 50.0,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _sendButton({required BuildContext context, required bool isDisabled}) {
    return SizedBox(
      width: 108.0,
      child: Container(
        height: 108.0,
        decoration: BoxDecoration(
          gradient: isDisabled
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff202020),
              Color(0xff303030),
            ],
          )
              : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff0095ff),
              Color(0xff00ffa6),
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
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ElevatedButton(
          onPressed: isDisabled ? null : _sendMessage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.send,
                size: 50.0,
                color: isDisabled ? Colors.grey : Colors.white,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDisabled ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    print('Sending message: ${commandController.text} ${payloadController.text}');

    messageLogBloc.add(
      MessageLogSentMessageEvent(commandController.text, payloadController.text),
    );

    payloadController.clear();
  }
}