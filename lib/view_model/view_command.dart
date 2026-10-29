import 'package:flutter/material.dart';

/// A [ViewCommand] represents a ViewModel that performs actions
/// on elements that can be enabled or disabled [enabled].
///
/// IMPORTANT: Changing [enabled] or [isVisible] does not refresh the view,
/// and you need to call [notifyListeners].
///
/// The [ViewCommand] should do teh action on the view model and the domain models.
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
class ViewCommand {
  const ViewCommand({required this.action, this.enabled = true, this.visible = true});

  /// Define a command which is not supported to execute.
  ///
  /// Use this in base view models and override
  /// in inheriting view models to provide specific implementation.
  /// A command that is not supported to execute.
  const ViewCommand.notSupported() : action = _notSupported, enabled = false, visible = false;

  final bool enabled;
  final bool visible;
  final Future<void> Function() action;

  static Future<void> _notSupported() async => throw Exception('Command not supported');
}
