import 'package:flutter/material.dart';
import 'screens/stateless_stateful_demo.dart';

void main() {
  runApp(const HustleHubApp());
}

class HustleHubApp extends StatelessWidget {
  const HustleHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HustleHub',
      home: const StatelessStatefulDemo(),
    );
  }
}

class WidgetTreeDemo extends StatefulWidget {
  const WidgetTreeDemo({super.key});

  @override
  State<WidgetTreeDemo> createState() => _WidgetTreeDemoState();
}

class _WidgetTreeDemoState extends State<WidgetTreeDemo> {
  int counter = 0;
  bool showMessage = true;

  void incrementCounter() {
    setState(() {
      counter++;
    });
  }

  void toggleMessage() {
    setState(() {
      showMessage = !showMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Widget Tree Demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Counter: $counter",
              style: const TextStyle(fontSize: 24),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: incrementCounter,
              child: const Text("Increment Counter"),
            ),

            const SizedBox(height: 20),

            if (showMessage)
              const Text(
                "Flutter Reactive UI!",
                style: TextStyle(fontSize: 18),
              ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: toggleMessage,
              child: const Text("Toggle Message"),
            ),
          ],
        ),
      ),
    );
  }
}