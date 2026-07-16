import 'package:flutter/material.dart';
import 'package:build_time_analyzer/build_time_analyzer.dart';

class LivePerformancePanel extends StatelessWidget {
  const LivePerformancePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AnalyzerRecorder(),
      builder: (context, _) {
        final recorder = AnalyzerRecorder();
        if (!recorder.isRecording || recorder.frameRecords.isEmpty) {
          return const SizedBox.shrink();
        }

        final lastFrame = recorder.frameRecords.last;
        final stats = recorder.widgetStats.values;
        final trackedCount = stats.length;

        int slowCount = 0;
        double totalBuildMs = 0;
        int totalBuilds = 0;

        for (final stat in stats) {
          if (stat.averageBuildTime.inMilliseconds > 16) {
            slowCount++;
          }
          totalBuildMs += stat.totalBuildTime.inMicroseconds / 1000;
          totalBuilds += stat.buildCount;
        }

        final avgBuildTime =
            totalBuilds > 0 ? (totalBuildMs / totalBuilds) : 0.0;
        final droppedFrames = recorder.frameRecords
            .where((f) => f.status == FrameStatus.jank)
            .length;

        return Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Card(
            elevation: 8,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Live Performance',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatColumn('FPS', '${lastFrame.fps}', context),
                      _StatColumn('Tracked', '$trackedCount', context),
                      _StatColumn('Slow', '$slowCount', context),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatColumn('Avg Build',
                          '${avgBuildTime.toStringAsFixed(1)}ms', context),
                      _StatColumn('Dropped', '$droppedFrames', context),
                      _StatColumn('Frame', '${lastFrame.frameNumber}', context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;

  const _StatColumn(this.label, this.value, this.context);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.8))),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
