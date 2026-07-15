import 'dart:ui';
import 'package:flutter/material.dart';
import 'analyzer_recorder.dart';


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
  final ValueNotifier<bool> _isExpanded = ValueNotifier(false);

  @override
  void dispose() {
    _isExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showOverlay) return widget.child;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            bottom: 40,
            right: 20,
            child: MediaQuery(
              data: const MediaQueryData(),
              child: Material(
                  color: Colors.transparent,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isExpanded,
                    builder: (context, isExpanded, child) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        width: isExpanded ? 340 : 64,
                        height: isExpanded ? 500 : 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isExpanded ? 24 : 32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 24,
                          spreadRadius: 4,
                          offset: const Offset(0, 12),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isExpanded ? 24 : 32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161622).withOpacity(0.75),
                            borderRadius: BorderRadius.circular(isExpanded ? 24 : 32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1.5,
                            ),
                          ),
                          child: isExpanded 
                              ? OverflowBox(
                                  minWidth: 340, maxWidth: 340, 
                                  minHeight: 500, maxHeight: 500, 
                                  child: _buildExpandedView()
                                )
                              : _buildCollapsedView(),
                        ),
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
    );
  }

  Widget _buildCollapsedView() {
    return InkWell(
      onTap: () {
        _isExpanded.value = true;
        _printStatsToConsole();
      },
      splashColor: Colors.white24,
      highlightColor: Colors.white10,
      borderRadius: BorderRadius.circular(32),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Icon(Icons.speed_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  void _printStatsToConsole() {
    final stats = AnalyzerRecorder().widgetStats.values.toList();
    stats.sort((a, b) => b.totalBuildTime.compareTo(a.totalBuildTime));

    debugPrint('\n================ PERFORMANCE METRICS ================');
    if (stats.isEmpty) {
      debugPrint('No widgets tracked yet.');
    } else {
      for (final stat in stats) {
        final isSlow = stat.averageBuildTime > AnalyzerRecorder().thresholds.slowBuildThreshold;
        debugPrint(
          'Widget: ${stat.widgetName.padRight(20)} | '
          'Avg: ${stat.averageBuildTime.inMilliseconds.toString().padLeft(4)}ms | '
          'Max: ${stat.maxBuildTime.inMilliseconds.toString().padLeft(4)}ms | '
          'Builds: ${stat.buildCount}'
        );
        if (isSlow) {
          debugPrint(
            '  -> ⚠️  WHY IS THIS SLOW? Common causes: heavy synchronous computations, '
            'decoding large assets in build(), or deeply nested complex layouts. '
            'Consider moving work to initState(), compute(), or using const constructors.'
          );
        }
      }
    }
    debugPrint('=====================================================\n');
  }

  Widget _buildExpandedView() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: AnimatedBuilder(
            animation: AnalyzerRecorder(),
            builder: (context, _) {
              final stats = AnalyzerRecorder().widgetStats.values.toList();
              stats.sort((a, b) => b.totalBuildTime.compareTo(a.totalBuildTime));

              final jankyFrames = AnalyzerRecorder().frameRecords.where((f) => f.isJanky).length;
              final totalFrames = AnalyzerRecorder().frameRecords.length;

              return Column(
                children: [
                  if (totalFrames > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: jankyFrames > 0 
                              ? const Color(0xFFFF5252).withOpacity(0.1) 
                              : const Color(0xFF00E676).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: jankyFrames > 0 
                                ? const Color(0xFFFF5252).withOpacity(0.3) 
                                : const Color(0xFF00E676).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Frames Monitored: $totalFrames',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            Text(
                              'Janky: $jankyFrames',
                              style: TextStyle(
                                color: jankyFrames > 0 ? const Color(0xFFFF5252) : const Color(0xFF00E676),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: stats.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.analytics_outlined, 
                                  color: Colors.white.withOpacity(0.2), 
                                  size: 56,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No widgets tracked yet.\nWrap widgets with TrackedWidget.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6), 
                                    height: 1.5,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            itemCount: stats.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                  final stat = stats[index];
                  final isSlow = stat.averageBuildTime > AnalyzerRecorder().thresholds.slowBuildThreshold;
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSlow 
                            ? const Color(0xFFFF5252).withOpacity(0.3) 
                            : Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSlow 
                                  ? const Color(0xFFFF5252).withOpacity(0.15) 
                                  : const Color(0xFF00C6FF).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSlow ? Icons.warning_rounded : Icons.widgets_rounded,
                              color: isSlow ? const Color(0xFFFF5252) : const Color(0xFF00C6FF),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stat.widgetName, 
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildBadge(
                                      'Avg: ${stat.averageBuildTime.inMilliseconds}ms', 
                                      isSlow ? const Color(0xFFFF5252) : Colors.white70,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildBadge(
                                      'Max: ${stat.maxBuildTime.inMilliseconds}ms', 
                                      Colors.white54,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${stat.buildCount}',
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'builds',
                                style: TextStyle(
                                  color: Colors.white54, 
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                            ],
                          ),
                          if (isSlow) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5252).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.2)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline, color: Color(0xFFFF5252), size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Why is this slow?\nThis widget takes too long to build. Common causes include synchronous heavy computations, decoding large assets in build(), or deeply nested complex layouts. Consider moving work to initState(), compute(), or using const constructors.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color, 
          fontSize: 11, 
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.06),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              const Text(
                'Performance', 
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.w700, 
                  fontSize: 17,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 22),
              splashRadius: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onPressed: () => _isExpanded.value = false,
              hoverColor: Colors.white10,
              highlightColor: Colors.white10,
            ),
          ),
        ],
      ),
    );
  }
}
