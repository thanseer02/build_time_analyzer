import 'dart:math';
import 'package:flutter/material.dart';
import 'flashing_tracker.dart';

// ==========================================
// Counter Card
// ==========================================
class CounterCard extends StatefulWidget {
  const CounterCard({Key? key}) : super(key: key);

  @override
  State<CounterCard> createState() => _CounterCardState();
}

class _CounterCardState extends State<CounterCard> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlashingTrackedWidget(
      name: 'CounterCard',
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Counter', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Current Value: $_counter',
                      style: const TextStyle(fontSize: 16)),
                  ElevatedButton(
                    onPressed: _increment,
                    child: const Text('Increment'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// Random Color Box
// ==========================================
class RandomColorBox extends StatefulWidget {
  const RandomColorBox({Key? key}) : super(key: key);

  @override
  State<RandomColorBox> createState() => _RandomColorBoxState();
}

class _RandomColorBoxState extends State<RandomColorBox> {
  Color _color = Colors.blue;

  void _changeColor() {
    setState(() {
      _color =
          Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlashingTrackedWidget(
      name: 'RandomColorBox',
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Random Color Box',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: _changeColor,
                    child: const Text('Change Color'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// Todo List
// ==========================================
class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<String> _tasks = ['Task 1', 'Task 2'];

  void _addTask() {
    setState(() {
      _tasks.add('Task ${_tasks.length + 1}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlashingTrackedWidget(
      name: 'TodoList',
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Todo List',
                      style: Theme.of(context).textTheme.titleLarge),
                  TextButton.icon(
                    onPressed: _addTask,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._tasks.map((task) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(task),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// Unhealthy Lag Widget
// ==========================================
class UnhealthyLagWidget extends StatefulWidget {
  const UnhealthyLagWidget({Key? key}) : super(key: key);

  @override
  State<UnhealthyLagWidget> createState() => _UnhealthyLagWidgetState();
}

class _UnhealthyLagWidgetState extends State<UnhealthyLagWidget> {
  int _rebuilds = 0;

  void _triggerLag() {
    setState(() {
      _rebuilds++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_rebuilds > 0) {
      final sw = Stopwatch()..start();
      while (sw.elapsedMilliseconds < 60) {}
    }

    return FlashingTrackedWidget(
      name: 'UnhealthyLagWidget',
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        color: Colors.red.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unhealthy Lag Widget',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.red.shade900)),
              const SizedBox(height: 8),
              Text(
                  'This widget intentionally blocks the main thread for 60ms when rebuilt. Watch the red flash and the console warning!',
                  style: TextStyle(color: Colors.red.shade900)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lag Rebuilds: $_rebuilds',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: _triggerLag,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    child: const Text('Trigger Lag'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// Product Grid
// ==========================================
class ProductGrid extends StatelessWidget {
  const ProductGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlashingTrackedWidget(
      name: 'ProductGrid',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('Product Grid',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              return ProductCard(index: index + 1);
            },
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final int index;
  const ProductCard({Key? key, required this.index}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _tapCount = 0;

  void _onTap() {
    setState(() {
      _tapCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // We intentionally make this widget artificially slow for demonstration
    if (widget.index == 2) {
      final sw = Stopwatch()..start();
      while (sw.elapsedMilliseconds < 20) {}
    }

    return FlashingTrackedWidget(
      name: 'ProductCard #${widget.index}',
      child: InkWell(
        onTap: _onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag, size: 40, color: Colors.blueGrey[300]),
              const SizedBox(height: 16),
              Text('Card ${widget.index}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Taps: $_tapCount',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
