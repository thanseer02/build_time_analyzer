import 'package:flutter/material.dart';
import 'package:build_time_analyzer/build_time_analyzer.dart';

void main() {
  BuildTimeAnalyzer.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BuildTimeAnalyzer(
      showOverlay: true,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final List<ValueNotifier<int>> _itemCounters =
      List.generate(5, (_) => ValueNotifier<int>(0));

  @override
  void dispose() {
    for (var notifier in _itemCounters) {
      notifier.dispose();
    }
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: TrackedWidget(
        name: 'MainBody',
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TrackedWidget(
              name: 'HeaderSection',
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'Performance Tracker Demo',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            TrackedWidget(
              name: 'CounterSection',
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('You have pushed the button this many times:'),
                      Text(
                        '$_counter',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TrackedWidget(
              name: 'Extremely Slow Widget',
              child: Builder(
                builder: (context) {
                  // Simulate a heavy synchronous computation (e.g., parsing huge JSON, heavy math, synchronous IO)
                  final stopwatch = Stopwatch()..start();
                  while (stopwatch.elapsedMilliseconds < 100) {}

                  return Card(
                    color: Colors.red.shade100,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                          'This widget is INTENTIONALLY SLOW (100ms block)!'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            TrackedWidget(
              name: 'Partial Update Buttons',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _itemCounters[1].value++;
                      _itemCounters[2].value++;
                    },
                    child: const Text('Update 1 & 2'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _itemCounters[0].value++;
                      _itemCounters[3].value++;
                      _itemCounters[4].value++;
                    },
                    child: const Text('Update Rest'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TrackedWidget(
              name: 'ListSection',
              child: Column(
                children: List.generate(
                  5,
                  (index) => ValueListenableBuilder<int>(
                    valueListenable: _itemCounters[index],
                    builder: (context, value, child) {
                      final isIntentionallySlow = index == 1 || index == 2;
                      if (isIntentionallySlow) {
                        final stopwatch = Stopwatch()..start();
                        while (stopwatch.elapsedMilliseconds < 50) {}
                      }
                      
                      return TrackedWidget(
                        name: 'ListItem_$index',
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isIntentionallySlow ? Colors.red.shade100 : null,
                            child: Text('$index'),
                          ),
                          title: Text('Item $index'),
                          subtitle: Text(
                            isIntentionallySlow 
                                ? 'Updated $value times (SLOW build)' 
                                : 'Updated $value times (Fast build)'
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: TrackedWidget(
        name: 'IncrementButton',
        child: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
