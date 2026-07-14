import 'package:flutter/material.dart';
import 'analyzer_recorder.dart';
import 'performance_metrics.dart';

/// An in-app dashboard to display performance metrics recorded by the AnalyzerRecorder.
class DashboardOverlay extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const DashboardOverlay({
    Key? key,
    required this.child,
    this.showOverlay = true,
  }) : super(key: key);

  @override
  State<DashboardOverlay> createState() => _DashboardOverlayState();
}

class _DashboardOverlayState extends State<DashboardOverlay> {
  bool _isExpanded = false;
  Offset _position = const Offset(20, 20);

  @override
  Widget build(BuildContext context) {
    if (!widget.showOverlay) return widget.child;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            bottom: _position.dy,
            right: _position.dx,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _position = Offset(
                    _position.dx - details.delta.dx,
                    _position.dy - details.delta.dy,
                  );
                });
              },
              child: MediaQuery(
              data: const MediaQueryData(),
              child: Material(
                color: Colors.transparent,
                child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isExpanded ? 300 : 60,
                height: _isExpanded ? 400 : 60,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(_isExpanded ? 16 : 30),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _isExpanded 
                    ? OverflowBox(
                        minWidth: 300, maxWidth: 300, 
                        minHeight: 400, maxHeight: 400, 
                        child: _buildExpandedView()
                      )
                    : _buildCollapsedView(),
              ),
            ),
          ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedView() {
    return InkWell(
      onTap: () => setState(() => _isExpanded = true),
      borderRadius: BorderRadius.circular(30),
      child: const Center(
        child: Icon(Icons.speed, color: Colors.white),
      ),
    );
  }

  Widget _buildExpandedView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _isExpanded = false),
      child: Column(
      children: [
        _buildHeader(),
        Expanded(
          child: AnimatedBuilder(
            animation: AnalyzerRecorder(),
            builder: (context, _) {
              final stats = AnalyzerRecorder().widgetStats.values.toList();
              // Sort by total build time descending
              stats.sort((a, b) => b.totalBuildTime.compareTo(a.totalBuildTime));

              if (stats.isEmpty) {
                return const Center(
                  child: Text(
                    'No widgets tracked yet.\nWrap widgets with TrackedWidget.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: stats.length,
                itemBuilder: (context, index) {
                  final stat = stats[index];
                  final isSlow = stat.averageBuildTime > AnalyzerRecorder().thresholds.slowBuildThreshold;
                  
                  return ListTile(
                    title: Text(stat.widgetName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Avg: ${stat.averageBuildTime.inMilliseconds}ms | Max: ${stat.maxBuildTime.inMilliseconds}ms\nBuilds: ${stat.buildCount}',
                      style: TextStyle(color: isSlow ? Colors.redAccent : Colors.white70),
                    ),
                    isThreeLine: true,
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Performance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => setState(() => _isExpanded = false),
          ),
        ],
      ),
    );
  }
}
