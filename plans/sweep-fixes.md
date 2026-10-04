---
status: in-progress
created: 2026-10-03
updated: 2026-10-04
---

# Plan: material_async_button 3.1.0 — sweep fixes, parity params, maintainSize + minLoadingDuration

Frontmatter `status` is the plan's lifecycle, one owner per transition: `draft` → `approved` (planner, on user approval, before commit) → `in-progress` (executor, before Phase 1) → deleted (executor's last commit, once every § Verification step ran and passed — one that couldn't run keeps it `in-progress`, logged to the § Found tracker). Plans are ephemeral: git is the archive. `outdated` — whoever finds § Files no longer matching the tree; an outdated plan is re-grounded or replaced, never executed. Every transition bumps `updated`.

## Progress

- [x] Phase 1: Loading button keeps its size (P0)
- [x] Phase 2: Fire-and-forget lint convention
- [x] Phase 3: Controller state machine
- [x] Phase 4: Variant fixes
- [x] Phase 5: Line-box measurement
- [x] Phase 6: Parity parameters
- [x] Phase 7: maintainSize + minLoadingDuration
- [ ] Phase 8: Repo meta, packaging, CI
- [ ] Phase 9: Docs, skill, example
- [ ] Phase 10: Release prep, push, CI

## Problem

Since 2.0.0 every non-FAB wrapper grows to fill its parent while loading; the controller double-runs or runs dead callbacks after `reset()`, unmount, swap or sharing; some variants lose the spinner; `.icon` constructors reject the documented `enabled:`; docs, skill and repo meta have drifted. 3.1.0 fixes all of it behind tests that failed first, and adds `maintainSize`, `minLoadingDuration` and the missing Material parameters.

## Invariants

- One library of `part` files (`lib/material_async_button.dart`): state↔controller wiring uses new library-private members, never new public API. Minor release, additive only: `AsyncButtonController.attach` and `debugLineBoxCache` stay public `@visibleForTesting`; no rename, removal or class-modifier change.
- Keep each file's Dart 3.13 constructor style (`class const X({...})`, `const new name({...})`); new parameters join those lists. Code below is shape, not layout — `dart format` reflows it.
- Loading never disables: the builder `callback` stays non-null while loading; only `enabled: false` / `onPressed: null` disable. Every `AsyncButtonTheme` field resolves widget → theme → built-in default.
- Maintainer rules: no `!`, no `unawaited(...)` (bare drop), no `late final`, comments only for traps/contracts; format tracked files only (`git ls-files -z -- '*.dart' | xargs -0 dart format`). Tests use `package:checks` + `test/_helpers.dart`; disposal errors are asserted `isA<Error>()` (beta throws `StateError` from `package:listen`, stable `FlutterError`).
- `analysis_options.yaml` is guarded by a PreToolUse hook (`~/.claude/hooks/config-protection.sh`). The edit this plan makes to it is a user-approved, deliberate config change (fleet decision X-17). In that step only: `touch .dart_tool/.config-edit-ok`, write the file, then `rm .dart_tool/.config-edit-ok` right away. Never use the marker for any other edit, and never leave it behind.
- `git-committer` commits **and pushes** by default. Every dispatch of it in this plan must say **"commit only, do not push"**, except the one push the final phase names. A phase commit must never reach the remote before that.

## Decisions

- Floor stays `sdk: ^3.13.0` / `flutter: ">=3.47.0"`, forward-only; release 3.1.0, floor first under `### Changed`. Commit directly on `main` (planner default) via the `git-committer` agent after each passing oracle (conventional commits); never publish, tag, create releases or change repo settings.
- `reset()` abandons the in-flight run: idle and re-armed at once (escape hatch for a hung future); the abandoned run's completion no longer touches state; a tap after `reset()` is a deliberate new run (planner default).
- One controller drives one mounted `AsyncButton`: a second binder fails a debug `assert`; release keeps last-binder-wins. Unbinding is owner-checked and happens in `deactivate()` (rebind in `activate()`). Swapping controllers mid-flight: the incoming controller adopts the in-flight future unless it is already loading. `trigger()` after `dispose()`: debug `assert`; release no-op (`dispose()` clears the callback).
- `maintainSize: true` overlays the loading view on the invisible idle child (footprint = max(idle, loading)); `.icon` constructors and non-collapsed `.extended` keep their icon visible under it (planner default). Default `false` keeps today's swap.
- `minLoadingDuration` holds loading at least that long from trigger start (tap or `controller.trigger()`); errors rethrow after the floor; default `Duration.zero` creates no timer. New theme fields snap in `lerp` at `t < 0.5`; `copyWith` cannot clear a field (documented, not changed). Default FAB `heroTag` sentinel: documented, not changed (planner default).
- `onPressed: null` + `onLongPress` gives an enabled button, as in Flutter (behaviour change, under `### Changed`; planner default). `isSemanticButton` only on `TextAsyncButton.new` (`TextButton.icon` has none); `IconAsyncButton.onLongPress` is gated only on loading (`IconButton` drops it when `onPressed == null`).
- Line-box cache: keep the bounded LRU; clear it from a `PaintingBinding.instance.systemFonts` listener registered once. CHANGELOG history stays as written (incl. the 2.0.0 `FlutterError.onError` claim) except the title and `### Breaking` capitalisation (planner default). The doc-snippet compile check is a scratch file, never committed (planner default). `bug_report.yaml` drops collection_notifiers' "What happened?" placeholder (planner default).

## Files

