import 'package:flutter/material.dart';
import 'package:material_async_button/material_async_button.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'material_async_button demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        extensions: [AsyncButtonTheme.material()],
      ),
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
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (fail) throw StateError('simulated failure');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('material_async_button')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
            onPressed: () => _simulateWork(fail: true),
            child: const Text('OutlinedAsyncButton (fails)'),
          ),
          const SizedBox(height: 8),
          TextAsyncButton(
            onPressed: _simulateWork,
            child: const Text('TextAsyncButton'),
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
          const _SectionLabel('Per-button overrides'),
          ElevatedAsyncButton(
            onPressed: _simulateWork,
            successChild: const Text('Saved!'),
            successDisplayDuration: const Duration(milliseconds: 1200),
            cooldownDuration: const Duration(seconds: 1),
            child: const Text('Custom successChild + 1s cooldown'),
          ),
          const SizedBox(height: 8),
          OutlinedAsyncButton(
            onPressed: () => _simulateWork(fail: true),
            errorChild: const Text('Failed — try again'),
            errorDisplayDuration: const Duration(milliseconds: 1200),
            onError: (error, _) => debugPrint('error: $error'),
            child: const Text('Custom errorChild + onError'),
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
                onPressed: () =>
                    _externalController.invalidate('server rejected'),
                child: const Text('invalidate()'),
              ),
              OutlinedButton(
                onPressed: _externalController.markSuccess,
                child: const Text('markSuccess()'),
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
            animateSize: true,
            builder: (ctx, child, callback, status) => Material(
              color: switch (status) {
                AsyncButtonStatusIdle() ||
                AsyncButtonStatusLoading() => Colors.indigo,
                AsyncButtonStatusSuccess() => Colors.green,
                AsyncButtonStatusError() => Colors.red,
              },
              clipBehavior: .hardEdge,
              shape: const StadiumBorder(),
              child: InkWell(onTap: callback, child: child),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('Custom', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
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
