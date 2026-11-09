import 'dart:async';
import 'support/test_profiler_stub.dart'
    if (dart.library.io) 'support/test_profiler_io.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await configureTestProfiler();
  await testMain();
}
