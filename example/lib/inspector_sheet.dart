import 'package:flutter/material.dart';
import 'package:build_time_analyzer/build_time_analyzer.dart';

class WidgetInspectorSheet extends StatelessWidget {
  final String widgetName;

  const WidgetInspectorSheet({Key? key, required this.widgetName})
      : super(key: key);

  static void show(BuildContext context, String widgetName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WidgetInspectorSheet(widgetName: widgetName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AnalyzerRecorder(),
      builder: (context, child) {
        final stat = AnalyzerRecorder().widgetStats[widgetName];

        if (stat == null) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No data for this widget yet.')),
          );
        }

        final lastMs =
            (stat.lastDuration.inMicroseconds / 1000).toStringAsFixed(2);
        final avgMs =
            (stat.averageBuildTime.inMicroseconds / 1000).toStringAsFixed(2);
        final maxMs =
            (stat.maxBuildTime.inMicroseconds / 1000).toStringAsFixed(2);

        String statusText;
        Color statusColor;
        final avg = stat.averageBuildTime.inMilliseconds;
        if (avg < 5) {
          statusText = '🟢 Healthy';
          statusColor = Colors.green;
        } else if (avg < 16) {
          statusText = '🟡 Moderate';
          statusColor = Colors.yellow[700]!;
        } else if (avg < 25) {
          statusText = '🟠 Slow';
          statusColor = Colors.orange;
        } else {
          statusText = '🔴 Very Slow';
          statusColor = Colors.red;
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Widget Details',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Divider(height: 32),
                _buildRow(context, 'Widget Name', widgetName, isBold: true),
                _buildRow(context, 'Build Time', '$lastMs ms'),
                _buildRow(context, 'Average Build', '$avgMs ms'),
                _buildRow(context, 'Maximum Build', '$maxMs ms'),
                _buildRow(context, 'Rebuild Count', '${stat.buildCount}'),
                _buildRow(
                    context, 'Parent Widget', stat.parentWidget ?? 'None'),
                _buildRow(context, 'Widget Depth', '${stat.depth}'),
                _buildRow(context, 'Status', statusText,
                    valueColor: statusColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey[600])),
          Text(value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                    color: valueColor,
                  )),
        ],
      ),
    );
  }
}