|Path|Action|Exact symbols|
|--|--|--|
|`lib/src/material_async_button_theme.dart`|modify|`AsyncButtonSpinner.build`; `_ambientTextLineBox`; new `_lineBoxCacheListensToFonts`; `AsyncButtonTheme` +`maintainSize`, +`minLoadingDuration`, `copyWith`, `lerp`, `==`, `hashCode`|
|`lib/src/async_button_controller.dart`|modify|new `_run`, `_inFlight`, `_owner`, `_minLoadingDuration`, `_bind`, `_unbind`, `_adopt`, `_settle`, `_withFloor`; `trigger`, `reset`, `dispose`|
|`lib/src/async_button.dart`|modify|`AsyncButton` +`maintainSize`, +`minLoadingDuration`; `_AsyncButtonState` `_bind`, `initState`, `didUpdateWidget`, `activate`, `deactivate`, `build`|
|`lib/src/buttons/async_material_button.dart`|modify|`AsyncMaterialButton` +2 params, `_resolveMaintainSize`; `AsyncStandardMaterialButton` +2 super params, `build`; `_loadingSizing` removed|
|`lib/src/buttons/{elevated,filled,outlined,text,icon,floating_action}_async_button.dart`|modify|all 18 constructors +2 params; `enabled` on the 5 `.icon`/`.tonalIcon`; `TextAsyncButton.isSemanticButton`; `IconAsyncButton` +`onHover`/`onLongPress`/`statesController`, `_buildIconButton`; FAB `build`, `_buildExtended`, `heroTag` doc|
|`test/{layout,icon_enabled,line_box_font}_test.dart`, `test/leak/{flutter_test_config,line_box_leak_test}.dart`|create|ported repros + feature oracles|
|`test/_helpers.dart`, `test/{async_button,async_button_controller,elevated_async_button,outlined_async_button,text_async_button,icon_async_button,floating_action_async_button,material_async_button_theme}_test.dart`|modify|ported repros, masking-test fixes, feature tests; `_helpers.dart`: delete `spinnerTextLineBox`, `asyncButtonTheme` +2 params, new `columnHost`|
|`pubspec.yaml`, `analysis_options.yaml`, `CHANGELOG.md`, `README.md`, `.github/workflows/ci.yaml`, `example/lib/main.dart`, `example/README.md`, `/Users/mehmetesen/pub-dev/SWEEP.md`|modify|see phases|
|`.pubignore`; `plans/sweep-fixes.md` (last commit)|delete|—|
|`.github/{dependabot.yml,PULL_REQUEST_TEMPLATE.md}`, `.github/ISSUE_TEMPLATE/{bug_report.yaml,feature_request.yaml,config.yml}`, `CONTRIBUTING.md`|create|fleet meta|
|`.github/workflows/publish.yaml`|create (restore)|deleted tag-publish workflow, tag trigger commented out|
|`skills/flutter-material-async-button/SKILL.md` → `skills/material-async-button-usage/SKILL.md`|`git mv` + modify|frontmatter, H1, drift|

Repros (copy allowed): `/Users/mehmetesen/pub-dev/sweep-2026-10-03/repros/material_async_button/`. "Theme file" = `lib/src/material_async_button_theme.dart`; "wrapper files" = `lib/src/buttons/*_async_button.dart`. Each phase adds its bullets under `## Unreleased` in `CHANGELOG.md` (sections `### Added`, `### Changed`, `### Fixed`).

## Phases

### Phase 1: Loading button keeps its size (P0)

- **Files**: theme file, `test/_helpers.dart`, `test/layout_test.dart`, `CHANGELOG.md`.
- **Change**:
  1. Failing first (MAB-M1): `test/layout_test.dart` from repro `layout_test.dart`, widened to all 18 constructors (Elevated `.new/.icon`; Filled `.new/.tonal/.icon/.tonalIcon`; Outlined `.new/.icon`; Text `.new/.icon`; Icon `.new/.filled/.filledTonal/.outlined`; FAB `.new/.small/.large/.extended`), label `Text('Save')`, icon `Icon(Icons.save)`, finder `find.bySubtype<ButtonStyleButton>()` / `find.byType(IconButton)` / `find.byType(FloatingActionButton)`. Hosts: `pumpHost` (Center) and new `Widget columnHost(Widget child, {ThemeData? theme}) => MaterialApp(theme: theme ?? emptyAsyncButtonTheme, home: Scaffold(body: Column(children: [child])))`. Per case: `pendingPress()`, `idle = tester.getSize(finder)`, `await tester.tap(finder); await tester.pump();`, `loading = getSize`, complete, pump; `check(loading.height).equals(idle.height)`, `check(loading.width).isLessOrEqual(idle.width)`. Keep the repro's body-level `Row` IconAsyncButton height case.
  2. MAB-B1: `AsyncButtonSpinner.build` → `Center(widthFactor: 1, heightFactor: 1, child: SizedBox.square(...))`. CHANGELOG (MAB-X-8, MAB-I11): title `# Changelog`; `### BREAKING` → `### Breaking`; add `## Unreleased` with `### Changed` "Requires Dart 3.13 / Flutter 3.47 (was Dart 3.10 / Flutter 3.38)." and `### Fixed` "Loading buttons no longer grow to fill their parent (every non-FAB wrapper since 2.0.0, and custom `loadingBuilder`s returning `AsyncButtonSpinner`)."
- **Traps**: measure the Material button, never the spinner's `SizedBox` (the blind spot that hid B1). Load by tap — a dropped `trigger()` Future fails the lints until Phase 2. FAB cases pass before the fix (controls).
- **Oracle**: `flutter test test/layout_test.dart`

### Phase 2: Fire-and-forget lint convention

- **Files**: `analysis_options.yaml`, the 4 test files holding the 11 `unawaited(` hits.
- **Change** (MAB-X-17): `analysis_options.yaml` becomes exactly:
  ```yaml
  include: package:very_good_analysis/analysis_options.yaml

  analyzer:
    exclude:
      - build/**

  linter:
    rules:
      # Maintainer convention: fire-and-forget is a bare drop; never unawaited().
      unawaited_futures: false
      discarded_futures: false
  ```
  Replace every `unawaited(<expr>)` with `<expr>;`; drop a `dart:async` import only where the analyzer reports it unused (`Completer` still needs it).
- **Oracle**: `flutter analyze --fatal-infos --fatal-warnings && ! rg -n 'unawaited\(' lib test example && flutter test`

### Phase 3: Controller state machine

