import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/app.dart';
import 'package:musicpod/core/catalog.dart';
import 'package:musicpod/core/controller.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await (FontLoader(
      'Roboto',
    )..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))).load();
  });
  for (final size in [
    const Size(428, 926),
    const Size(360, 780),
    const Size(320, 690),
  ]) {
    testWidgets('All 26 screens render at ${size.width.toInt()}px', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = AppController(persist: false, audioEnabled: false);
      await tester.pumpWidget(MusicPodApp(controller: c, autoAdvance: false));
      final issues = <String>[];
      for (final screen in AppScreen.values) {
        c.go(screen);
        await tester.pumpAndSettle();
        final error = tester.takeException();
        if (error != null) issues.add('${screen.name}: $error');
      }
      expect(issues, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
    });
  }

  testWidgets('Search opens from browse and updates visible results', (
    tester,
  ) async {
    final c = AppController(persist: false, audioEnabled: false)..selectTab(1);
    await tester.pumpWidget(MusicPodApp(controller: c, autoAdvance: false));
    await tester.tap(find.byType(TextField), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(c.screen, AppScreen.searchResults);
    await tester.enterText(find.byType(TextField), 'Adele');
    await tester.pumpAndSettle();
    expect(c.query, 'Adele');
    expect(find.text('Hello'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no such song');
    await tester.pumpAndSettle();
    expect(find.textContaining('No results'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    c.dispose();
  });

  testWidgets('Skip stays tappable above the signup scroll area', (
    tester,
  ) async {
    final c = AppController(persist: false, audioEnabled: false)
      ..go(AppScreen.signup);
    await tester.pumpWidget(MusicPodApp(controller: c, autoAdvance: false));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(c.screen, AppScreen.home);
    expect(c.onboarded, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    c.dispose();
  });

  testWidgets('Signup validates phone and PIN before entering home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(428, 926);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = AppController(persist: false, audioEnabled: false)
      ..go(AppScreen.signup);
    await tester.pumpWidget(MusicPodApp(controller: c, autoAdvance: false));
    await tester.tap(find.text('Send Verification PIN'));
    await tester.pumpAndSettle();
    expect(c.screen, AppScreen.signup);
    await tester.enterText(
      find.byKey(const ValueKey('phone-field')),
      '8493856738',
    );
    await tester.tap(find.text('Send Verification PIN'));
    await tester.pumpAndSettle();
    expect(c.screen, AppScreen.otp);
    await tester.enterText(find.byKey(const ValueKey('otp-field')), '0000');
    await tester.tap(find.text('Verify PIN'));
    await tester.pumpAndSettle();
    expect(c.screen, AppScreen.otp);
    await tester.enterText(find.byKey(const ValueKey('otp-field')), '1234');
    await tester.tap(find.text('Verify PIN'));
    await tester.pumpAndSettle();
    expect(c.screen, AppScreen.home);
    expect(c.onboarded, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    c.dispose();
  });
}
