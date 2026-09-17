/// Performance Tracker - Track operation performance
class PerformanceTracker {
  static final PerformanceTracker _instance = PerformanceTracker._internal();
  factory PerformanceTracker() => _instance;
  PerformanceTracker._internal();

  final Map<String, DateTime> _startTimes = {};
  final Map<String, List<Duration>> _metrics = {};
  static const int _maxMetricsPerOperation = 100;

  /// Start tracking an operation
  static void startTrace(String name) {
    final instance = PerformanceTracker();
    instance._startTimes[name] = DateTime.now();
    print('⏱️ [PerformanceTracker] Started: $name');
  }

  /// End tracking an operation
  static void endTrace(String name) {
    final instance = PerformanceTracker();
    final startTime = instance._startTimes[name];
    
    if (startTime == null) {
      print('⚠️ [PerformanceTracker] No start time found for: $name');
      return;
    }

    final duration = DateTime.now().difference(startTime);
    instance._startTimes.remove(name);

    // Store metric
    if (!instance._metrics.containsKey(name)) {
      instance._metrics[name] = [];
    }
    
    instance._metrics[name]!.add(duration);
    
    // Keep only recent metrics
    if (instance._metrics[name]!.length > _maxMetricsPerOperation) {
      instance._metrics[name]!.removeAt(0);
    }

    // Log if slow
    if (duration.inMilliseconds > 1000) {
      print('🐌 [PerformanceTracker] SLOW: $name took ${duration.inMilliseconds}ms');
    } else {
      print('✅ [PerformanceTracker] Completed: $name in ${duration.inMilliseconds}ms');
    }
  }

  /// Get metrics for an operation
  static PerformanceMetrics? getMetrics(String name) {
    final instance = PerformanceTracker();
    final durations = instance._metrics[name];
    
    if (durations == null || durations.isEmpty) {
      return null;
    }

    return PerformanceMetrics(
      name: name,
      count: durations.length,
      average: _calculateAverage(durations),
      min: _calculateMin(durations),
      max: _calculateMax(durations),
      recent: durations.last,
    );
  }

  /// Get all metrics
  static Map<String, PerformanceMetrics> getAllMetrics() {
    final instance = PerformanceTracker();
    final result = <String, PerformanceMetrics>{};
    
    for (final name in instance._metrics.keys) {
      final metrics = getMetrics(name);
      if (metrics != null) {
        result[name] = metrics;
      }
    }
    
    return result;
  }

  /// Get slow operations (average > 1 second)
  static List<PerformanceMetrics> getSlowOperations() {
    final allMetrics = getAllMetrics();
    return allMetrics.values
        .where((m) => m.average.inMilliseconds > 1000)
        .toList()
      ..sort((a, b) => b.average.compareTo(a.average));
  }

  /// Clear all metrics
  static void clearMetrics() {
    final instance = PerformanceTracker();
    instance._metrics.clear();
    instance._startTimes.clear();
    print('🗑️ [PerformanceTracker] Metrics cleared');
  }

  /// Calculate average duration
  static Duration _calculateAverage(List<Duration> durations) {
    final totalMs = durations.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ durations.length);
  }

  /// Calculate minimum duration
  static Duration _calculateMin(List<Duration> durations) {
    return durations.reduce((a, b) => a < b ? a : b);
  }

  /// Calculate maximum duration
  static Duration _calculateMax(List<Duration> durations) {
    return durations.reduce((a, b) => a > b ? a : b);
  }

  /// Format duration for display
  static String formatDuration(Duration duration) {
    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    } else if (duration.inSeconds < 60) {
      return '${(duration.inMilliseconds / 1000).toStringAsFixed(2)}s';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
  }
}

/// Performance metrics for an operation
class PerformanceMetrics {
  final String name;
  final int count;
  final Duration average;
  final Duration min;
  final Duration max;
  final Duration recent;

  PerformanceMetrics({
    required this.name,
    required this.count,
    required this.average,
    required this.min,
    required this.max,
    required this.recent,
  });

  bool get isSlow => average.inMilliseconds > 1000;

  @override
  String toString() {
    return 'PerformanceMetrics(name: $name, count: $count, avg: ${PerformanceTracker.formatDuration(average)})';
  }
}
