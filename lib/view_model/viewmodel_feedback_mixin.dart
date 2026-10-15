import 'dart:async';

import 'package:flutter/material.dart';

import '../command/i_command.dart';
import '../command/relay_command.dart';
import '../command/relay_p_command.dart';
import '../enums.dart';
import '../locator.dart';
import '../view/dialog2.dart';
import '../view/help_page/help_page.dart';
import '../view/textWithCountdown.dart';
import 'viewmodel_navigation_mixin.dart';

/// Mixin providing UI feedback capabilities (snackbars, dialogs, help) 
/// to ViewModels.
mixin ViewModelFeedbackMixin on ViewModelNavigationMixin {
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
        .showSnackBar(SnackBar(
          content: TextWithCountdown(
            text: message,
            countValue: commitDelay,
          ),
          action: rollbackAction,
          duration: Duration(seconds: commitDelay),
        ))
        .closed
        .then((SnackBarClosedReason reason) async {
      if (reason != SnackBarClosedReason.action && commitFuncAsync != null) {
        await commitFuncAsync();
      }
    });
  }

  /// Prompts a confirmation dialog before deleting data.
  Future<DialogResultYesNoCancel> showDeleteDialogAsync(
    BuildContext context, {
    String title = "Daten unwiderruflich löschen?",
    String message = "Sollen die ausgewählten Daten unwiderruflich gelöscht werden?",
  }) async =>
      await Dialog2.showQueryDialogAsync(
        context,
        title,
        message,
        actions: [Dialog2.yesButton, Dialog2.noButton],
        cancelButton: true,
      );

  /// Creates a command that prompts for deletion confirmation and closes the view on result.
  ICommand deleteCloseViewCommand({
    required Future<void> Function() deleteActionAsync,
    bool Function()? canExecuteAction,
    String title = "Daten unwiderruflich löschen?",
    String message = "Sollen die ausgewählten Daten unwiderruflich gelöscht werden?",
  }) =>
      RelayCommand((context) async {
        switch (await showDeleteDialogAsync(context, title: title, message: message)) {
          case DialogResultYesNoCancel.cancel:
            break;
          case DialogResultYesNoCancel.yes:
            await deleteActionAsync();
            closeViewWithResult(ViewResult.Delete);
            break;
          case DialogResultYesNoCancel.no:
            closeViewWithResult(ViewResult.None);
            break;
        }
      }, canExecute: canExecuteAction ?? () => true);

  /// Command to navigate to the context help page.
  late ICommand showHelpCommand = RelayPCommand((context, helpContext) async {
    await showViewAsync(HelpPage.show(HelpPageArgs(helpContext)));
  });
}
