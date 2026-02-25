import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(title: const Text("Responsive Layout")),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: isLargeScreen
            ? Row(
                children: [
                  Expanded(child: buildLeftPanel()),
                  const SizedBox(width: 16),
                  Expanded(child: buildRightPanel()),
                ],
              )
            : Column(
                children: [
                  buildLeftPanel(),
                  const SizedBox(height: 16),
                  buildRightPanel(),
                ],
              ),
      ),
    );
  }

  Widget buildLeftPanel() {
    return Container(
      height: 200,
      color: Colors.blueAccent,
      child: const Center(
        child: Text(
          "Left Panel",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  Widget buildRightPanel() {
    return Container(
      height: 200,
      color: Colors.green,
      child: const Center(
        child: Text(
          "Right Panel",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}