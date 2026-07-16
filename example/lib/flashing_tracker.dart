import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:build_time_analyzer/build_time_analyzer.dart';
import 'inspector_sheet.dart';

class FlashingTrackedWidget extends StatefulWidget {
  final String name;
  final Widget child;
  final bool inspectable;

  const FlashingTrackedWidget({
    Key? key,
    required this.name,
    required this.child,
    this.inspectable = true,
  }) : super(key: key);

  @override
  State<FlashingTrackedWidget> createState() => _FlashingTrackedWidgetState();
}

class _FlashingTrackedWidgetState extends State<FlashingTrackedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Color _targetColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBuildFired(Duration duration, int buildCount) {
    if (kReleaseMode) return;

    final ms = duration.inMicroseconds / 1000;

    // Log the custom console block
    debugPrint('\n══════════════════════════════');
    debugPrint('Widget Rebuilt');
    debugPrint('══════════════════════════════');
    debugPrint('Widget\n${widget.name}\n');
    debugPrint('Build Time\n${ms.toStringAsFixed(2)} ms\n');
    final stat = AnalyzerRecorder().widgetStats[widget.name];
    if (stat != null) {
      debugPrint(
          'Average\n${(stat.averageBuildTime.inMicroseconds / 1000).toStringAsFixed(2)} ms\n');
    }
    debugPrint('Rebuild Count\n$buildCount\n');
    debugPrint('══════════════════════════════\n');

    // Trigger flash animation without calling setState to prevent infinite build loops!
    Color targetColor;
    if (ms < 5) {
      targetColor = Colors.green;
    } else if (ms < 16) {
      targetColor = Colors.yellow;
    } else if (ms < 25) {
      targetColor = Colors.orange;
    } else {
      targetColor = Colors.red;
    }

    _targetColor = targetColor;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward(from: 0.0);
      }
    });
  }

  void _showInspector() {
    WidgetInspectorSheet.show(context, widget.name);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = ColorTween(begin: _targetColor, end: Colors.transparent)
            .evaluate(
                CurvedAnimation(parent: _controller, curve: Curves.easeOut));

        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: color ?? Colors.transparent,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9), // Inner clip to prevent child corners sticking out
            child: child,
          ),
        );
      },
      child: TrackedWidget(
        name: widget.name,
        onBuild: _onBuildFired,
        child: widget.child,
      ),
    );

    if (widget.inspectable) {
      content = GestureDetector(
        onLongPress: _showInspector,
        child: Stack(
          children: [
            content,
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.info_outline,
                    color: Colors.blueGrey, size: 20),
                onPressed: _showInspector,
                tooltip: 'Inspect Widget',
              ),
            ),
          ],
        ),
      );
    }

    return content;
  }
}
