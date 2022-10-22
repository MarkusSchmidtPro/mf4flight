import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../mf4flight.dart';

enum DialogResultYesNoCancel { cancel, yes, no }

enum DialogResultOkCancel { cancel, ok }

/// Provides predefined dialog and user-interaction functionality.
///
/// 'Dialog2' to avoid conflict with Material Dialog.
/// See also: https://api.flutter.dev/flutter/material/AlertDialog-class.html
///
/// https://balsamiq.com/learn/articles/button-design-best-practices/
/// * In small windows, the primary action button should be placed at the bottom right
///
class Dialog2 {
  static void _close(Object result) => navigator.pop(result);

  static Widget get yesButton => TextButton(
      child: Text("yes"/*S.current.btn_yes*/), onPressed: () => _close(DialogResultYesNoCancel.yes));

  static Widget get noButton => TextButton(
      child: Text("no"/*S.current.btn_no*/), onPressed: () => _close(DialogResultYesNoCancel.no));

  static Widget get okButton =>
      TextButton(child: Text("ok"/*S.current.btn_ok*/), onPressed: () => _close(DialogResultOkCancel.ok));

  /// Shows a dialog to ask the uer if an item should be deleted.

  static Future<DialogResultYesNoCancel> showQueryDialogAsync(
      BuildContext? context, String titleText, String message,
      {List<Widget>? actions, bool cancelButton = false}) async {
    //
    Widget dialogView = new AlertDialog(
        titlePadding: EdgeInsets.only(left: 24.0, top: 24.0, right: 10.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        //
        title: !cancelButton
            ? Text(titleText)
            : Row(children: [
                Expanded(child: Text(titleText)),
                IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => _close(DialogResultYesNoCancel.cancel)),
              ]),
        //
        content: Text(message),
        actions: actions ?? [yesButton, noButton]);

    DialogResultYesNoCancel? result;
    if (context != null)
      result = await showDialog(context: context, builder: (context) => dialogView);
    else // for dialogs in event handlers etc. which do not have a context
      result = await _showDialogAsync(dialogView);
    // Turn dismissed (=null) into cancel
    return result ?? DialogResultYesNoCancel.cancel;
  }

  /*static Future<TResult> showQueryDialogAsync3<TResult>(
      BuildContext? context, String titleText, String message,
      {required List<Dialog3Action> dialogActions, bool cancelButton = false}) async {
    //
    Widget dialogView = new AlertDialog(
        titlePadding: EdgeInsets.only(left: 24.0, top: 24.0, right: 10.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        //
        title: !cancelButton
            ? Text(titleText)
            : Row(children: [
          Expanded(child: Text(titleText)),
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () => _close(DialogResultYesNoCancel.cancel)),
        ]),
        content: Text(message),
        actions: dialogActions.map( (e) => e.widget).toList()) ; //?? [yesButton, noButton]);

    TResult? result;
    if (context != null)
      result = await showDialog(context: context, builder: (context) => dialogView);
    else // for dialogs in event handlers etc. which do not have a context
      result = await _showDialogAsync(dialogView);
    // Turn dismissed (=null) into cancel
    return result ?? DialogResultYesNoCancel.cancel;
  }*/

  static Future<DialogResultOkCancel> showMarkdownAsync(BuildContext context, String md) async {
    var dialogView = Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Container(
            padding: EdgeInsets.only(left: 16.0, top: 24.0, right: 16.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      // decoration: BoxDecoration(border: Border.all()), DEBUG make border visible
                      child: MarkdownBody(data: md)),
                  Dialog2.okButton // Markdown(data: md),
                ])));

    DialogResultOkCancel? result =
        await showDialog(context: context, builder: (context) => dialogView);
    // Turn dismissed (=null) into cancel
    return result ?? DialogResultOkCancel.cancel;
  }

  /// Show a Dialog without a BuildContext.
  ///
  /// See also: showDialog<String>( context: context, builder: .. )
  /// The System [showDialog] requires a BuildContext:
  /// var dialogResult = await showDialog<DialogResult>(
  ///   context: context,
  ///   builder: (BuildContext context) => _getDialogWidget(titleText, message, actions: actions),
  /// );
  static Future<T> _showDialogAsync<T>(Widget dialog) async {
    T? dialogResult = await navigator.push<T?>(
      new MaterialPageRoute<T?>(builder: (_) => dialog),
    );
    assert(dialogResult != null);
    return dialogResult!;
  }
}



class Dialog3Action<TResult> {
  Dialog3Action(this.widget, {required this.result, this.actionAsync});

  Widget widget;
  TResult result;
  Future<void> Function()? actionAsync;
}

