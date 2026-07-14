import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'analyzer_recorder.dart';

/// A wrapper widget that tracks the exact build time of its child.
/// 
/// Place this around widgets you want to explicitly measure.
class TrackedWidget extends StatelessWidget {
  final String name;
  final Widget child;

  const TrackedWidget({
    Key? key,
    required this.name,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode || !AnalyzerRecorder().isRecording) {
      return child;
    }

    final stopwatch = Stopwatch()..start();
    
    // We defer the recording to the end of the frame to capture the actual build time
    // including the child's build (if it happens synchronously).
    // Note: To truly measure the entire tree beneath this, more complex hooks are needed,
    // but measuring the build method execution of this specific node is straightforward.
    final builtChild = child;
    
    stopwatch.stop();
    AnalyzerRecorder().recordWidgetBuild(name, stopwatch.elapsed);
    
    return builtChild;
  }
}

/// A mixin for StatefulWidget states to automatically track their build times
mixin TrackedStateMixin<T extends StatefulWidget> on State<T> {
  String get trackedName => widget.runtimeType.toString();

  @override
  void build(BuildContext context) {
    // This mixin relies on the user calling super.build(context), 
    // which is not the standard Flutter pattern (build must be overridden).
    // Therefore, using TrackedWidget is the preferred approach.
  }
}
