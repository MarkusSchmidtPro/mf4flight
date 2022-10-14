import 'package:flutter/material.dart';

/// Represent a Command.
///
/// A Command represents an action that is triggered by a View.
/// A Command is always bound to a visual element.
/// ```dart
/// CommonWidgets.iconButton(  icon: new Icon(Icons.delete_outline),
///   onPressed: !viewModel.deleteCommand.canExecute()
///               ? null
///               : () async {
///                       await viewModel.deleteCommand.execute(context);
///                       navigator.pop( ViewCloseResult.Deleted);
///               }
///   )
/// ```
abstract class ICommand {
  Future<void> executeAsync(BuildContext context, [dynamic args]);

  bool canExecute();
}

class CancelCommandArgs {
  CancelCommandArgs() : args = null;
  CancelCommandArgs.withArgs(this.args);
  final dynamic args;
  bool cancel = false;
}
