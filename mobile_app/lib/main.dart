import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const BridgeApp());

class BridgeApp extends StatelessWidget {
  const BridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'monospace',
            color: Colors.greenAccent,
          ),
        ),
      ),
      home: const TerminalScreen(),
    );
  }
}

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  // CONFIGURATION: Replace with your PC's Local IP from 'ipconfig'
  final String pcIp = "192.168.1.XX";

  List<String> files = [];
  List<String> logs = ["System initialized. Ready to connect..."];
  bool isLoading = false;

  void addLog(String message) {
    setState(
      () => logs.insert(
        0,
        "[${DateTime.now().toString().split(' ')[1].substring(0, 8)}] $message",
      ),
    );
  }

  Future<void> fetchFiles() async {
    setState(() => isLoading = true);
    addLog("Connecting to $pcIp:8000...");

    try {
      final response = await http
          .get(Uri.parse('http://$pcIp:8000/files'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          files = List<String>.from(data['files']);
        });
        addLog("Success: Found ${files.length} files.");
      } else {
        addLog("Error: Server returned status ${response.statusCode}");
      }
    } catch (e) {
      addLog("Connection Failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ROOT@BRIDGE_APP:~# ls ./pc_files",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // FILE LIST AREA
              Expanded(
                flex: 2,
                child: files.isEmpty
                    ? const Center(child: Text("-- NO FILES LOADED --"))
                    : ListView.builder(
                        itemCount: files.length,
                        itemBuilder: (context, i) => Text("> ${files[i]}"),
                      ),
              ),

              const Divider(color: Colors.greenAccent),
              const Text(
                "SYSTEM_LOGS:",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              // LOG AREA
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, i) => Text(
                    logs[i],
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
              ),

              // ACTION BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.withOpacity(0.2),
                  ),
                  onPressed: isLoading ? null : fetchFiles,
                  child: Text(
                    isLoading ? "EXECUTING..." : "FETCH FILES",
                    style: const TextStyle(color: Colors.greenAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
