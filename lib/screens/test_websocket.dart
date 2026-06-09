import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class TestWebSocketScreen extends StatefulWidget {
  const TestWebSocketScreen({super.key});

  @override
  State<TestWebSocketScreen> createState() => _TestWebSocketScreenState();
}

class _TestWebSocketScreenState extends State<TestWebSocketScreen> {
  final TextEditingController _orderCodeController = TextEditingController();
  WebSocketChannel? _channel;
  String _status = 'Not connected';
  String _log = '';

  void _connect() {
    final orderCode = _orderCodeController.text.trim();
    if (orderCode.isEmpty) return;

    final wsUrl = 'ws://192.168.255.219:8080/app/orders.$orderCode?app_key=medimeal-key';
    _addLog('Connecting to: $wsUrl');
    
    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(wsUrl));
      _addLog('Connected!');
      setState(() => _status = 'Connected');
      
      _channel!.stream.listen((message) {
        _addLog('Received: $message');
        setState(() => _status = message);
      }, onError: (error) {
        _addLog('Error: $error');
        setState(() => _status = 'Error');
      }, onDone: () {
        _addLog('Disconnected');
        setState(() => _status = 'Disconnected');
      });
    } catch (e) {
      _addLog('Exception: $e');
    }
  }

  void _disconnect() {
    _channel?.sink.close();
    _channel = null;
    setState(() => _status = 'Disconnected');
  }

  void _addLog(String msg) {
    setState(() {
      _log = '$msg\n$_log';
    });
    print(msg);
  }

  @override
  void dispose() {
    _disconnect();
    _orderCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test WebSocket'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _orderCodeController,
              decoration: const InputDecoration(
                labelText: 'Order Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(onPressed: _connect, child: const Text('Connect')),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: _disconnect, child: const Text('Disconnect')),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade200,
              child: Text('Status: $_status'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black87,
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    _log,
                    style: const TextStyle(color: Colors.green, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}