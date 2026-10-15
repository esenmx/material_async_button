/// Drop-in async wrappers for Flutter Material buttons.
///
/// See `ElevatedAsyncButton`, `FilledAsyncButton`, `OutlinedAsyncButton`,
/// `TextAsyncButton`, `IconAsyncButton`, and `FloatingActionAsyncButton` for
/// the named-constructor variants. Use `AsyncButton` when you need a custom
/// non-Material button.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_async_button/src/line_box.dart';
import 'package:material_ui/material_ui.dart';

part 'src/async_button.dart';
part 'src/async_button_controller.dart';
part 'src/buttons/async_material_button.dart';
part 'src/buttons/elevated_async_button.dart';
part 'src/buttons/filled_async_button.dart';
part 'src/buttons/floating_action_async_button.dart';
part 'src/buttons/icon_async_button.dart';
part 'src/buttons/outlined_async_button.dart';
part 'src/buttons/text_async_button.dart';
part 'src/material_async_button_theme.dart';
