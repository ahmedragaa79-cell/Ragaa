@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Arabic catalogs contain the same nonempty messages', () {
    Map<String, dynamic> catalog(String locale) {
      final file = File('lib/app/localization/app_$locale.arb');
      return (jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)
        ..removeWhere((key, _) => key.startsWith('@'));
    }

    final en = catalog('en');
    final ar = catalog('ar');
    expect(ar.keys.toSet(), en.keys.toSet());
    for (final message in [...en.values, ...ar.values]) {
      expect(
        message,
        isA<String>().having((s) => s.trim().isNotEmpty, 'has text', true),
      );
    }
  });
}
