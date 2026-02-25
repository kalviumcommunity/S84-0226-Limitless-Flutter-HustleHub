import 'package:flutter/material.dart';

class StatelessStatefulDemo extends StatelessWidget {
  const StatelessStatefulDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stateless & Stateful Demo")),
      body: const Center(
        child: DemoBody(),
      ),
    );
  }
}

// ------------------ STATELESS WIDGET ------------------

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Interactive Counter App",
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

// ------------------ STATEFUL WIDGET ------------------

class DemoBody extends StatefulWidget {
  const DemoBody({super.key});

  @override
  State<DemoBody> createState() => _DemoBodyState();
}

class _DemoBodyState extends State<DemoBody> {
  int counter = 0;

  void increment() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const HeaderWidget(), // Stateless Widget

        const SizedBox(height: 20),

        Text(
          "Count: $counter",
          style: const TextStyle(fontSize: 20),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: increment,
          child: const Text("Increase Counter"),
        ),
      ],
    );
  }
}