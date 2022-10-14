import 'package:flutter/material.dart';

import '../mf4flight.dart';

/// Dialog2 to avoid conflict with Material Dialog.
class Dialog2 {
  /// Shows a dialog to ask the uer if an item should be deleted.
  ///
  /// The dialog is based on [showQueryDialogAsync] and is does not
  /// offer a cancel action. This means, there is no 'X' in the dialog
  /// and the user must make a yes/no decision.
  ///
  /// @Returns [DialogResult.ok] :YES, delete!
  /// @Returns [DialogResult.cancel] :NO, do not delete.
  static Future<DialogResult> showDeleteDecisionDialogAsync() async =>
      await showQueryDialogAsync('Daten unwiderruflich löschen?',
          'Sollen die ausgewählten Daten\nunwiderruflich gelöscht werden?',
          action1: TextButton(
              child: Text('ja'),
              onPressed: () => navigator.pop(DialogResult.ok)),
          action2: ElevatedButton(
              child: Text('nein'),
              onPressed: () => navigator.pop(DialogResult.cancel)));

  /// Show a dialog and offer [actions] for selection.
  ///
  /// If the user should have the option the *cancel* the dialog via an 'X'
  /// in the title bar, simply provide a [cancelAction].
  ///
  /// @returns [DialogResult]
  ///
  /// ```dart
  /// var userDecision = await Dialog2.showQueryDialogAsync('Daten unwiderruflich löschen?',
  ///         'Sollen die ausgewählten Daten\nunwiderruflich gelöscht werden?',
  ///         action1:
  ///             TextButton(child: Text('ja'), onPressed: () => navigator.pop(DialogResult.action1)),
  ///         action2: ElevatedButton(
  ///             child: Text('nein'), onPressed: () => navigator.pop(DialogResult.action2)));
  ///     if (userDecision != DialogResult.action1) return;
  /// ```
  static Future<DialogResult> showQueryDialogAsync(
      String titleText, String message,
      {required Widget action1,
      Widget? action2,
      Widget? action3,
      VoidCallback? cancelAction}) async {
    //
    /*  System showDialog requires a BuildContext
        var dialogResult = await showDialog<DialogResult>(
          context: context,
          builder: (BuildContext context) => _getDialogWidget(titleText, message, actions: actions),
        ); 
    */

    var dialogResult = await _showDialogAsync(_getDialogWidget(
        titleText, message, action1, action2, action3, cancelAction));
    return dialogResult ?? DialogResult.dismissed;
  }

  /// Show a Dialog without a BuildContext.
  static Future<DialogResult?> _showDialogAsync(Widget dialog) async =>
      await navigator.push(
        new MaterialPageRoute<DialogResult>(builder: (_) => dialog),
      );

  /// Get an ActionDialog widget.
  ///
  /// If [cancelAction] is null the title bar comes without an 'X' and
  /// the user cannot cancel the dialog. However, the uer can dismiss [DialogResult.dismissed]
  /// the dialog at any time.
  ///
  /// @param onCancelAction The action that is called when the user selects
  ///                       the 'close' button, which is the 'X' on the title bar
  ///                       to the right.
  static AlertDialog _getDialogWidget(
      String titleText,
      String message,
      Widget action1,
      Widget? action2,
      Widget? action3,
      VoidCallback? cancelAction) {
    final List<Widget> actions = [action1]; // mandatory action
    if (action2 != null) actions.add(action2);
    if (action3 != null) actions.add(action3);

    return AlertDialog(
      titlePadding: EdgeInsets.only(left: 24.0, top: 24.0, right: 10.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      title: Row(children: [
        Expanded(child: Text(titleText)),
        (cancelAction == null) // X or Blank
            ? Text('')
            : IconButton(icon: Icon(Icons.close), onPressed: cancelAction)
      ]),
      content: Text(message),
      actions: actions,
    );
  }

  static Future<void> notYetImplementedMessage() async {
    await Dialog2.showQueryDialogAsync(
        'Es gibt etwas zu tun!', 'not yet implemented!',
        action1: ElevatedButton(
            child: Text('ok'),
            onPressed: () => navigator.pop(DialogResult.action)));
  }

  /// Determine the behaviour when a view is closed with changed data.
  static Future<ViewCloseBehaviour> viewCloseDialogAsync() async {
    const Map<DialogResult, ViewCloseBehaviour> mapResult = {
      DialogResult.action: ViewCloseBehaviour.saveDataClose,
      DialogResult.discard: ViewCloseBehaviour.discardDataClose,
      DialogResult.dismissed: ViewCloseBehaviour.cancelClose,
    };

    DialogResult dialogResult = await Dialog2.showQueryDialogAsync(
        'Änderungen erkannt!', 'Sollen die Änderungen gespeichert werden?',
        action1: TextButton(
            child: Text('nein'),
            onPressed: () => navigator.pop(DialogResult.discard)),
        action2: ElevatedButton(
            child: Text('ja'),
            onPressed: () => navigator.pop(DialogResult.action)));

    assert(mapResult.containsKey(dialogResult), "Result not mapped");
    return mapResult[dialogResult]!;
  }
}

enum DialogResult {
  /// The user has clicked the 'X' in the dialog's title bar,
  /// to cancel the dialog without making a decision.
  canceled,

  /// The user clicked on the 'back' button and
  /// he did not make a decision about the dialog.
  dismissed,

  /// The user has chosen action1 on the dialog.
  ///
  /// If the dialog displays cancel / ok decision,
  /// action1 should be cancel and displayed to the left.
  action,

  /// The user has chosen action2 on the dialog.
  ///
  /// If the dialog displays cancel / ok decision,
  /// action2 should be ok and displayed to the right.
  discard,

  /// The user has chosen action3 on the dialog.
  action3,
  ok,
  cancel
}
