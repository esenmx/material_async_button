import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_async_button/material_async_button.dart';
import 'package:material_ui/material_ui.dart';

import '_helpers.dart';

typedef _Button = Widget Function(
  AsyncButtonController c,
  AsyncCallback onPressed,
);

/// A multi-child parent: it inflates a new keyed child before it deactivates
/// the old one, unlike the single-child [pumpHost].
Widget _columnOf(List<Widget> children) => MaterialApp(
  theme: emptyAsyncButtonTheme,
  home: Scaffold(
    body: Column(mainAxisSize: .min, children: children),
  ),
);

/// Multi-child parents that reuse unkeyed children by index.
final Map<String, Widget Function(List<Widget>)> _parents = {
  'Column': (children) => Column(mainAxisSize: .min, children: children),
  'Row': (children) => Row(mainAxisSize: .min, children: children),
  'ListView': (children) => ListView(children: children),
  'Stack': (children) => Stack(children: children),
};

Widget _hostIn(Widget Function(List<Widget>) parent, List<Widget> children) =>
    MaterialApp(
      theme: emptyAsyncButtonTheme,
      home: Scaffold(body: parent(children)),
    );

void main() {
  group('AsyncButton rendering', () {
    testWidgets('shows child in idle state', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async {},
            builder: textBuilder,
            child: const Text('hello'),
          ),
        ),
      );
      check(find.text('hello')).findsOne();
    });

    testWidgets('falls back to built-in spinner when no loadingBuilder', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: onPressed,
            builder: textBuilder,
            child: const Text('go'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      check(find.byType(CircularProgressIndicator)).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('stays enabled while loading (taps are no-ops)', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: onPressed,
            builder: textBuilder,
            child: const Text('go'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      // Loading never disables the button — the callback stays wired; the
      // controller swallows the tap (still loading), so it doesn't re-run.
      final btn = tester.widget<TextButton>(find.byType(TextButton));
      check(btn.onPressed).isNotNull();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('uses per-widget loadingBuilder when given', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: onPressed,
            loadingBuilder: (_) => const Text('spinning'),
            builder: textBuilder,
            child: const Text('go'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      check(find.text('spinning')).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('theme loadingBuilder used when no per-widget override', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: onPressed,
            builder: textBuilder,
            child: const Text('go'),
          ),
          theme: asyncButtonTheme(
            loadingBuilder: (_) => const Text('themed-loading'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      check(find.text('themed-loading')).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('widget loadingBuilder beats theme', (tester) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: onPressed,
            loadingBuilder: (_) => const Text('widget'),
            builder: textBuilder,
            child: const Text('go'),
          ),
          theme: asyncButtonTheme(loadingBuilder: (_) => const Text('themed')),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      check(find.text('widget')).findsOne();
      check(find.text('themed')).findsNone();
      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  group('AsyncButton transitions', () {
    testWidgets('returns to its child after onPressed completes', (
      tester,
    ) async {
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async {},
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      check(find.text('label')).findsOne();
    });

    testWidgets('a throwing onPressed returns to idle and rethrows', (
      tester,
    ) async {
      final controller = newController();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: controller,
            onPressed: () async => throw StateError('boom'),
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      // The error is not swallowed — trigger() rethrows so the caller (state
      // management / the surrounding zone) sees it.
      await check(controller.trigger()).throws<StateError>();
      await tester.pump();
      // The button is back to its idle child — there is no error view.
      check(find.text('label')).findsOne();
    });

    testWidgets('taps while loading join the run without reporting its error '
        'again', (tester) async {
      // The gate's future must live in the guarded zone: errors never cross
      // error-zone boundaries.
      late final Completer<void> gate;
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () => gate.future,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      final tap = tester.widget<TextButton>(find.byType(TextButton)).onPressed;
      final errors = <Object>[];
      runZonedGuarded(() {
        gate = Completer<void>();
        tap?.call();
        tap?.call();
        tap?.call();
      }, (e, _) => errors.add(e));
      gate.completeError(StateError('boom'));
      await tester.pump();
      check(errors).length.equals(1);
    });
  });

  group('AsyncButton callbacks', () {
    testWidgets('callback null when onPressed is null', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          const AsyncButton(
            onPressed: null,
            builder: textBuilder,
            child: Text('label'),
          ),
        ),
      );
      final btn = tester.widget<TextButton>(find.byType(TextButton));
      check(btn.onPressed).isNull();
    });

    testWidgets('callback null when enabled is false', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async {},
            enabled: false,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      final btn = tester.widget<TextButton>(find.byType(TextButton));
      check(btn.onPressed).isNull();
    });

    testWidgets('enabled:false no-ops external controller.trigger', (
      tester,
    ) async {
      var ran = 0;
      final controller = newController();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: controller,
            onPressed: () async => ran++,
            enabled: false,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      // enabled:false collapses to onPressed:null at the controller seam, so an
      // external trigger can't run either.
      await controller.trigger();
      await tester.pump();
      check(ran).equals(0);
      check(controller).isIdle();
      check(find.byType(CircularProgressIndicator)).findsNone();
    });
  });

  group('AsyncButton external control', () {
    testWidgets('controller.trigger drives loading; stays enabled', (
      tester,
    ) async {
      final controller = newController();
      final completer = Completer<void>();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: controller,
            onPressed: () => completer.future,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      final textButton = find.byType(TextButton);
      // Idle: interactive.
      check(tester.widget<TextButton>(textButton).onPressed).isNotNull();

      controller.trigger();
      await tester.pump();
      // Loading: spinner shows and the button keeps its enabled look.
      check(find.byType(CircularProgressIndicator)).findsOne();
      check(tester.widget<TextButton>(textButton).onPressed).isNotNull();

      completer.complete();
      await tester.pumpAndSettle();
      check(find.text('label')).findsOne();
    });

    testWidgets('controller.reset clears the loading state', (tester) async {
      final controller = newController();
      final completer = Completer<void>();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: controller,
            onPressed: () => completer.future,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      controller.trigger();
      await tester.pump();
      check(find.byType(CircularProgressIndicator)).findsOne();
      controller.reset();
      await tester.pump();
      check(find.text('label')).findsOne();
      completer.complete();
    });

    testWidgets(
      'swapping from internal to external controller disposes internal '
      'and uses new',
      (tester) async {
        final externalController = newController();
        final completer = Completer<void>();
        AsyncButton button(AsyncButtonController? c) => AsyncButton(
          controller: c,
          onPressed: () => completer.future,
          builder: textBuilder,
          child: const Text('child'),
        );

        // 1. Pump with internal controller (null)
        await tester.pumpWidget(pumpHost(button(null)));
        final internalController = mountedController(tester);

        // 2. Pump with external controller
        await tester.pumpWidget(pumpHost(button(externalController)));
        check(internalController).isDisposed();

        // The widget now listens to externalController: driving it must show
        // loading.
        externalController.trigger();
        await tester.pump();
        check(find.byType(CircularProgressIndicator)).findsOne();

        completer.complete();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('swapping from external to internal controller', (
      tester,
    ) async {
      final externalController = newController();
      final completer = Completer<void>();
      var externalCalls = 0;
      var internalCalls = 0;
      AsyncButton button(AsyncButtonController? c, VoidCallback count) =>
          AsyncButton(
            controller: c,
            onPressed: () {
              count();
              return completer.future;
            },
            builder: textBuilder,
            child: const Text('child'),
          );

      // 1. Pump with external controller
      await tester.pumpWidget(
        pumpHost(button(externalController, () => externalCalls++)),
      );

      // 2. Pump with internal controller (null)
      await tester.pumpWidget(pumpHost(button(null, () => internalCalls++)));

      // The detached externalController has no button bound: trigger()
      // throws and runs nothing.
      await check(externalController.trigger()).throws<StateError>();
      await tester.pump();
      check(find.byType(CircularProgressIndicator)).findsNone();
      check(
        because: 'a detached controller runs nothing',
        externalCalls,
      ).equals(0);

      await tester.tap(find.byType(TextButton));
      await tester.pump();
      check(internalCalls).equals(1);

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'swapping the external controller transfers listening without leak',
      (tester) async {
        final a = newController();
        final b = newController();
        final aCompleter = Completer<void>();
        final bCompleter = Completer<void>();
        var aCalls = 0;
        var bCalls = 0;
        AsyncButton button(
          AsyncButtonController c,
          Completer<void> done,
          VoidCallback count,
        ) => AsyncButton(
          controller: c,
          onPressed: () {
            count();
            return done.future;
          },
          builder: textBuilder,
          child: const Text('child'),
        );
        await tester.pumpWidget(
          pumpHost(button(a, aCompleter, () => aCalls++)),
        );
        await tester.pumpWidget(
          pumpHost(button(b, bCompleter, () => bCalls++)),
        );
        // The widget now listens to b: a has no button bound, so trigger()
        // throws and nothing loads.
        await check(a.trigger()).throws<StateError>();
        await tester.pump();
        check(find.byType(CircularProgressIndicator)).findsNone();
        check(because: 'a detached controller runs nothing', aCalls).equals(0);
        // Driving b does.
        b.trigger();
        await tester.pump();
        check(find.byType(CircularProgressIndicator)).findsOne();
        check(bCalls).equals(1);
        aCompleter.complete();
        bCompleter.complete();
        await tester.pumpAndSettle();
        // Neither caller-owned controller was disposed by the swap.
        check(a).isNotDisposed();
        check(b).isNotDisposed();
      },
    );

    testWidgets('disposes internal controller when unmounted', (tester) async {
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async {},
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      final internalController = mountedController(tester);

      await tester.pumpWidget(pumpHost(const SizedBox()));

      check(internalController).isDisposed();
    });

    testWidgets('does not dispose external controller when unmounted', (
      tester,
    ) async {
      final controller = newController();
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            controller: controller,
            onPressed: () async {},
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );

      await tester.pumpWidget(pumpHost(const SizedBox()));

      check(controller).isNotDisposed();
    });
  });

  group('AsyncButton transition builder', () {
    testWidgets('no transition by default — the swap is instant', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton(onPressed: onPressed, child: const Text('go')),
        ),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      // No AnimatedSwitcher/AnimatedSize is inserted by the package.
      check(find.byType(AnimatedSwitcher)).findsNone();
      check(find.byType(CircularProgressIndicator)).findsOne();
      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('wraps the keyed state child with the supplied builder', (
      tester,
    ) async {
      final (:onPressed, :completer) = pendingPress();
      final seenLoading = <bool>[];
      await tester.pumpWidget(
        pumpHost(
          FilledAsyncButton(
            onPressed: onPressed,
            transitionBuilder: (context, child, isLoading) {
              seenLoading.add(isLoading);
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child: child,
              );
            },
            child: const Text('go'),
          ),
        ),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      check(find.byType(AnimatedSwitcher)).findsOne();
      check(seenLoading).contains(true);
      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  group('minLoadingDuration', () {
    const floor = Duration(milliseconds: 300);
    const ms = Duration(milliseconds: 1);

    Widget button(
      AsyncButtonController c, {
      AsyncCallback? onPressed,
      Duration? minLoadingDuration = floor,
    }) {
      return AsyncButton(
        controller: c,
        onPressed: onPressed ?? () async {},
        minLoadingDuration: minLoadingDuration,
        builder: textBuilder,
        child: const Text('label'),
      );
    }

    testWidgets('holds loading until the floor elapses from the tap', (
      tester,
    ) async {
      final c = newController();
      await tester.pumpWidget(pumpHost(button(c)));
      await tester.tap(find.byType(TextButton));
      await tester.pump(ms * 299);
      check(c).isLoading();
      await tester.pump(ms);
      check(c).isIdle();
    });

    testWidgets('the floor counts from the tap, not from completion', (
      tester,
    ) async {
      final c = newController();
      await tester.pumpWidget(
        pumpHost(button(c, onPressed: () => Future<void>.delayed(ms * 200))),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump(ms * 299);
      check(c).isLoading();
      await tester.pump(ms);
      check(because: 'idle at +300 ms, not +500 ms', c).isIdle();
    });

    testWidgets('reset() during the floor ends loading once', (tester) async {
      final c = newController();
      final trace = <bool>[];
      c.addListener(() => trace.add(c.value));
      await tester.pumpWidget(pumpHost(button(c)));
      await tester.tap(find.byType(TextButton));
      await tester.pump(ms * 100);
      c.reset();
      await tester.pump(ms * 200);
      check(trace).deepEquals([true, false]);
    });

    testWidgets('a throwing onPressed rethrows after the floor', (
      tester,
    ) async {
      final c = newController();
      Object? error;
      await tester.pumpWidget(
        pumpHost(button(c, onPressed: () async => throw StateError('boom'))),
      );
      c.trigger().then<void>((_) {}, onError: (Object e) => error = e);
      await tester.pump(ms * 100);
      check(c).isLoading();
      check(error).isNull();
      await tester.pump(ms * 200);
      check(c).isIdle();
      check(error).isA<StateError>();
    });

    testWidgets('widget value beats the theme', (tester) async {
      final c = newController();
      await tester.pumpWidget(
        pumpHost(
          button(c, minLoadingDuration: ms * 100),
          theme: asyncButtonTheme(minLoadingDuration: floor),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump(ms * 99);
      check(c).isLoading();
      await tester.pump(ms);
      check(c).isIdle();
    });

    testWidgets('theme value applies when the widget sets none', (
      tester,
    ) async {
      final c = newController();
      await tester.pumpWidget(
        pumpHost(
          button(c, minLoadingDuration: null),
          theme: asyncButtonTheme(minLoadingDuration: floor),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump(ms * 299);
      check(c).isLoading();
      await tester.pump(ms);
      check(c).isIdle();
    });

    testWidgets('unmounting mid-floor leaves an external controller loading '
        'until its floor elapses', (tester) async {
      final c = newController();
      await tester.pumpWidget(pumpHost(button(c)));
      await tester.tap(find.byType(TextButton));
      await tester.pump(ms * 100);
      await tester.pumpWidget(pumpHost(const SizedBox()));
      await tester.pump(ms);
      check(
        because: 'the run and its floor belong to the controller',
        c,
      ).isLoading();
      await tester.pump(ms * 200);
      check(c).isIdle();
    });

    testWidgets('unmounting before the floor elapses leaves no pending timer', (
      tester,
    ) async {
      await tester.pumpWidget(
        pumpHost(
          AsyncButton(
            onPressed: () async {},
            minLoadingDuration: floor,
            builder: textBuilder,
            child: const Text('label'),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump(ms * 100);
      await tester.pumpWidget(pumpHost(const SizedBox()));
    });

    testWidgets(
      'reset() during the floor resolves trigger() immediately with no '
      'pending timer',
      (tester) async {
        final c = newController();
        await tester.pumpWidget(pumpHost(button(c)));
        var settled = false;
        c.trigger().then((_) => settled = true);
        await tester.pump(ms * 100);
        check(settled).isFalse();
        c.reset();
        await tester.pump();
        check(settled).isTrue();
      },
    );

    testWidgets(
      'a controller moved to a button without a floor runs with no floor',
      (tester) async {
        final c = newController();
        await tester.pumpWidget(pumpHost(button(c)));
        await tester.pumpWidget(pumpHost(const SizedBox()));
        await tester.pumpWidget(pumpHost(button(c, minLoadingDuration: null)));
        var settled = false;
        c.trigger().then((_) => settled = true);
        await tester.pump();
        check(
          because: 'the floor comes from the bound button',
          settled,
        ).isTrue();
        check(c).isIdle();
      },
    );
  });

  group('AsyncButton controller ownership', () {
    testWidgets('reset() mid-flight abandons the run; a new tap starts one', (
      tester,
    ) async {
      final c = newController();
      var calls = 0;
      final runs = <Completer<void>>[];
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton(
            controller: c,
            onPressed: () {
              calls++;
              final run = Completer<void>();
              runs.add(run);
              return run.future;
            },
            child: const Text('Pay'),
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      c.reset();
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      runs.first.complete();
      await tester.pump();
      check(calls).equals(2);
      check(
        because: 'the abandoned run must not clear the new one',
        c,
      ).isLoading();

      runs.last.complete();
      await tester.pump();
      check(c).isIdle();
    });

    testWidgets('a controller swapped in mid-flight shows its own idle state', (
      tester,
    ) async {
      final ext = newController();
      var calls = 0;
      final (:onPressed, :completer) = pendingPress();
      Future<void> counted() {
        calls++;
        return onPressed();
      }

      Widget host(AsyncButtonController? c) => _columnOf([
        ValueListenableBuilder<bool>(
          valueListenable: ext,
          builder: (_, busy, _) => Text('busy=$busy'),
        ),
        TextAsyncButton(
          controller: c,
          onPressed: counted,
          child: const Text('Go'),
        ),
      ]);

      await tester.pumpWidget(host(null));
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      await tester.pumpWidget(host(ext));
      check(tester.takeException()).isNull();
      check(
        because: 'the run stays with the internal controller it started on',
        ext,
      ).isIdle();
      check(find.byType(CircularProgressIndicator)).findsNone();
      check(find.text('busy=false')).findsOne();

      await tester.tap(find.byType(TextButton));
      await tester.pump();
      check(
        because: 'a tap starts a run on the new controller',
        calls,
      ).equals(2);
      check(find.text('busy=true')).findsOne();

      completer.complete();
      await tester.pump();
      check(ext).isIdle();
    });

    testWidgets('one controller on two mounted buttons throws StateError', (
      tester,
    ) async {
      final c = newController();
      Widget button(String label) => SizedBox(
        width: 100,
        height: 48,
        child: TextAsyncButton(
          controller: c,
          onPressed: () async {},
          child: Text(label),
        ),
      );
      await tester.pumpWidget(
        pumpHost(Row(mainAxisSize: .min, children: [button('A'), button('B')])),
      );
      check(tester.takeException()).isA<StateError>();
    });

    testWidgets('external controller detaches when its button unmounts', (
      tester,
    ) async {
      final c = newController();
      var ran = 0;
      await tester.pumpWidget(
        pumpHost(
          ElevatedAsyncButton(
            controller: c,
            onPressed: () async => ran++,
            child: const Text('Go'),
          ),
        ),
      );
      await tester.pumpWidget(pumpHost(const SizedBox()));
      check(because: 'no button is attached any more', c.canTrigger).isFalse();
      await check(c.trigger()).throws<StateError>();
      check(because: 'unmounted button callback must not run', ran).equals(0);
    });

    testWidgets('swapped-out external controller no longer runs onPressed', (
      tester,
    ) async {
      final a = newController();
      final b = newController();
      var ran = 0;
      Widget button(AsyncButtonController c) => ElevatedAsyncButton(
        controller: c,
        onPressed: () async => ran++,
        child: const Text('Go'),
      );
      await tester.pumpWidget(pumpHost(button(a)));
      await tester.pumpWidget(pumpHost(button(b)));
      await check(a.trigger()).throws<StateError>();
      check(because: 'a is detached from the button', ran).equals(0);
    });

    final reparentKey = GlobalKey();
    for (final (name, before, after) in <(String, _Button, _Button)>[
      (
        'same-slot type swap',
        (c, f) => ElevatedAsyncButton(
          controller: c,
          onPressed: f,
          child: const Text('Go'),
        ),
        (c, f) => TextAsyncButton(
          controller: c,
          onPressed: f,
          child: const Text('Go'),
        ),
      ),
      (
        'same-slot key swap',
        (c, f) => ElevatedAsyncButton(
          key: const ValueKey(1),
          controller: c,
          onPressed: f,
          child: const Text('Go'),
        ),
        (c, f) => ElevatedAsyncButton(
          key: const ValueKey(2),
          controller: c,
          onPressed: f,
          child: const Text('Go'),
        ),
      ),
      (
        'GlobalKey reparent into a Padding',
        (c, f) => ElevatedAsyncButton(
          key: reparentKey,
          controller: c,
          onPressed: f,
          child: const Text('Go'),
        ),
        (c, f) => Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedAsyncButton(
            key: reparentKey,
            controller: c,
            onPressed: f,
            child: const Text('Go'),
          ),
        ),
      ),
    ]) {
      testWidgets('$name rebinds the controller to the new button', (
        tester,
      ) async {
        final c = newController();
        final ran = <String>[];
        await tester.pumpWidget(
          pumpHost(before(c, () async => ran.add('old'))),
        );
        await tester.pumpWidget(pumpHost(after(c, () async => ran.add('new'))));
        check(tester.takeException()).isNull();
        check(c.canTrigger).isTrue();
        await c.trigger();
        check(ran).deepEquals(['new']);
      });
    }

    for (final (name, before, after) in <(String, _Button, _Button)>[
      (
        'keyed swap in a Column',
        (c, f) => ElevatedAsyncButton(
          key: const ValueKey(1),
          controller: c,
          onPressed: f,
          child: const Text('Go'),
        ),
        (c, f) => ElevatedAsyncButton(
          key: const ValueKey(2),
          controller: c,
          onPressed: f,
          child: const Text('Go'),
        ),
      ),
      (
        'same-key type swap in a Column',
        (c, f) => ElevatedAsyncButton(
          key: const ValueKey('k'),
          controller: c,
          onPressed: f,
          child: const Text('Go'),
        ),
        (c, f) => TextAsyncButton(
          key: const ValueKey('k'),
          controller: c,
          onPressed: f,
          child: const Text('Go'),
        ),
      ),
    ]) {
      testWidgets('$name rebinds the controller to the new button', (
        tester,
      ) async {
        final c = newController();
        final ran = <String>[];
        await tester.pumpWidget(
          _columnOf([before(c, () async => ran.add('old'))]),
        );
        await tester.pumpWidget(
          _columnOf([after(c, () async => ran.add('new'))]),
        );
        check(tester.takeException()).isNull();
        check(c.canTrigger).isTrue();
        await c.trigger();
        check(ran).deepEquals(['new']);
      });

      testWidgets(
        '$name mid-run keeps the in-flight run and prevents double submit',
        (tester) async {
          final c = newController();
          var runs = 0;
          final completer = Completer<void>();
          Future<void> work() {
            runs++;
            return completer.future;
          }

          await tester.pumpWidget(_columnOf([before(c, work)]));
          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();
          check(c).isLoading();
          check(runs).equals(1);

          await tester.pumpWidget(_columnOf([after(c, work)]));
          check(tester.takeException()).isNull();
          check(c).isLoading();
          check(find.byType(CircularProgressIndicator)).findsOne();

          await tester.tap(find.byType(CircularProgressIndicator));
          await tester.pump();
          check(runs).equals(1);

          completer.complete();
          await tester.pump();
          check(c).isIdle();
        },
      );
    }

    testWidgets(
      'swapping controllers twice mid-floor leaves the run and its floor on '
      'the first controller',
      (tester) async {
        final c1 = newController();
        final c2 = newController();
        final c3 = newController();
        Widget host(AsyncButtonController c) => pumpHost(
          ElevatedAsyncButton(
            controller: c,
            minLoadingDuration: const Duration(seconds: 5),
            onPressed: () async {},
            child: const Text('Go'),
          ),
        );

        await tester.pumpWidget(host(c1));
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        check(c1).isLoading();

        for (final next in [c2, c3]) {
          await tester.pumpWidget(host(next));
          await tester.pump();
          check(c1).isLoading();
          check(next).isIdle();
          check(find.byType(CircularProgressIndicator)).findsNone();
        }

        await tester.pump(const Duration(seconds: 5));
        check(because: 'the floor elapsed on its own controller', c1).isIdle();
      },
    );

    testWidgets('an AnimatedSwitcher cross-fade of keyed buttons on one '
        'controller throws StateError', (tester) async {
      final c = newController();
      Widget host(int k) => pumpHost(
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: ElevatedAsyncButton(
            key: ValueKey(k),
            controller: c,
            onPressed: () async {},
            child: Text('$k'),
          ),
        ),
      );
      await tester.pumpWidget(host(1));
      await tester.pumpWidget(host(2));
      check(
        because: 'both buttons are mounted mid-transition',
        find.byType(ElevatedButton).evaluate(),
      ).length.equals(2);
      check(tester.takeException()).isA<StateError>();

      await tester.pumpAndSettle();
      check(tester.takeException()).isNull();
      check(find.byType(ElevatedButton)).findsOne();
      check(c.canTrigger).isTrue();
    });

    testWidgets('a GlobalKey move between two parents mid-flight keeps the '
        'binding and the run', (tester) async {
      final c = newController();
      final key = GlobalKey();
      final (:onPressed, :completer) = pendingPress();
      Widget host({required bool left}) {
        final button = ElevatedAsyncButton(
          key: key,
          controller: c,
          onPressed: onPressed,
          child: const Text('Go'),
        );
        return _columnOf([
          SizedBox(child: left ? button : null),
          SizedBox(child: left ? null : button),
        ]);
      }

      await tester.pumpWidget(host(left: true));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      for (final left in [false, true]) {
        await tester.pumpWidget(host(left: left));
        check(because: 'left: $left', tester.takeException()).isNull();
        check(because: 'the run survives the move', c).isLoading();
      }

      completer.complete();
      await tester.pump();
      check(c).isIdle();
      check(c.canTrigger).isTrue();
    });

    testWidgets('shifting controllers along a row mid-flight leaves the run '
        'on its controller', (tester) async {
      final c1 = newController();
      final c2 = newController();
      final c3 = newController();
      var bRan = 0;
      final (:onPressed, :completer) = pendingPress();
      Widget a(AsyncButtonController c) => TextAsyncButton(
        controller: c,
        onPressed: onPressed,
        child: const Text('a'),
      );
      Widget b(AsyncButtonController c) => TextAsyncButton(
        controller: c,
        onPressed: () async => bRan++,
        child: const Text('b'),
      );

      await tester.pumpWidget(_columnOf([a(c1), b(c2)]));
      c1.trigger();
      await tester.pump();
      await tester.pumpWidget(_columnOf([a(c2), b(c3)]));
      await tester.pump();
      check(tester.takeException()).isNull();
      check(
        because: 'no button drives c1, but its run is in flight',
        c1,
      ).isLoading();
      check(c2).isIdle();
      check(c3).isIdle();
      check(find.byType(CircularProgressIndicator)).findsNone();
      await c3.trigger();
      check(bRan).equals(1);

      completer.complete();
      await tester.pump();
      check(c1).isIdle();
    });

    for (final MapEntry(key: name, value: parent) in _parents.entries) {
      testWidgets('a 3-way controller rotation in a $name leaves each run on '
          'its controller', (tester) async {
        final cs = [newController(), newController(), newController()];
        final ran = <int>[];
        final (:onPressed, :completer) = pendingPress();
        Widget buttons(int shift) => _hostIn(parent, [
          for (var i = 0; i < 3; i++)
            TextAsyncButton(
              controller: cs[(i + shift) % 3],
              onPressed: i == 0 ? onPressed : () async => ran.add(i),
              child: Text('$i'),
            ),
        ]);

        await tester.pumpWidget(buttons(0));
        cs[0].trigger();
        await tester.pump();
        await tester.pumpWidget(buttons(1));
        await tester.pump();
        check(tester.takeException()).isNull();
        check(cs[0]).isLoading();
        check(cs[1]).isIdle();
        check(cs[2]).isIdle();
        check(
          because: 'button 2 now drives cs[0] and shows its run',
          find.byType(CircularProgressIndicator),
        ).findsOne();
        check(find.text('0')).findsOne();
        check(find.text('1')).findsOne();
        check(find.text('2')).findsNone();
        var joinedDone = false;
        final joined = cs[0].trigger().then((_) => joinedDone = true);
        await cs[2].trigger();
        check(because: 'busy cs[0] joins its run', ran).deepEquals([1]);
        await tester.pump();
        check(joinedDone).isFalse();

        completer.complete();
        await tester.pump();
        await joined;
        check(cs[0]).isIdle();
      });
    }

    testWidgets('removing the loading first row of an unkeyed list keeps its '
        'run on its controller and leaves the other rows idle', (tester) async {
      final cs = [for (var i = 0; i < 5; i++) newController()];
      final (:onPressed, :completer) = pendingPress();
      Widget rows(int from) => _columnOf([
        for (var i = from; i < 5; i++)
          TextAsyncButton(
            controller: cs[i],
            onPressed: i == 0 ? onPressed : () async {},
            child: Text('$i'),
          ),
      ]);

      await tester.pumpWidget(rows(0));
      cs[0].trigger();
      await tester.pump();
      await tester.pumpWidget(rows(1));
      await tester.pump();
      check(tester.takeException()).isNull();
      check([for (var i = 0; i < 5; i++) cs[i].value])
          .deepEquals([true, false, false, false, false]);
      check(find.byType(CircularProgressIndicator)).findsNone();

      completer.complete();
      await tester.pump();
      check(cs[0]).isIdle();
    });

    for (final loadingFirst in [true, false]) {
      testWidgets('exchanging controllers mid-flight leaves the run on its '
          'controller (loading ${loadingFirst ? 'first' : 'second'})', (
        tester,
      ) async {
        final x = newController();
        final y = newController();
        final (:onPressed, :completer) = pendingPress();
        Widget host(AsyncButtonController first, AsyncButtonController second) {
          return _columnOf([
            TextAsyncButton(
              controller: first,
              onPressed: loadingFirst ? onPressed : () async {},
              child: const Text('1'),
            ),
            TextAsyncButton(
              controller: second,
              onPressed: loadingFirst ? () async {} : onPressed,
              child: const Text('2'),
            ),
          ]);
        }

        await tester.pumpWidget(host(x, y));
        (loadingFirst ? x : y).trigger();
        await tester.pump();
        await tester.pumpWidget(host(y, x));
        await tester.pump();
        check(tester.takeException()).isNull();
        check(
          because: 'the run stays on the controller that started it',
          loadingFirst ? x : y,
        ).isLoading();
        check(loadingFirst ? y : x).isIdle();
        check(
          because: 'the button now driving the busy controller shows the run',
          find.text(loadingFirst ? '2' : '1'),
        ).findsNone();
        check(find.text(loadingFirst ? '1' : '2')).findsOne();
        check(find.byType(CircularProgressIndicator)).findsOne();

        completer.complete();
        await tester.pump();
        check(x).isIdle();
        check(y).isIdle();
      });
    }

    testWidgets('removing an unkeyed sibling above a loading button keeps the '
        'run on its controller', (tester) async {
      final b = newController();
      var runs = 0;
      final completer = Completer<void>();
      Future<void> save() {
        runs++;
        return completer.future;
      }

      Widget host({required bool show}) => _columnOf([
        if (show)
          TextAsyncButton(onPressed: () async {}, child: const Text('other')),
        TextAsyncButton(
          controller: b,
          onPressed: save,
          child: const Text('save'),
        ),
      ]);

      await tester.pumpWidget(host(show: true));
      await tester.tap(find.text('save'));
      await tester.pump();
      check(b).isLoading();

      await tester.pumpWidget(host(show: false));
      check(tester.takeException()).isNull();
      check(because: 'save is still in flight', b).isLoading();
      check(b.canTrigger).isFalse();
      check(find.byType(CircularProgressIndicator)).findsOne();

      await tester.tap(find.byType(TextButton));
      await tester.pump();
      check(because: 'a tap while loading is swallowed', runs).equals(1);

      completer.complete();
      await tester.pump();
      check(b).isIdle();
    });

    testWidgets('reordering unkeyed buttons mid-flight keeps the run on its '
        'controller', (tester) async {
      final b = newController();
      var runs = 0;
      final completer = Completer<void>();
      Future<void> save() {
        runs++;
        return completer.future;
      }

      Widget host({required bool swapped}) {
        final other = TextAsyncButton(
          onPressed: () async {},
          child: const Text('other'),
        );
        final saveButton = TextAsyncButton(
          controller: b,
          onPressed: save,
          child: const Text('save'),
        );
        return _columnOf(swapped ? [saveButton, other] : [other, saveButton]);
      }

      await tester.pumpWidget(host(swapped: false));
      await tester.tap(find.text('save'));
      await tester.pump();

      await tester.pumpWidget(host(swapped: true));
      check(tester.takeException()).isNull();
      check(because: 'save is still in flight', b).isLoading();
      check(find.text('other')).findsOne();
      check(find.text('save')).findsNone();
      check(
        because: 'the spinner sits in the first slot, where save now is',
        tester.getCenter(find.byType(CircularProgressIndicator)).dy,
      ).isLessThan(tester.getCenter(find.text('other')).dy);

      var joinedDone = false;
      final joined = b.trigger().then((_) => joinedDone = true);
      await tester.pump();
      check(because: 'a trigger while loading joins the run', runs).equals(1);
      check(joinedDone).isFalse();

      completer.complete();
      await tester.pump();
      await joined;
      check(b).isIdle();
    });

    Widget floorPair(
      AsyncButtonController first,
      AsyncButtonController second,
    ) {
      return _columnOf([
        TextAsyncButton(
          controller: first,
          minLoadingDuration: const Duration(seconds: 2),
          onPressed: () async {},
          child: const Text('x'),
        ),
        TextAsyncButton(
          controller: second,
          minLoadingDuration: const Duration(milliseconds: 100),
          onPressed: () async {},
          child: const Text('y'),
        ),
      ]);
    }

    testWidgets('exchanging controllers mid-floor keeps each run on its own '
        'controller and floor', (tester) async {
      final a = newController();
      final b = newController();
      await tester.pumpWidget(floorPair(a, b));
      await tester.tap(find.text('x'));
      await tester.tap(find.text('y'));
      await tester.pump();

      await tester.pumpWidget(floorPair(b, a));
      await tester.pump(const Duration(milliseconds: 300));
      check(because: "y's 100 ms floor has elapsed on b", b).isIdle();
      check(because: "x's 2 s floor still holds a", a).isLoading();

      await tester.pump(const Duration(seconds: 2));
      check(a).isIdle();
    });

    testWidgets('resetting both controllers after a mid-floor exchange leaves '
        'no pending timer', (tester) async {
      final a = newController();
      final b = newController();
      await tester.pumpWidget(floorPair(a, b));
      await tester.tap(find.text('x'));
      await tester.tap(find.text('y'));
      await tester.pump();

      await tester.pumpWidget(floorPair(b, a));
      a.reset();
      b.reset();
      await tester.pump();
      check(a).isIdle();
      check(b).isIdle();
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('two buttons exchanging controllers keep both bindings', (
      tester,
    ) async {
      final a = newController();
      final b = newController();
      final ran = <String>[];
      Widget host(AsyncButtonController first, AsyncButtonController second) {
        return _columnOf([
          TextAsyncButton(
            controller: first,
            onPressed: () async => ran.add('first'),
            child: const Text('1'),
          ),
          TextAsyncButton(
            controller: second,
            onPressed: () async => ran.add('second'),
            child: const Text('2'),
          ),
        ]);
      }

      await tester.pumpWidget(host(a, b));
      await tester.pumpWidget(host(b, a));
      check(tester.takeException()).isNull();
      await b.trigger();
      await a.trigger();
      check(
        because: 'the outgoing unbind must not clear the incoming binding',
        ran,
      ).deepEquals(['first', 'second']);
    });

    testWidgets(
      'an external controller swapped out mid-flight stays busy for outside '
      'listeners',
      (tester) async {
        final ext = newController();
        final (:onPressed, :completer) = pendingPress();
        Widget host(AsyncButtonController? c) => _columnOf([
          ValueListenableBuilder<bool>(
            valueListenable: ext,
            builder: (_, busy, _) => Text('busy=$busy'),
          ),
          TextAsyncButton(
            controller: c,
            onPressed: onPressed,
            child: const Text('Go'),
          ),
        ]);

        await tester.pumpWidget(host(ext));
        ext.trigger();
        await tester.pump();
        check(find.text('busy=true')).findsOne();

        await tester.pumpWidget(host(null));
        check(tester.takeException()).isNull();
        check(because: 'its run is still in flight', ext).isLoading();
        check(
          because: 'the button now shows its new internal controller',
          find.byType(CircularProgressIndicator),
        ).findsNone();
        await tester.pump();
        check(find.text('busy=true')).findsOne();

        completer.complete();
        await tester.pump();
        check(ext).isIdle();
        await tester.pump();
        check(find.text('busy=false')).findsOne();
      },
    );
  });
}
