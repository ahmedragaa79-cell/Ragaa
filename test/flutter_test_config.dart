import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final (family, asset) in [
    ('Manrope', 'Manrope'),
    ('Noto Sans Arabic', 'NotoSansArabic'),
  ]) {
    final loader = FontLoader(family)
      ..addFont(rootBundle.load('assets/fonts/$asset.ttf'));
    await loader.load();
  }
  await testMain();
}
