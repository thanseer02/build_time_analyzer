# Widget Time Checker ⏱️

A production-ready Flutter performance analysis plugin that identifies expensive widget builds, excessive rebuild frequencies, and frame performance bottlenecks during development.

**Zero overhead in Release mode.** Built to help you find and fix jank before your users experience it.

---

## 🌟 Features

* **Premium In-App Dashboard**: A sleek, glassmorphic UI overlay that tracks widget builds in real-time.
* **Widget Build Time Tracking**: Measure exact milliseconds spent building specific widgets.
* **Rebuild Counter**: Identify widgets that are rebuilding too frequently.
* **Janky Frame Tracking**: Monitor frame rasterization and build times, with live counts in the dashboard.
* **Actionable Insights**: The dashboard and debug console will explain exactly *why* a widget is slow and offer actionable tips to fix it.
* **Console Logging**: All metrics automatically print out clean, tabulated data to your debug console.
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
      threshold: Duration(milliseconds: 15),
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

## 📱 The Dashboard Overlay

When `showOverlay: true` is set, a speed icon will float in the bottom right corner of your app. Tapping it reveals a premium dashboard containing:

1. **Janky Frames Banner**: A live counter at the top indicating how many frames took too long to build.
2. **Widget List**: A sorted list of all `TrackedWidget`s, detailing their Average Build Time, Max Build Time, and Total Builds.
3. **Slow Widget Alerts**: If a widget exceeds the `slowBuildThreshold`, it is highlighted in red. The UI will expand to give you common reasons for the slow build (e.g., synchronous computations, deep nesting) to help you fix it immediately!

*Note: Tapping the overlay also dumps a nicely formatted table of these metrics directly into your IDE's debug console.*

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
| `showOverlay`| `bool` | `true` | Show the in-app performance dashboard. |
| `threshold` | `Duration` | `5ms` | The threshold above which a build is considered "slow". |
| `exportPath`| `String?`| `null` | Optional path to automatically export performance reports. |

---

## 💡 Optimization Suggestions

If the analyzer flags a widget as slow, consider these common fixes:
* **High Rebuild Count**: Use `ValueNotifier` or `ValueListenableBuilder` to selectively update only the widgets that need to change, instead of calling `setState` at the top of your tree. 
* **Long Build Time**: Move heavy synchronous operations (like parsing JSON) to `initState()` or background isolates via `compute()`.
* **Expensive Layouts**: Avoid deeply nested rows/columns. Simplify the tree and use `const` constructors wherever possible.

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
