import 'package:flutter/widgets.dart';

// Bounded cache to prevent thrashing between multiple button styles on screen,
// while avoiding unbounded memory growth in apps with dynamic text styles.
typedef _LineBoxKey = (TextStyle, TextDirection, TextScaler);
final _lineBoxCache = <_LineBoxKey, double>{};

// A font that loads after a style was measured (google_fonts, FontLoader)
// changes its line box; the cache is cleared on every system font change.
var _lineBoxCacheListensToFonts = false;

/// The bounded line-box cache, most recently used last.
@visibleForTesting
Map<(TextStyle, TextDirection, TextScaler), double> get debugLineBoxCache =>
    _lineBoxCache;

/// The single-line height of the ambient label style at [context] — the
/// vertical extent a one-line [Text] occupies here. The default spinner sizes
/// to this (the idle content's *line box*, which is taller than the raw
/// `fontSize`) so the button keeps its idle height while loading instead of
/// shrinking. Honours the ambient [TextScaler], matching how the label scales.
double ambientTextLineBox(BuildContext context) {
  if (!_lineBoxCacheListensToFonts) {
    _lineBoxCacheListensToFonts = true;
    PaintingBinding.instance.systemFonts.addListener(_lineBoxCache.clear);
  }
  final style = DefaultTextStyle.of(context).style;
  final textDirection = Directionality.of(context);
  final textScaler = MediaQuery.textScalerOf(context);
  final key = (style, textDirection, textScaler);

  final cached = _lineBoxCache.remove(key);
  if (cached != null) {
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
  final lineBox = painter.preferredLineHeight;
  painter.dispose();

  return _lineBoxCache[key] = lineBox;
}
