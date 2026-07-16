import 'package:flutter/material.dart';
import 'package:build_time_analyzer/build_time_analyzer.dart';
import 'demo_widgets.dart';
import 'live_panel.dart';
import 'flashing_tracker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Build Time Analyzer Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const DashboardOverlay(
        child: MyHomePage(title: 'Build Time Analyzer Demo'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Automatically start recording when the app launches
    AnalyzerRecorder().startRecording();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          FlashingTrackedWidget(
            name: 'MainBody',
            inspectable: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 200),
              children: const [
                CounterCard(),
                SizedBox(height: 16),
                RandomColorBox(),
                SizedBox(height: 16),
                TodoList(),
                SizedBox(height: 16),
                UnhealthyLagWidget(),
                SizedBox(height: 16),
                ProductGrid(),
              ],
            ),
          ),
          const LivePerformancePanel(),
        ],
      ),
    );
  }
}
