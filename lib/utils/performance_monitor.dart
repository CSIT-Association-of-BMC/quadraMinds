import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static final Map<String, Stopwatch> _stopwatches = {};
  static final Map<String, List<int>> _metrics = {};

  // Start timing an operation
  static void startTimer(String operationName) {
    final stopwatch = Stopwatch()..start();
    _stopwatches[operationName] = stopwatch;
    debugPrint('PerformanceMonitor: Started timing $operationName');
  }

  // Stop timing and record the result
  static int stopTimer(String operationName) {
    final stopwatch = _stopwatches[operationName];
    if (stopwatch == null) {
      debugPrint('PerformanceMonitor: No timer found for $operationName');
      return 0;
    }

    stopwatch.stop();
    final elapsedMs = stopwatch.elapsedMilliseconds;
    
    // Store the metric
    _metrics[operationName] ??= [];
    _metrics[operationName]!.add(elapsedMs);
    
    debugPrint('PerformanceMonitor: $operationName completed in ${elapsedMs}ms');
    
    // Remove the stopwatch
    _stopwatches.remove(operationName);
    
    return elapsedMs;
  }

  // Get average time for an operation
  static double getAverageTime(String operationName) {
    final times = _metrics[operationName];
    if (times == null || times.isEmpty) return 0.0;
    
    final sum = times.reduce((a, b) => a + b);
    return sum / times.length;
  }

  // Get the last recorded time for an operation
  static int getLastTime(String operationName) {
    final times = _metrics[operationName];
    if (times == null || times.isEmpty) return 0;
    return times.last;
  }

  // Check if operation is within target time
  static bool isWithinTarget(String operationName, int targetMs) {
    final lastTime = getLastTime(operationName);
    return lastTime > 0 && lastTime <= targetMs;
  }

  // Get performance report
  static Map<String, dynamic> getReport() {
    final report = <String, dynamic>{};
    
    for (final entry in _metrics.entries) {
      final operationName = entry.key;
      final times = entry.value;
      
      if (times.isNotEmpty) {
        final sum = times.reduce((a, b) => a + b);
        final average = sum / times.length;
        final min = times.reduce((a, b) => a < b ? a : b);
        final max = times.reduce((a, b) => a > b ? a : b);
        
        report[operationName] = {
          'count': times.length,
          'average': average.round(),
          'min': min,
          'max': max,
          'last': times.last,
          'total': sum,
        };
      }
    }
    
    return report;
  }

  // Clear all metrics
  static void clearMetrics() {
    _metrics.clear();
    _stopwatches.clear();
    debugPrint('PerformanceMonitor: All metrics cleared');
  }

  // Log performance report
  static void logReport() {
    final report = getReport();
    debugPrint('PerformanceMonitor Report:');
    for (final entry in report.entries) {
      final name = entry.key;
      final data = entry.value as Map<String, dynamic>;
      debugPrint('  $name: avg=${data['average']}ms, min=${data['min']}ms, max=${data['max']}ms, count=${data['count']}');
    }
  }
}
