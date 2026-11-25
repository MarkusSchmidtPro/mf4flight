import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../locator.dart';
import '../view/dialog2.dart';
import '../view/textWithCountdown.dart';

/// Mixin providing UI feedback capabilities (snackbars, dialogs, help)
/// to ViewModels.
mixin ViewModelFeedbackMixin {
  /// Displays a SnackBar with optional countdown and rollback action.
  void showSnackBar(
    String message, {
    Future<void> Function()? commitFuncAsync,
    int commitDelay = 5,
    VoidCallback? rollbackFunc,
    String? rollbackLabel,
  }) {
    SnackBarAction? rollbackAction;
    if (rollbackFunc != null) {
      rollbackAction = SnackBarAction(label: rollbackLabel ?? "", onPressed: rollbackFunc);
    }
    messenger
        .showSnackBar(
          SnackBar(
            content: TextWithCountdown(text: message, countValue: commitDelay),
            action: rollbackAction,
            duration: Duration(seconds: commitDelay),
          ),
        )
        .closed
        .then((SnackBarClosedReason reason) async {
          if (reason != SnackBarClosedReason.action && commitFuncAsync != null) {
            await commitFuncAsync();
          }
        });
  }

  Future<DialogResultYesNoCancel> showDeleteDialogAsync() async =>
      await Dialog2.showQueryDialogAsync(
        "Daten unwiderruflich löschen?",
        "Sollen die ausgewählten Daten unwiderruflich gelöscht werden?",
        actions: [Dialog2.yesButton, Dialog2.noButton],
        cancelButton: true,
      );
}
