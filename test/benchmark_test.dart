import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _LineBoxKey = (TextStyle, TextDirection, TextScaler);
final _lineBoxCache = <_LineBoxKey, double>{};

double _ambientTextLineBox(TextStyle style, TextDirection textDirection, TextScaler textScaler) {
  final key = (style, textDirection, textScaler);

  final cached = _lineBoxCache[key];
  if (cached != null) {
    return cached;
  }

  if (_lineBoxCache.length >= 16) {
    _lineBoxCache.clear();
  }

  final painter = TextPainter(
    text: TextSpan(text: '', style: style),
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout();

  return _lineBoxCache[key] = painter.preferredLineHeight;
}

double _ambientTextLineBoxLRU(TextStyle style, TextDirection textDirection, TextScaler textScaler) {
  final key = (style, textDirection, textScaler);

  final cached = _lineBoxCache[key];
  if (cached != null) {
    // LRU: move to end
    _lineBoxCache.remove(key);
    _lineBoxCache[key] = cached;
    return cached;
  }

  if (_lineBoxCache.length >= 16) {
    _lineBoxCache.remove(_lineBoxCache.keys.first);
  }

  final painter = TextPainter(
    text: TextSpan(text: '', style: style),
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout();

  return _lineBoxCache[key] = painter.preferredLineHeight;
}

void main() {
  testWidgets('Benchmark cache eviction', (WidgetTester tester) async {
    final commonStyles = List.generate(15, (i) => TextStyle(fontSize: 10.0 + i));
    final rareStyles = List.generate(10, (i) => TextStyle(fontSize: 30.0 + i));
    final textDirection = TextDirection.ltr;
    final textScaler = TextScaler.noScaling;

    // Warmup
    for (int i = 0; i < 100; i++) {
      _ambientTextLineBox(commonStyles[0], textDirection, textScaler);
    }

    _lineBoxCache.clear();
    final watch1 = Stopwatch()..start();
    int misses1 = 0;
    for (int iter = 0; iter < 1000; iter++) {
      for (final style in commonStyles) {
        if (!_lineBoxCache.containsKey((style, textDirection, textScaler))) misses1++;
        _ambientTextLineBox(style, textDirection, textScaler);
      }
      final rare = rareStyles[iter % rareStyles.length];
      if (!_lineBoxCache.containsKey((rare, textDirection, textScaler))) misses1++;
      _ambientTextLineBox(rare, textDirection, textScaler);
    }
    watch1.stop();

    _lineBoxCache.clear();
    final watch2 = Stopwatch()..start();
    int misses2 = 0;
    for (int iter = 0; iter < 1000; iter++) {
      for (final style in commonStyles) {
        if (!_lineBoxCache.containsKey((style, textDirection, textScaler))) misses2++;
        _ambientTextLineBoxLRU(style, textDirection, textScaler);
      }
      final rare = rareStyles[iter % rareStyles.length];
      if (!_lineBoxCache.containsKey((rare, textDirection, textScaler))) misses2++;
      _ambientTextLineBoxLRU(rare, textDirection, textScaler);
    }
    watch2.stop();

    print('Current Strategy (Clear): ${watch1.elapsedMilliseconds} ms, misses: $misses1');
    print('LRU Strategy: ${watch2.elapsedMilliseconds} ms, misses: $misses2');
  });
}
