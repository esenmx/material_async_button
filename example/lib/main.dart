import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_async_button/material_async_button.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'material_async_button demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formController = AsyncButtonController();
  final _externalController = AsyncButtonController();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _formController.dispose();
    _externalController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _simulateWork({bool fail = false}) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (fail) {
      throw Exception('simulated failure');
    }
  }

  /// A button is not the place to surface errors. A throw from `onPressed`
  /// returns the button to idle and re-propagates — so handle it here (in real
  /// apps, in your state management) and surface it your way.
  Future<void> _submit(BuildContext context, {bool fail = false}) async {
    try {
      await _simulateWork(fail: fail);
    } on Exception catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('material_async_button')),
    body: SingleChildScrollView(
      padding: const .all(16),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          const _SectionLabel('Material wrappers'),
          ElevatedAsyncButton(
            onPressed: _simulateWork,
            child: const Text('ElevatedAsyncButton'),
          ),
          const SizedBox(height: 8),
          ElevatedAsyncButton.icon(
            onPressed: _simulateWork,
            icon: const Icon(Icons.send),
            label: const Text('ElevatedAsyncButton.icon'),
          ),
          const SizedBox(height: 8),
          FilledAsyncButton(
            onPressed: _simulateWork,
            child: const Text('FilledAsyncButton'),
          ),
          const SizedBox(height: 8),
          FilledAsyncButton.tonal(
            onPressed: _simulateWork,
            child: const Text('FilledAsyncButton.tonal'),
          ),
          const SizedBox(height: 8),
          FilledAsyncButton.icon(
            onPressed: _simulateWork,
            icon: const Icon(Icons.save),
            label: const Text('FilledAsyncButton.icon'),
          ),
          const SizedBox(height: 8),
          FilledAsyncButton.tonalIcon(
            onPressed: _simulateWork,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('FilledAsyncButton.tonalIcon'),
          ),
          const SizedBox(height: 8),
          OutlinedAsyncButton(
            onPressed: () => _submit(context, fail: true),
            child: const Text('OutlinedAsyncButton (handles failure)'),
          ),
          const SizedBox(height: 8),
          TextAsyncButton(
            onPressed: _simulateWork,
            child: const Text('TextAsyncButton'),
          ),
          const SizedBox(height: 8),
          FilledAsyncButton(
            onPressed: _simulateWork,
            enabled: false,
            child: const Text('Disabled (enabled: false)'),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: .spaceEvenly,
            children: [
              IconAsyncButton(
                onPressed: _simulateWork,
                icon: const Icon(Icons.refresh),
              ),
              IconAsyncButton.filled(
                onPressed: _simulateWork,
                icon: const Icon(Icons.add),
              ),
              IconAsyncButton.filledTonal(
                onPressed: _simulateWork,
                icon: const Icon(Icons.edit),
              ),
              IconAsyncButton.outlined(
                onPressed: _simulateWork,
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          const Divider(height: 32),
          const _SectionLabel('Floating Action Buttons'),
          Row(
            mainAxisAlignment: .spaceEvenly,
            children: [
              FloatingActionAsyncButton(
                onPressed: _simulateWork,
                child: const Icon(Icons.navigation),
              ),
              FloatingActionAsyncButton.small(
                onPressed: _simulateWork,
                child: const Icon(Icons.navigation),
              ),
              FloatingActionAsyncButton.large(
                onPressed: _simulateWork,
                child: const Icon(Icons.navigation),
              ),
              FloatingActionAsyncButton.extended(
                onPressed: _simulateWork,
                icon: const Icon(Icons.navigation),
                label: const Text('Navigate'),
              ),
            ],
          ),
          const Divider(height: 32),
          const _SectionLabel('Animated spinner swap'),
          FilledAsyncButton(
            onPressed: _simulateWork,
            transitionBuilder: _animatedSwitchSize,
            child: const Text('Save (animated)'),
          ),
          const Divider(height: 32),
          const _SectionLabel('Custom loading widget'),
          ElevatedAsyncButton(
            onPressed: _simulateWork,
            loadingBuilder: (_) => const AsyncButtonSpinner(strokeWidth: 3),
            child: const Text('Thicker spinner'),
          ),
          const Divider(height: 32),
          const _SectionLabel('Form "Done" → controller.trigger()'),
          TextField(
            controller: _textController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Name'),
            onSubmitted: (_) => _formController.trigger(),
          ),
          const SizedBox(height: 8),
          ElevatedAsyncButton(
            controller: _formController,
            onPressed: _simulateWork,
            child: const Text('Submit'),
          ),
          const Divider(height: 32),
          const _SectionLabel('External controller'),
          ElevatedAsyncButton(
            controller: _externalController,
            onPressed: _simulateWork,
            child: const Text('Submit (driven by controller)'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: _externalController.trigger,
                child: const Text('trigger()'),
              ),
              OutlinedButton(
                onPressed: _externalController.reset,
                child: const Text('reset()'),
              ),
            ],
          ),
          const Divider(height: 32),
          const _SectionLabel('Custom button via AsyncButton'),
          AsyncButton(
            onPressed: _simulateWork,
            loadingBuilder: (context) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const AsyncButtonSpinner(strokeWidth: 3),
            ),
            builder: (context, child, callback, isLoading) {
              return Material(
                color: isLoading ? Colors.indigo.shade200 : Colors.indigo,
                clipBehavior: .hardEdge,
                shape: const StadiumBorder(),
                child: InkWell(onTap: callback, child: child),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('Custom', style: TextStyle(color: Colors.white)),
            ),
          ),
          const Divider(height: 32),
          const _SectionLabel('Custom button style OutlinedButton'),
          OutlinedAsyncButton.icon(
            onPressed: _simulateWork,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            style: OutlinedButton.styleFrom(
              padding: const .symmetric(vertical: 16, horizontal: 24),
              textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: .w500),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Animates the spinner swap: [AnimatedSwitcher] cross-fades between the idle
/// child and the loading spinner (already keyed by loading state), and
/// [AnimatedSize] tweens the button's width as they differ in size.
Widget _animatedSwitchSize(BuildContext context, Widget child, bool isLoading) {
  return AnimatedSize(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: child,
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}
