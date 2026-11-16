import 'dart:async' show FutureOr;

import 'package:flutter/material.dart';

/// A [Command] represents a ViewModel that performs actions
/// on elements that can be enabled or disabled [enabled].
///
/// Encapsulates an invokable action bound to UI capability without
/// implying it is itself a visual widget.
///
/// IMPORTANT: Changing [enabled] or [isVisible] does not refresh the view,
/// and you need to call [notifyListeners].
///
/// The [Command] should do teh action on the view model and the domain models.
/// If the parent view needs to be updated, the command calls [notifyListeners],
/// which is then executed, when the [onPressed] action (from below) returns.
/// The command should *not* perform and view related (context) action - that is why
/// no [BuildContext] is passed.
/// ```dart
/// BottomBarAction(
///   ...
///   isVisible: vm.deleteCommand.visible,
///   isEnabled: vm.deleteCommand.enabled,
///   onPressed: () async {
///     // Command action
///     await vm.deleteCommand.action();
///     // View related actions
///     if (context.mounted) {
///       Navigator.of(context).pop();
///     }
/// ```
typedef CommandAction = FutureOr Function();

enum VisualState { enabled, disabled, invisible }

/// Represents a [CommandAction] with a [VisualState].
///
/// A Command is a backend component (biew-model) onyl without any visual representation.
/// A Command is basically the state of an action and an action to be executed.
class Command {
  @protected
  const Command(this._action, {this.state = VisualState.enabled});

  /// Represents a [CommandAction] which is always visble
  /// and an enabled or disabled state..
  factory Command.withState(CommandAction action, {required bool enabled}) =>
      Command(action, state: enabled ? VisualState.enabled : VisualState.disabled);

  factory Command.notSupported() =>
      Command(() => throw Exception('Command not supported'), state: VisualState.disabled);

  final CommandAction _action;
  final VisualState state;

  /// The action that is executed when the command is triggered.
  ///
  /// Returns _null_ when [state] is not [VisualState.enabled].
  CommandAction? get action => state == VisualState.enabled ? _action : null;
}