- **Files**: `async_button_controller.dart`, `async_button.dart`, `test/async_button_controller_test.dart`, `test/async_button_test.dart`, `CHANGELOG.md`.
- **Change**:
  1. Failing first, from repro `controller_test.dart`. In `async_button_test.dart`: MAB-B2 tap → `reset()` → tap → complete run 1 → `calls == 2` and `c.value` true → complete run 2 → idle (do not port the repro's `calls == 1`; it contradicts the run-token decision). MAB-S1 internal controller, tap (pending), re-pump the same button with `controller: ext` → `ext.value` true; tap → `calls == 1`; complete → idle. MAB-B3 two `TextAsyncButton(controller: c)`, each in `SizedBox(width: 100, height: 48)`, in `Row(mainAxisSize: .min)` → `check(tester.takeException()).isA<AssertionError>()`. MAB-B4 the repro's unmount and swap tests as written, plus controls that must pass: same-slot type swap (`ElevatedAsyncButton` → `TextAsyncButton`, same `c`), same-slot key swap, `GlobalKey` reparent into a `Padding` — each `takeException()` null, `c.canTrigger` true, `trigger()` runs the new callback.
     In `async_button_controller_test.dart`, MAB-B10: attach, dispose, `check(c.canTrigger).isFalse()`, `await c.trigger().then<void>((_) {}, onError: (Object e) => err = e)`; `ran == 0`, `err` `isA<Error>()`.
     MAB-M2: in "swapping from external to internal controller" (`async_button_test.dart:314`) and "swapping the external controller transfers listening without leak" (`:342`) count `onPressed` calls per controller; the detached controller's count stays 0 after its `trigger()`.
  2. Controller: new members and rewritten methods (keep public docs; reword `reset()` per Decisions):
     ```dart
     int _run = 0; Future<void>? _inFlight; Object? _owner; Duration _minLoadingDuration = Duration.zero;
     void _bind(Object owner, {required AsyncCallback? onPressed}) {
       assert(_owner == null || identical(_owner, owner), 'An AsyncButtonController can drive only one mounted AsyncButton.');
       _owner = owner; _onPressed = onPressed;
     }
     void _unbind(Object owner) { if (identical(_owner, owner)) { _owner = null; _onPressed = null; } }
     Future<void> trigger() async {
       assert(ChangeNotifier.debugAssertNotDisposed(this), 'trigger() after dispose()');
       final onPressed = _onPressed;
       if (_isLoading || onPressed == null) { return; }
       final run = ++_run; _setLoading(true);
       final pending = _withFloor(onPressed, _minLoadingDuration); _inFlight = pending;
       try { await pending; } finally { _settle(run); }
     }
     static Future<void> _withFloor(AsyncCallback onPressed, Duration floor) async {
       final minimum = floor > Duration.zero ? Future<void>.delayed(floor) : null;
       try { await onPressed(); } finally { if (minimum != null) { await minimum; } }
     }
     void _adopt(Future<void> pending) {
       final run = ++_run; _inFlight = pending; _setLoading(true);
       pending.then<void>((_) => _settle(run), onError: (Object _) => _settle(run));
     }
     void _settle(int run) { if (run == _run) { _inFlight = null; _setLoading(false); } }
     void reset() { _run++; _inFlight = null; _setLoading(false); }
     // dispose(): _isDisposed = true; _onPressed = null; _owner = null; super.dispose();
     ```
     `_minLoadingDuration` stays zero until Phase 7.
  3. `_AsyncButtonState`: `void _bind() => controller._bind(this, onPressed: effectiveOnPressed);`. `initState`: assign controller, `addListener(listener)`, `_bind()`. `didUpdateWidget` on controller change: `final previous = controller; final inFlight = previous._inFlight;` `previous..removeListener(listener).._unbind(this)`; dispose `previous` only when `oldWidget.controller == null`; assign + `addListener`; `if (inFlight != null && !controller.value) { controller._adopt(inFlight); }`; then always `_bind()`. Add `activate()` (`super.activate(); _bind();`) and `deactivate()` (`controller._unbind(this); super.deactivate();`). `dispose()` unchanged. CHANGELOG: `### Fixed` — reset mid-flight no longer lets the stale run clear a new run; a controller swap mid-flight keeps the loading state; an external controller detaches when its button unmounts or is swapped out (`canTrigger` false, `trigger()` no-op); `trigger()` after `dispose()` never runs `onPressed`. `### Changed` — one controller bound to two mounted buttons fails a debug assertion; `reset()` abandons the in-flight run.
- **Traps**: unbinding in `dispose` would trip the assert on every same-slot swap — the new element's `initState` runs before the old `dispose`, but after the old `deactivate`. An unbounded B3 host turns the `ErrorWidget` into a second (layout) exception and `takeException()` returns a String. `onPressed()` must run inside `_withFloor`'s `try` so a synchronous throw still settles.
- **Oracle**: `flutter test test/async_button_controller_test.dart test/async_button_test.dart`

### Phase 4: Variant fixes

- **Files**: the 6 wrapper files, `async_material_button.dart`, `test/icon_enabled_test.dart`, `test/{icon,floating_action,elevated}_async_button_test.dart`, `CHANGELOG.md`.
- **Change**:
  1. Failing first: `test/icon_enabled_test.dart` — the 5 `.icon`/`.tonalIcon` constructors with `enabled: false, onPressed: () async {}`, each pumped alone, `check(tester.widget<ButtonStyleButton>(find.bySubtype<ButtonStyleButton>()).enabled).isFalse()`; run it alone first (compile error expected). Repro `variants_test.dart` B5 → `icon_async_button_test.dart`, B6 → `floating_action_async_button_test.dart`; repro `hypotheses_test.dart` "onPressed: null + onLongPress keeps the button enabled" → `elevated_async_button_test.dart`.
  2. MAB-B7: `super.enabled,` after `super.statesController,` in `ElevatedAsyncButton.icon`, `FilledAsyncButton.icon`, `FilledAsyncButton.tonalIcon`, `OutlinedAsyncButton.icon`, `TextAsyncButton.icon`.
  3. MAB-B5: `IconAsyncButton._buildIconButton({required VoidCallback? onPressed, required Widget icon, required bool isLoading})` passes `selectedIcon: isLoading ? null : selectedIcon`.
  4. MAB-B6: `FloatingActionAsyncButton.build`: `final collapsedIcon = _variant == .extended && !isExtended ? _icon : null;` → `AsyncButton(child: collapsedIcon ?? child, …)`, sizing `_variant == .extended && collapsedIcon == null ? .max : .iconSize`; `_buildExtended(callback, animatedChild, isLoading:, collapsed: collapsedIcon != null)` with `icon: collapsed ? animatedChild : (isLoading ? null : _icon)`, `label: collapsed ? child : animatedChild`.
  5. MAB-I6: `AsyncStandardMaterialButton.build` → `final longPress = enabled && !isLoading ? onLongPress : null;`. CHANGELOG: `### Fixed` selected `IconAsyncButton` shows the spinner; collapsed extended FAB shows the spinner; `enabled` on every `.icon`/`.tonalIcon`. `### Changed` `onPressed: null` with `onLongPress` keeps the button enabled for long-press, as in Flutter.
- **Traps**: find `.icon` buttons with `find.bySubtype<ButtonStyleButton>()` — they may be private subclasses. A collapsed extended FAB with no `icon` stays blank, as in Flutter.
- **Oracle**: `flutter test test/icon_enabled_test.dart test/icon_async_button_test.dart test/floating_action_async_button_test.dart test/elevated_async_button_test.dart`

### Phase 5: Line-box measurement

- **Files**: theme file, `pubspec.yaml`, `test/leak/*`, `test/line_box_font_test.dart`, `test/_helpers.dart`, `test/{elevated,outlined,text,floating_action}_async_button_test.dart`, `test/material_async_button_theme_test.dart`, `CHANGELOG.md`.
- **Change**:
  1. Failing first: dev dep `leak_tracker_flutter_testing: ^3.0.10` (resolves on 3.47.0 and 3.47.5); repro `leak/flutter_test_config.dart` → `test/leak/flutter_test_config.dart`, `leak/leak_test.dart` → `test/leak/line_box_leak_test.dart` (drop both `// ignore: depend_on_referenced_packages`). Repro `font_cache_test.dart` → `test/line_box_font_test.dart`, replacing the hard-coded SDK path fallback with `final root = Platform.environment['FLUTTER_ROOT']; if (root == null) fail('flutter test sets FLUTTER_ROOT');`.
  2. MAB-B8: `_ambientTextLineBox` reads `painter.preferredLineHeight` into a local, calls `painter.dispose()`, then caches and returns it.
  3. MAB-B9: top-level `var _lineBoxCacheListensToFonts = false;`; first thing in `_ambientTextLineBox`: if false, set true and `PaintingBinding.instance.systemFonts.addListener(_lineBoxCache.clear);`.
  4. MAB-M3: delete `spinnerTextLineBox`; at `elevated_async_button_test.dart:160`, `outlined_async_button_test.dart:82`, `text_async_button_test.dart:48`, `floating_action_async_button_test.dart:214` use `tester.getSize(find.text('<label>')).height` taken **before** `tapIntoLoading` (verified equal, e.g. 30.0 for `height: 2`). MAB-M4: delete "empty default has all null fields" (`material_async_button_theme_test.dart:24-29`). CHANGELOG `### Fixed`: no `TextPainter` leak per line-box cache miss; the spinner re-measures after fonts load (e.g. google_fonts).
- **Traps**: `test/leak/flutter_test_config.dart` enables leak tracking for that directory only; keep the repro's `withTrackedAll()` — it leaves not-GCed tracking ignored (library default), so no GC-timing flake. A mounted spinner re-measures on its next build; the font test re-pumps, which is the contract. If CI lacks `bin/cache/artifacts/material_fonts/Roboto-Regular.ttf`, replace that test's font load with `await tester.binding.defaultBinaryMessenger.handlePlatformMessage(SystemChannels.system.name, SystemChannels.system.codec.encodeMessage(<String, Object?>{'type': 'fontsChange'}), (_) {});` and assert `debugLineBoxCache` is empty (verified; `handleSystemMessage` itself is `@protected`); log it in § Found.
- **Oracle**: `flutter test`

### Phase 6: Parity parameters

- **Files**: `icon_async_button.dart`, `text_async_button.dart`, `test/icon_async_button_test.dart`, `test/text_async_button_test.dart`, `CHANGELOG.md`.
- **Change**:
  1. Failing first (compile error): each of the 4 `IconAsyncButton` constructors with `onHover`, `onLongPress`, `statesController` (a `WidgetStatesController` disposed via `addTearDown`) → the built `IconButton` holds the identical `onHover`/`statesController`; `onLongPress` non-null idle, null while loading. `TextAsyncButton(isSemanticButton: false, …)` → `tester.widget<TextButton>(…).isSemanticButton` false.
  2. `IconAsyncButton`: fields `final ValueChanged<bool>? onHover;`, `final VoidCallback? onLongPress;`, `final WidgetStatesController? statesController;` (doc "Forwarded to the underlying [IconButton]."), `this.onHover, this.onLongPress, this.statesController,` in all 4 constructors; `_buildIconButton` forwards `onHover`, `onLongPress: isLoading ? null : onLongPress`, `statesController`.
  3. `TextAsyncButton`: `final bool? isSemanticButton;` (doc: forwarded to [TextButton.isSemanticButton]; ignored by `.icon` — [TextButton.icon] has none); `.new` gets `this.isSemanticButton = true,`; `.icon` initializer `isSemanticButton = true`; `_buildButton` forwards it. CHANGELOG `### Added`: `IconAsyncButton` `onHover`/`onLongPress`/`statesController`; `TextAsyncButton.isSemanticButton`.
- **Traps**: the 4 `IconButton` constructors are torn off and called with one argument list; all four accept these params in Flutter 3.47.
- **Oracle**: `flutter test test/icon_async_button_test.dart test/text_async_button_test.dart`

### Phase 7: maintainSize + minLoadingDuration

- **Files**: theme file, `async_button.dart`, `async_material_button.dart`, the 6 wrapper files, `test/_helpers.dart`, `test/layout_test.dart`, `test/async_button_test.dart`, `test/material_async_button_theme_test.dart`, `CHANGELOG.md`.
- **Change** (MAB-G1 `maintainSize`, MAB-G2 `minLoadingDuration`):
  1. Failing first: `asyncButtonTheme({loadingBuilder, transitionBuilder, bool? maintainSize, Duration? minLoadingDuration})`. `layout_test.dart`: rerun the Phase 1 table with `theme: asyncButtonTheme(maintainSize: true)` in both hosts → `check(loading).equals(idle)` and `find.text('Save').hitTestable()` finds nothing while loading; widget `maintainSize: false` under that theme → `loading.width < idle.width` (`ElevatedAsyncButton`). `async_button_test.dart` group "minLoadingDuration" (`AsyncButton`, `onPressed: () async {}`, 300 ms): loading at +299 ms, idle at +300 ms; `reset()` during the floor → listener trace `[true, false]` after +300 ms; throwing `onPressed` → loading at +100 ms, error after +300 ms; theme 300 ms + widget 100 ms → idle at +100 ms. Theme tests: `copyWith`, `lerp` snap, `==`/`hashCode`, `empty` cover both fields.
  2. `AsyncButtonTheme`: `final bool? maintainSize,` and `final Duration? minLoadingDuration,` with dartdoc stating the defaults (`false`, `Duration.zero`); add to `copyWith`, `lerp` (`snap ? x : other.x`), `==`, `hashCode` (`Object.hash` of 4).
  3. `AsyncButton`: `final bool? maintainSize, final Duration? minLoadingDuration,`. In `build`, after `theme`: `controller._minLoadingDuration = widget.minLoadingDuration ?? theme.minLoadingDuration ?? Duration.zero;` and replace `var content = …` with
     ```dart
     final keepFootprint = widget.maintainSize ?? theme.maintainSize ?? false;
     Widget content = switch ((isLoading, keepFootprint)) {
       (false, _) => widget.child,
       (true, false) => loadingBuilder(context),
       (true, true) => Stack(alignment: .center, children: [Visibility(visible: false, maintainState: true,
           maintainAnimation: true, maintainSize: true, child: widget.child), loadingBuilder(context)]),
     };
     ```
  4. `AsyncMaterialButton`: `final bool? maintainSize, final Duration? minLoadingDuration,` ("See [AsyncButton.…]") and `bool _resolveMaintainSize(BuildContext context) => maintainSize ?? AsyncButtonTheme.of(context).maintainSize ?? false;`. `AsyncStandardMaterialButton` adds `super.maintainSize, super.minLoadingDuration`; each of the 18 wrapper constructors adds `super.maintainSize, super.minLoadingDuration,` after `super.transitionBuilder,`; every wrapper `build` computes `final keepFootprint = _resolveMaintainSize(context);` once and passes `maintainSize: keepFootprint, minLoadingDuration: minLoadingDuration` to `AsyncButton`.
  5. Icon kept: `AsyncStandardMaterialButton.build` sizing `_icon != null && !keepFootprint ? .max : .fontSize` (delete `_loadingSizing`), `icon: isLoading && !keepFootprint ? null : _icon`. FAB: `_buildExtended` gains `required bool keepFootprint`, non-collapsed `icon: isLoading && !keepFootprint ? null : _icon`; sizing `_variant != .extended || collapsedIcon != null ? .iconSize : (keepFootprint && _icon != null ? .fontSize : .max)`. CHANGELOG `### Added`: `maintainSize` (keep the idle footprint while loading) and `minLoadingDuration` (anti-flicker floor) on `AsyncButtonTheme`, `AsyncButton` and every wrapper.
- **Traps**: `Visibility` asserts `maintainSize` ⇒ `maintainAnimation` ⇒ `maintainState`; leave `maintainSemantics` false so screen readers hear only "Loading". `find.text` still finds the hidden label — use `.hitTestable()`. A test with a non-zero floor must pump past it or flutter_test fails on a pending timer. `AsyncButtonTheme.of` is illegal in `initState` — read it in `build`.
- **Oracle**: `flutter test`

### Phase 8: Repo meta, packaging, CI

- **Files**: `pubspec.yaml`, `.pubignore`, `.github/**` (incl. restored `workflows/publish.yaml`), `CONTRIBUTING.md`.
- **Change**:
  1. `pubspec.yaml` (MAB-X-1, MAB-X-18): delete `homepage:` and `documentation:`; order `name, description, version, repository, issue_tracker, topics, environment, dependencies, dev_dependencies`.
  2. MAB-P1 / MAB-X-16: `git rm .pubignore` (`.gitignore` already lists `.idea/`, `.vscode/`, `build/`, `coverage/`).
  3. No `SECURITY.md` (the maintainer accepts no private vulnerability reports). `CONTRIBUTING.md`:
     ```markdown
     # Contributing

     1. `flutter pub get`
     2. Run what CI runs:
        - `git ls-files -z -- '*.dart' | xargs -0 dart format --output=none --set-exit-if-changed`
        - `flutter analyze --fatal-infos --fatal-warnings`
        - `flutter test`
        - `flutter pub publish --dry-run`
     3. Add a line under `## Unreleased` in `CHANGELOG.md` for every user-visible change.

     Releases are published manually by the maintainer.
     ```
     `.github/PULL_REQUEST_TEMPLATE.md`:
     ```markdown
     ## Summary

     ## Checklist

     - [ ] Tests added or updated
     - [ ] `CHANGELOG.md` `## Unreleased` entry
     - [ ] Docs / README / skill updated if public API changed
     ```
  4. `.github/ISSUE_TEMPLATE/bug_report.yaml`:
     ```yaml
     name: Bug report
     description: Something is broken in material_async_button
     title: "[bug] "
     labels: [bug]
     body:
       - type: textarea
         id: what-happened
         attributes:
           label: What happened?
           description: A clear, concise description of the bug.
         validations:
           required: true
       - type: textarea
         id: reproduction
         attributes:
           label: Minimal reproduction
           description: A minimal Dart snippet that reproduces the issue.
           render: dart
           placeholder: |
             // minimal reproduction
         validations:
           required: true
       - type: textarea
         id: expected
         attributes:
           label: Expected behavior
         validations:
           required: true
       - type: input
         id: package-version
         attributes:
           label: material_async_button version
           placeholder: 3.1.0
         validations:
           required: true
       - type: textarea
         id: env
         attributes:
           label: Environment
           description: Output of `flutter doctor -v`.
           render: shell
         validations:
           required: true
     ```
     `.github/ISSUE_TEMPLATE/feature_request.yaml`:
     ```yaml
     name: Feature request
     description: Suggest a new capability or improvement
     title: "[feature] "
     labels: [enhancement]
     body:
       - type: textarea
         id: problem
         attributes:
           label: Problem
           description: What problem are you trying to solve?
         validations:
           required: true
       - type: textarea
         id: proposed
         attributes:
           label: Proposed solution
           description: How would you like this to work?
         validations:
           required: true
       - type: textarea
         id: alternatives
         attributes:
           label: Alternatives considered
         validations:
           required: false
     ```
     `.github/ISSUE_TEMPLATE/config.yml`:
     ```yaml
     blank_issues_enabled: true
     ```
  5. `.github/dependabot.yml`:
     ```yaml
     version: 2
     updates:
       - package-ecosystem: pub
         directory: /
         schedule:
           interval: weekly
         open-pull-requests-limit: 5
         labels: [dependencies]
       - package-ecosystem: pub
         directory: /example
         schedule:
           interval: weekly
         open-pull-requests-limit: 5
         labels: [dependencies, example]
       - package-ecosystem: github-actions
         directory: /
         schedule:
           interval: weekly
         labels: [dependencies, ci]
     ```
  6. `.github/workflows/ci.yaml` (MAB-X-9 dry-run job, MAB-X-10 permissions/timeouts, MAB-X-12, MAB-M5 floor + downgrade), replaced entirely:
     ```yaml
     name: CI

     on:
       push:
         branches: [main]
       pull_request:
         branches: [main]
       workflow_dispatch:

     permissions:
       contents: read

     concurrency:
       group: ${{ github.workflow }}-${{ github.ref }}
       cancel-in-progress: true

     jobs:
       format:
         runs-on: ubuntu-latest
         timeout-minutes: 10
         steps:
           - uses: actions/checkout@v7
           - uses: subosito/flutter-action@v2
             with: { channel: stable, cache: true }
           - run: git ls-files -z -- '*.dart' | xargs -0 dart format --output=none --set-exit-if-changed

       analyze:
         runs-on: ubuntu-latest
         timeout-minutes: 15
         steps:
           - uses: actions/checkout@v7
           - uses: subosito/flutter-action@v2
             with: { channel: stable, cache: true }
           - run: flutter pub get
           - run: flutter analyze --fatal-infos --fatal-warnings
           - run: flutter pub get
             working-directory: example
           - run: flutter analyze --fatal-infos --fatal-warnings
             working-directory: example

       test:
         name: test (${{ matrix.name }})
         runs-on: ubuntu-latest
         timeout-minutes: 20
         strategy:
           fail-fast: false
           matrix:
             include:
               - { name: floor, channel: stable, version: '3.47.0' }
               - { name: stable, channel: stable, version: '' }
               - { name: beta, channel: beta, version: '' }
         steps:
           - uses: actions/checkout@v7
           - uses: subosito/flutter-action@v2
             with:
               channel: ${{ matrix.channel }}
               flutter-version: ${{ matrix.version }}
               cache: true
           - run: flutter pub get
           - run: flutter test

       downgrade:
         runs-on: ubuntu-latest
         timeout-minutes: 20
         steps:
           - uses: actions/checkout@v7
           - uses: subosito/flutter-action@v2
             with: { channel: stable, cache: true }
           - run: flutter pub downgrade
           - run: flutter analyze --fatal-warnings
           - run: flutter test

       pana:
         runs-on: ubuntu-latest
         timeout-minutes: 15
         steps:
           - uses: actions/checkout@v7
           - uses: subosito/flutter-action@v2
             with: { channel: stable, cache: true }
           - run: dart pub global activate pana
           - run: dart pub global run pana --no-warning --exit-code-threshold 0

       publish-dry-run:
         runs-on: ubuntu-latest
         timeout-minutes: 10
         steps:
           - uses: actions/checkout@v7
           - uses: subosito/flutter-action@v2
             with: { channel: stable, cache: true }
           - run: flutter pub publish --dry-run
     ```
  7. Restore `.github/workflows/publish.yaml` (deleted in commit `ceb22a0`) with its tag trigger commented out — automated publishing stays configured on pub.dev for later; `workflow_dispatch` keeps it a valid workflow and a manual run cannot publish (pub.dev requires a tag push; `verify` also fails off a tag):
     ```yaml
     name: Publish

     on:
       # Automated publishing is paused; pub.dev Admin → Automated publishing stays enabled.
       # Re-enable by uncommenting the tag trigger below. pub.dev rejects publishes not started
       # by a tag push, so a manual workflow_dispatch run cannot publish.
       # push:
       #   tags:
       #     - 'v[0-9]+.[0-9]+.[0-9]+*'
       workflow_dispatch:

     permissions:
       id-token: write
       contents: read

     jobs:
       verify:
         name: Verify tag matches pubspec
         runs-on: ubuntu-latest
         steps:
           - uses: actions/checkout@v6
           - name: Check tag matches pubspec version
             run: |
               TAG="${GITHUB_REF#refs/tags/v}"
               PUBSPEC=$(grep '^version:' pubspec.yaml | awk '{print $2}')
               if [ "$TAG" != "$PUBSPEC" ]; then
                 echo "::error::Tag v$TAG does not match pubspec.yaml version $PUBSPEC"
                 exit 1
               fi

       publish:
         name: Publish to pub.dev
         needs: verify
         runs-on: ubuntu-latest
         environment: pub.dev
         permissions:
           id-token: write
           contents: read
         steps:
           - uses: actions/checkout@v6
           - uses: dart-lang/setup-dart@v1
           - uses: subosito/flutter-action@v2
             with:
               channel: stable
           - run: flutter pub get
           - run: flutter pub publish --force
     ```
- **Traps**: without `.pubignore`, `.gitignore` governs the archive; `plans/` is in neither, so `plans/sweep-fixes.md` is listed until the last commit deletes it (expected). A dirty tree makes the dry-run warn and exit 65, so this oracle reads the file list only; § Verification checks exit 0. If pana fails *after* printing 160/160 with `PathNotFoundException`, add `continue-on-error: true` to that job only and log it in § Found. `3.47.0` exists as a stable tag (`git -C ~/Sdk/flutter tag | grep -x 3.47.0`). No `frontend_server_client` dev dep (Dart-only downgrade trap; MAB's downgrade run passed).
- **Oracle**: `test ! -e .pubignore && out=$(flutter pub publish --dry-run 2>&1); ! grep -qE '── (build|coverage)' <<<"$out" && grep -q 'SKILL.md' <<<"$out" && ! grep -qE '^(homepage|documentation):' pubspec.yaml && test ! -e SECURITY.md && yq -e '(.contact_links // []) | length == 0' .github/ISSUE_TEMPLATE/config.yml && yq -e '(.on | has(\"workflow_dispatch\")) and (.on | has(\"push\") | not)' .github/workflows/publish.yaml`

### Phase 9: Docs, skill, example

- **Files**: `README.md`, the skill, `lib/**` dartdoc, `example/lib/main.dart`, `example/README.md`, `CHANGELOG.md`. Line numbers are pre-edit — apply bottom-up within each file, or match the quoted text.
- **Change**:
  1. MAB-X-11: `git mv skills/flutter-material-async-button skills/material-async-button-usage`; frontmatter keys `name: material-async-button-usage`, `description` (unchanged), `license: MIT`; H1 `# material-async-button-usage`; fix every `rg -n 'flutter-material-async-button'` hit. SKILL drift: line 9 "Every Material param is forwarded" → forwarded except FAB `onPressed` is required; lines 25-27 → errors reach your zone / `PlatformDispatcher.instance.onError`, `controller.trigger()` callers get a rejected Future; delete lines 42-44; add `maintainSize: true` (no width jump) and `minLoadingDuration` (anti-flicker) under "Theme", and "one controller per mounted button; `reset()` abandons the run" under "Controller". CHANGELOG `### Changed`: skill renamed for `dart run skills@ get`.
  2. README skeleton (MAB-X-5, MAB-X-19, MAB-I1, MAB-P2): `# material_async_button`; one badge row `[![pub package](https://img.shields.io/pub/v/material_async_button.svg)](https://pub.dev/packages/material_async_button) [![pub points](https://img.shields.io/pub/points/material_async_button)](https://pub.dev/packages/material_async_button/score) [![CI](https://github.com/esenmx/material_async_button/actions/workflows/ci.yaml/badge.svg)](https://github.com/esenmx/material_async_button/actions/workflows/ci.yaml) [![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)`; pitch (lines 3-15); `## Install` holding only a `sh` block `flutter pub add material_async_button` (lines 19-24 go); existing sections; `## Agent skill` replacing lines 196-201:
     ````markdown
     ## Agent skill

     This package ships an agent skill in `skills/material-async-button-usage/`. Install it into your project's agent config with:

     ```sh
     dart run skills@ get --package material_async_button --all
     ```
     ````
     then `## Contributing` linking `CONTRIBUTING.md`, and `## License` "MIT — see [LICENSE](LICENSE)."
  3. README drift: add `FloatingActionButton` to the pitch and the wrappers table (MAB-I2); lines 45-48 → parameters forwarded except FAB `onPressed` is required and its default `heroTag` differs (MAB-I5); lines 57-58 → zone / `PlatformDispatcher.instance.onError` wording (MAB-I4); delete lines 106-109 (MAB-I3); Theming documents `maintainSize`/`minLoadingDuration` and "`copyWith` can't reset a field to null — build a new `AsyncButtonTheme`" (MAB-M7); External control: `reset()` abandons the run, one controller per mounted button; Defaults: `.icon` drops the icon unless `maintainSize`, `onPressed: null` disables only without `onLongPress`, `maintainSize: true` as the no-jump alternative beside the `AnimatedSize` advice.
  4. Dartdoc: add `FloatingActionAsyncButton` to `async_button.dart:44-47` and `async_material_button.dart:3-5`; `async_button.dart:54` `onPressed: () async => doWork()` → `onPressed: doWork` (MAB-I12); `elevated_async_button.dart:25-26` → loading replaces `label` and drops the icon unless `maintainSize` (MAB-I7); `icon_async_button.dart:11-14,189-191` → the spinner announces "Loading", so a `tooltip` keeps the idle label (MAB-I8); `FloatingActionAsyncButton.heroTag` doc → the default is a package sentinel, so no hero flight between a plain and an async FAB (MAB-I9); `material_async_button_theme.dart:166-168` "ambient font size" → "ambient label line box" (MAB-I10); controller `trigger()` doc and comment → zone wording.
  5. MAB-M6 example: before the `IconAsyncButton` `Row` add `Row(mainAxisAlignment: .center, children: [ElevatedAsyncButton(onPressed: _simulateWork, child: const Text('Intrinsic')), const SizedBox(width: 8), ElevatedAsyncButton(onPressed: _simulateWork, maintainSize: true, child: const Text('maintainSize'))])`. `example/README.md` → `# material_async_button example` plus "Platform folders are not tracked: run `flutter create .` once, then `flutter run`."
  6. Snippet check: copy repro `snippets/doc_snippets.dart` to `test/doc_snippets_scratch.dart`, re-paste every ```dart block of the new README/SKILL/dartdoc, analyze, delete.
- **Traps**: the Agent-skill block nests a fence — use the 4-backtick outer fence. `skills/` ships in the archive on purpose.
- **Oracle**:
  ```sh
  flutter analyze --fatal-infos test/doc_snippets_scratch.dart && rm test/doc_snippets_scratch.dart && (cd example && flutter analyze --fatal-infos --fatal-warnings) \
    && tmp=$(mktemp -d) && cd $tmp && flutter create -t app probe && cd probe && flutter pub add material_async_button --path /Users/mehmetesen/pub-dev/material_async_button \
    && dart run skills@ get --package material_async_button --agent claude --all 2>&1 | tee "$tmp/skills_get.txt" && ! grep -q 'Skipping skill' "$tmp/skills_get.txt" && find . -path '*material-async-button-usage/SKILL.md' | grep -q .
  ```
  If `dart run skills@` can't be resolved offline, record that in § Found and fall back to `ls /Users/mehmetesen/pub-dev/material_async_button/skills | grep -qx 'material-async-button-.*'`.

### Phase 10: Release prep, push, CI

- **Files**: `pubspec.yaml`, `CHANGELOG.md`, `/Users/mehmetesen/pub-dev/SWEEP.md`, `plans/sweep-fixes.md`.
- **Change** (MAB-X-7): `version: 3.1.0`; `## Unreleased` → `## 3.1.0 - $(date +%F)`. Append to SWEEP.md `## Deferred` one bullet per deferred item in § Out of scope: `- [material_async_button] <ID> — <one line> — <why deferred>`. Commit first (Verification 3 needs a clean tree); run § Verification; tick Phase 10 and let the last commit delete `plans/sweep-fixes.md`; then run the oracle on that pushed commit — a red run is fixed forward in a new commit and reported (the plan is gone).
- **Oracle**: `git push && gh run watch --exit-status $(gh run list -L1 --json databaseId -q '.[0].databaseId')`

## Verification

From the repo root, after Phase 10's bump commit:

1. `git ls-files -z -- '*.dart' | xargs -0 dart format --output=none --set-exit-if-changed && flutter analyze --fatal-infos --fatal-warnings && flutter test` (includes `test/leak/`)
2. `(cd example && flutter pub get && flutter analyze --fatal-infos --fatal-warnings && flutter test)`, then `flutter pub downgrade && flutter analyze --fatal-warnings && flutter test; flutter pub upgrade` (lockfile is gitignored)
3. `flutter pub publish --dry-run` → exit 0, 0 warnings (precondition: clean tree)
4. `dart pub global activate pana && dart pub global run pana --no-warning --exit-code-threshold 0`, then Phase 9's skills install oracle (precondition: network; fallback as stated there). The Flutter 3.47.0 floor runs only in CI `test (floor)` — a local skip, checked by the Phase 10 oracle.

## Edge cases

- Hung `onPressed`: `reset()` returns to idle and re-arms; the hung future's completion is ignored.
- Throw under a floor: loading holds for `minLoadingDuration`, then the error rethrows (tap: uncaught zone error; `trigger()` caller: rejected Future).
- Two mounted buttons on one controller (incl. an `AnimatedSwitcher` cross-fade of keyed buttons): debug assert; release last-binder-wins, and the outgoing unbind never clears the incoming binding. Controller swap while loading: the new controller adopts the run unless it is already running its own.
- `maintainSize` with a loading view larger than the idle child: footprint = max(idle, loading). Dispose mid-flight or mid-floor: `_settle`/`_setLoading` no-op; the floor timer completes harmlessly. Fonts load while a spinner is mounted: cache cleared; that spinner re-measures on its next build. Collapsed extended FAB without `icon`: blank, as in Flutter.

## Out of scope

- MAB-I13 class modifiers (`final class` wrappers, sealed base) — breaking, next major. MAB-I14 hiding `attach`/`debugLineBoxCache` — removes public API, next major. MAB-S2 inline-closure theme inequality — doc-only fix, no failing-first oracle, effect unmeasured.
- MAB-G3 announcements, MAB-G4 timeout/cancellation, MAB-G5 `loadingStyle`, MAB-G6 `MenuItemAsyncButton`, MAB-G8 busy-group scope — features outside this release's list.
- MAB-G7 `trigger()` → `Future<bool>` — breaking return type. `showSpinnerAfter` delay (the other half of the anti-flicker gap) — outside this release's feature list. MAB-X-4 beta `StateError` on use-after-dispose — collection_notifiers only; MAB's beta leg is green and new tests assert `isA<Error>()`.
- User-only steps (the executor never does these): publish the release to pub.dev (pub.dev Admin → Automated publishing stays enabled; the restored `publish.yaml` keeps its tag trigger commented out until you re-enable it). Optional: a DNS record for mehmetesen.com before re-adding `homepage:`.

## Found

Tracker: `/Users/mehmetesen/pub-dev/SWEEP.md` § Deferred.

Executor appends one bullet per discovery the plan didn't name: blocking and in-scope → fix + note; else note only, never silently absorbed. A log, not a tracker — it is deleted with the plan: anything left open — skipped check, deferred follow-up, user-only step — also gets a tracker row (`none` → final report); a finding stays open until its check runs.

- Phase 2: 2 of the 11 `unawaited(` hits were a comment in `floating_action_async_button_test.dart` justifying `.ignore()` on `Navigator.push`; replaced with a bare drop per the convention and dropped the comment (oracle `! rg 'unawaited\('`). Lint fallout fixed: `cascade_invocations` in `async_button_controller_test.dart` "reset returns to idle", unused `dart:async` in `elevated_async_button_test.dart`. Closed.
- Phase 3: `_minLoadingDuration` is declared `final` until Phase 7 assigns it (`prefer_final_fields` under `--fatal-infos`). `attach` dartdoc no longer claims `AsyncButton` calls it. Closed.
- Phase 5: lint fallout `avoid_redundant_argument_values` on the repro's `AsyncButtonSpinner(size: null)` → `AsyncButtonSpinner()`. The local SDK has `material_fonts/Roboto-Regular.ttf`, so the `fontsChange` fallback was not needed (CI unverified until the Phase 10 run). Closed.
- Phase 6: lint fallout `avoid_positional_boolean_parameters` on a local `void onHover(bool _) {}` in the new test → a `List<bool>.add` tear-off (identity-stable). Closed.
- Phase 7: added a "theme value applies when the widget sets none" `minLoadingDuration` test beside the listed "widget beats theme" one, so theme → widget resolution is pinned both ways. Lint fallout `omit_local_variable_types` → `var content = switch …`. Closed.

## Execution prompt

Paste as turn 1 of a fresh session:

```text
Execute plans/sweep-fixes.md. It is self-contained and every decision in it is final: do not re-explore, re-decide, or propose architectural changes. Set its frontmatter status to in-progress, then start at the first unticked phase in § Progress, run its oracle, tick it, report the output, and continue phase by phase without waiting for me. Append anything the plan did not name to § Found; anything left open also gets a row in the tracker § Found names. The file is the state of record: after compaction, re-read it and resume from § Progress. Only when every § Verification step ran and passed, delete the plan file in your last commit — plans are ephemeral, git is the archive. A decision the plan does not cover: stop and ask me as a structured question.
```
