class QuicklitTimer {
  static Stopwatch stopwatch = Stopwatch();
  static void start() => stopwatch.start();
  static void stop() => stopwatch.stop();
  static void reset() => stopwatch.reset();
  static int elapsedSeconds() => stopwatch.elapsed.inSeconds;
}
