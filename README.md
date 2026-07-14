# Build Time Analyzer ⏱️

A production-ready Flutter performance analysis plugin that identifies expensive widget builds, excessive rebuild frequencies, and frame performance bottlenecks during development.

**Zero overhead in Release mode.** Built to help you find and fix jank before your users experience it.

---

## 🌟 Features

* **Widget Build Time Tracking**: Measure exact milliseconds spent building specific widgets.
* **Rebuild Counter**: Identify widgets that are rebuilding too frequently.
* **Frame Analysis**: Track FPS, build duration, and raster duration per frame.
* **Slow Widget Detection**: Configurable thresholds to highlight slow builds.
* **Zero Release Overhead**: Automatically disables itself in `kReleaseMode`.

---

## 🚀 Quick Start

### 1. Install the package

Add `build_time_analyzer` to your `pubspec.yaml`:

```yaml
dependencies:
  build_time_analyzer: ^0.0.1
```

### 2. Initialize the Analyzer

Wrap your root application with `BuildTimeAnalyzer`. It's safe to leave this in production code; it completely disables itself in Release builds.

```dart
import 'package:flutter/material.dart';
import 'package:build_time_analyzer/build_time_analyzer.dart';

void main() {
  // Initialize global frame tracking
  BuildTimeAnalyzer.initialize();
  
  runApp(
    BuildTimeAnalyzer(
      showOverlay: true,
      threshold: Duration(milliseconds: 5),
      child: const MyApp(),
    ),
  );
}
```

### 3. Track Specific Widgets

To measure the precise build time of a specific widget, wrap it with `TrackedWidget`.

```dart
class HeavyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TrackedWidget(
      name: 'HeavyWidget',
      child: Container(
        // Your complex UI here
      ),
    );
  }
}
```

---

## 📊 How it Works

The analyzer runs only in **Debug** and **Profile** modes.

* `BuildTimeAnalyzer.initialize()` hooks into the Flutter `SchedulerBinding` to measure frame rasterization and build times.
* `TrackedWidget` uses high-precision timers during the `build` phase to measure exact execution duration.
* Data is aggregated in the singleton `AnalyzerRecorder`.

---

## ⚙️ Configuration

The `BuildTimeAnalyzer` widget accepts several parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enabled` | `bool` | `true` | Manually toggle the analyzer on or off. |
| `showOverlay`| `bool` | `true` | Show the in-app performance dashboard and heatmaps. |
| `threshold` | `Duration` | `5ms` | The threshold above which a build is considered "slow". |
| `exportPath`| `String?`| `null` | Optional path to automatically export performance reports. |

---

## 💡 Optimization Suggestions

If the analyzer flags a widget, consider these common fixes:
* **High Rebuild Count**: Use `const` constructors where possible, or isolate state using `Selector` or `Provider`.
* **Long Build Time**: Break the widget down into smaller, granular widgets.
* **Expensive Layouts**: Avoid deep nested rows/columns. Consider `CustomMultiChildLayout` or simplifying the tree.

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
