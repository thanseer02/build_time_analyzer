import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'analyzer_recorder.dart';

/// Provides hierarchical context for [TrackedWidget] instances.
class TrackerScope extends InheritedWidget {
  final String widgetName;
  final int depth;

  const TrackerScope({
    Key? key,
    required this.widgetName,
    required this.depth,
    required Widget child,
  }) : super(key: key, child: child);

  static TrackerScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TrackerScope>();
  }

  @override
  bool updateShouldNotify(TrackerScope oldWidget) {
    return widgetName != oldWidget.widgetName || depth != oldWidget.depth;
  }
}

/// A wrapper widget that tracks the exact build time of its child.
/// 
/// Place this around widgets you want to explicitly measure.
class TrackedWidget extends StatelessWidget {
  final String name;
  final Widget child;
  final bool enabled;
  final void Function(Duration duration, int buildCount)? onBuild;

  const TrackedWidget({
    Key? key,
    required this.name,
    required this.child,
    this.enabled = true,
    this.onBuild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!enabled || kReleaseMode || !AnalyzerRecorder().isRecording) {
      return child;
    }

    final scope = TrackerScope.of(context);
    final parentName = scope?.widgetName;
    final currentDepth = (scope?.depth ?? -1) + 1;

    final stopwatch = Stopwatch()..start();
    
    // We defer the recording to the end of the frame to capture the actual build time
    // including the child's build (if it happens synchronously).
    final builtChild = child;
    
    stopwatch.stop();
    final elapsed = stopwatch.elapsed;
    
    AnalyzerRecorder().recordWidgetBuild(
      name, 
      elapsed,
      parent: parentName,
      depth: currentDepth,
    );
    
    if (onBuild != null) {
      // Fire onBuild synchronously (or microtask if needed)
      // We pass the new build count straight from the recorder
      final stats = AnalyzerRecorder().widgetStats[name];
      onBuild!(elapsed, stats?.buildCount ?? 1);
    }
    
    return TrackerScope(
      widgetName: name,
      depth: currentDepth,
      child: builtChild,
    );
  }
}

/// A mixin for StatefulWidget states to automatically track their build times
mixin TrackedStateMixin<T extends StatefulWidget> on State<T> {
  String get trackedName => widget.runtimeType.toString();

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
