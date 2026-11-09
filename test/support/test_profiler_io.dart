import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

/// Test-only workaround for the Windows Dart 3.13.5 profiler crash:
/// https://github.com/dart-lang/sdk/issues/64627
/// Opt in with `flutter test --enable-vmservice`. No SDK files or app flags change.
Future<void> configureTestProfiler() async {
  if (!Platform.isWindows || !Platform.version.startsWith('3.13.5')) return;
  final service = await developer.Service.getInfo();
  final base = service.serverUri;
  if (base == null) return;
  final client = HttpClient()..findProxy = (_) => 'DIRECT';
  try {
    final request = await client.getUrl(
      base
          .resolve('setFlag')
          .replace(queryParameters: {'name': 'profiler', 'value': 'false'}),
    );
    final response = await request.close();
    final data =
        jsonDecode(await utf8.decoder.bind(response).join())
            as Map<String, dynamic>;
    if ((data['result'] as Map?)?['type'] != 'Success') {
      throw StateError('Could not apply the Windows test profiler workaround.');
    }
    // Never print the local debugger URI or its authentication code.
    stdout.writeln(
      'Windows test profiler workaround enabled (Dart SDK #64627).',
    );
  } finally {
    client.close(force: true);
  }
}
