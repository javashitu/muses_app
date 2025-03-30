// SocketIoClientApp
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../util/common_logger.dart';

class SocketIoClientApp extends StatelessWidget {
  const SocketIoClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SocketIoClientDemo(),
    );
  }
}

class SocketIoClientDemo extends StatefulWidget {
  const SocketIoClientDemo({super.key});

  @override
  State<SocketIoClientDemo> createState() => _SocketIoClientDemoState();
}

class _SocketIoClientDemoState extends State<SocketIoClientDemo> {
  final TextEditingController _controller = TextEditingController();
  late SocketIoClient socketIoClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Column(
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              icon: Icon(Icons.title),
              labelText: '输入发送的消息)',
            ),
          ),
          ElevatedButton(
            onPressed: _connect,
            child: const Text("链接"),
          ),
          ElevatedButton(
            onPressed: _emit,
            child: const Text("发送消息"),
          )
        ],
      )),
    );
  }

  _connect() {
    const String connectUrl = "";
    const String connectionId = "";
    const String roomId = "";
    const String token = "";
    socketIoClient = SocketIoClient(
        connectUrl: connectUrl,
        connectionId: connectionId,
        roomId: roomId,
        token: token,
        messageHandler: _dispatchMessage,
        closeHndler: _dispatchMessage);
    socketIoClient.connect();
  }

  _emit() {
    String message = _controller.text;
    socketIoClient.emit(message);
  }

  _dispatchMessage(data) {
    log.info("the rsp $data");
  }

  _closeHandler(data) {
    log.info("connection has closed");
  }
}

class SocketIoClient {
  final String connectUrl;
  final String connectionId;
  final String roomId;
  final String token;

  final Function messageHandler;
  final Function closeHndler;
  SocketIoClient(
      {required this.connectUrl,
      required this.connectionId,
      required this.roomId,
      required this.token,
      required this.messageHandler,
      required this.closeHndler});

  late Socket socket;
  connect() {
    Map<String, String> queryMap = {};
    queryMap.putIfAbsent("connectionId", () => connectionId);
    queryMap.putIfAbsent("roomId", () => roomId);
    queryMap.putIfAbsent("token", () => token);
    log.info("conenct socketio to server the queryMap $queryMap");
    socket = io(
        "$connectUrl/message",
        OptionBuilder()
            .setQuery(queryMap)
            .setTransports(['http', 'websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            // .setExtraHeaders({'foo': 'bar'}) // optional
            .build());
    socket.connect();
    socket.onConnect((_) {
      log.info('connect socket io success');
    });
    socket.on('rsp', (data) {
      log.info("receive the server message  ${jsonEncode(data)}");
      messageHandler(data);
    });
    socket.onDisconnect((_) {
      log.info('socketio client disconnect');
      closeHndler();
    });
  }

  emit(dynamic message) {
    log.info("emit to server the message ${message}");
    socket.emit("message", message);
  }

  close(dynamic closeMessage) {
    if (socket.active && closeMessage != null) {
      emit(closeMessage);
    }
    socket.close();
  }

  closeQuietly() {
    if (socket.active) {
      socket.close();
    }
  }
}
