import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'performance_metrics.dart';

class AnalyzerLogger {
  static const String _name = 'BuildTimeAnalyzer';

  static void info(String message) {
    if (kReleaseMode) return;
    developer.log(message, name: _name, level: 0);
  }

  static void warning(String message) {
    if (kReleaseMode) return;
    developer.log(message, name: _name, level: 900);
  }

  static void logFrameAnalysis(FrameRecord frame, Map<String, WidgetStats> stats) {
    if (kReleaseMode) return;

    final buffer = StringBuffer();
    buffer.writeln('========================================================');
    buffer.writeln('🚀 Build Time Analyzer');
    buffer.writeln('======================');
    buffer.writeln('Frame #${frame.frameNumber}');
    buffer.writeln('FPS               : ${frame.fps}');
    buffer.writeln('Build Time        : ${frame.buildDuration.inMicroseconds / 1000} ms');
    buffer.writeln('Raster Time       : ${frame.rasterDuration.inMicroseconds / 1000} ms');
    buffer.writeln('Total Frame       : ${frame.totalDuration.inMicroseconds / 1000} ms');
    buffer.writeln('Status            : ${frame.status.display}');
    buffer.writeln('---');
    
    if (stats.isNotEmpty) {
      buffer.writeln('Widgets Built');
      
      final roots = stats.values.where((s) => s.depth == 0 || s.parentWidget == null).toList();
      
      void printTree(WidgetStats stat, String prefix, bool isLast) {
        final ms = (stat.averageBuildTime.inMicroseconds / 1000).toStringAsFixed(2);
        final marker = stat.averageBuildTime.inMilliseconds >= 16 ? ' 🔴' : '';
        
        final branch = stat.depth == 0 ? '' : (isLast ? '└── ' : '├── ');
        final line = '$prefix$branch${stat.widgetName}';
        
        buffer.writeln('${line.padRight(40)} ${ms.padLeft(6)} ms$marker');
        
        final children = stats.values.where((s) => s.parentWidget == stat.widgetName).toList();
        for (int i = 0; i < children.length; i++) {
          final childPrefix = stat.depth == 0 ? '' : prefix + (isLast ? '    ' : '│   ');
          printTree(children[i], childPrefix, i == children.length - 1);
        }
      }

      for (int i = 0; i < roots.length; i++) {
        printTree(roots[i], '', i == roots.length - 1);
      }
      
      buffer.writeln('---');
    }

    info(buffer.toString());
  }

  static void logSlowBuild(WidgetStats stat) {
    if (kReleaseMode) return;

    final buffer = StringBuffer();
    buffer.writeln('Slow Widgets');
    buffer.writeln('🔴 ${stat.widgetName}');
    buffer.writeln('Average : ${(stat.averageBuildTime.inMicroseconds / 1000).toStringAsFixed(1)} ms');
    buffer.writeln('Maximum : ${(stat.maxBuildTime.inMicroseconds / 1000).toStringAsFixed(1)} ms');
    buffer.writeln('Build Count : ${stat.buildCount}');
    buffer.writeln('---');
    buffer.writeln('Suggestions');
    buffer.writeln('✓ Make ${stat.widgetName} const');
    buffer.writeln('✓ Replace Consumer with Selector');
    buffer.writeln('✓ Split ${stat.widgetName} into smaller widgets');
    buffer.writeln('✓ Wrap ${stat.widgetName} with RepaintBoundary');
    buffer.writeln('✓ Cache images');
    
    warning(buffer.toString());
  }

  static void logPerformanceSummary(
      int framesRecorded, 
      int averageFps, 
      double averageBuildTimeMs, 
      int droppedFrames, 
      int trackedWidgets, 
      int slowWidgets, 
      String worstWidgetName, 
      double worstWidgetAvgMs) {
    if (kReleaseMode) return;

    final buffer = StringBuffer();
    buffer.writeln('========================================================');
    buffer.writeln('Performance Summary');
    buffer.writeln('========================================================');
    buffer.writeln('Frames Recorded : $framesRecorded');
    buffer.writeln('Average FPS : $averageFps');
    buffer.writeln('Average Build Time : ${averageBuildTimeMs.toStringAsFixed(2)} ms');
    buffer.writeln('Dropped Frames : $droppedFrames');
    buffer.writeln('Tracked Widgets : $trackedWidgets');
    buffer.writeln('Slow Widgets : $slowWidgets');
    buffer.writeln('Worst Widget : $worstWidgetName');
    buffer.writeln('Average Build : ${worstWidgetAvgMs.toStringAsFixed(2)} ms');
    buffer.writeln('========================================================');
    
    info(buffer.toString());
  }
}
