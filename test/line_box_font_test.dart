// MAB-B9: the global line-box cache is keyed by TextStyle only; without
// invalidation on font load (google_fonts, FontLoader, deferred assets) a
// spinner measured before the font arrives stays mis-sized for the app's
// lifetime.
import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';

double freshLineBox(TextStyle style) {
  final p = TextPainter(
    text: TextSpan(text: '', style: style),
    textDirection: .ltr,
  )..layout();
  final h = p.preferredLineHeight;
  p.dispose();
  return h;
}

void main() {
  testWidgets('spinner re-measures after a late font load', (tester) async {
    debugLineBoxCache.clear();
    const style = TextStyle(fontFamily: 'LateFont', fontSize: 20);
    Widget host() => const MaterialApp(
      home: Material(
        child: Center(
          child: DefaultTextStyle(style: style, child: AsyncButtonSpinner()),
        ),
      ),
    );
    await tester.pumpWidget(host());
    final before = tester.getSize(find.byType(SizedBox).last).height;

    // The font arrives (google_fonts / FontLoader do exactly this).
    final root = Platform.environment['FLUTTER_ROOT'];
    if (root == null) fail('flutter test sets FLUTTER_ROOT');
    final bytes = File(
      '$root/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
    ).readAsBytesSync();
    await tester.runAsync(() async {
      final loader = FontLoader('LateFont')
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    });
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(host());
    final after = tester.getSize(find.byType(SizedBox).last).height;
    final truth = freshLineBox(style);
    check(
      because: 'before=$before after(cached)=$after fresh=$truth',
      after,
    ).equals(truth);
  });
}
