import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mf4flight/repository/i_repository.dart';

import '../enums.dart';
import '../locator.dart';
import '../view/dialog2.dart';
import '../view/view_errors.dart';
import 'viewmodel_base.dart';

/// A [ViewModel] implementation that supports editable data and form workflows.
///
/// Protected methods start with "on.." when they are called from this super/base class.
/// on-methods should be implemented in the inheriting class but not called directly.
/// You may place them in a "// region ViewModel implementation"
///
/// Solves high-impact form problems: centralizes dirty checking, unifies
/// validation rules, prevents accidental data loss during navigation,
/// and standardizes save, discard, and close lifecycles across the application.
abstract class ViewModelEdit<TViewArgs, TModel> extends ViewModel<TViewArgs> {
  /// The source which requests to close the view.
  CloseViewRequestSource closeViewRequestSource = CloseViewRequestSource.backButton;

  @protected
  ViewModelEdit(TViewArgs args, {required this.repos}) : super( args);

  final IRepository<TModel> repos;

  set model(TModel v) {
    _saved = v;
    _draft = v;
  }

  late final TModel _draft; // aktueller Entwurf, wird vom UI bearbeitet
  late TModel _saved; // zuletzt persistierter Stand (Baseline)
  bool _isSaving = false;

  TModel get draft => _draft;

  bool get isSaving => _isSaving;

  /// Abgeleitet, kein eigenes Flag.
  bool get isDirty => _draft != _saved;

  /// Darf gespeichert werden?
  bool get canSave => isDirty && !_isSaving;

  /// Clears any validation or view error state and discards pending form error markers.
  void discardChanges() {
    _draft = _saved;
    _viewErrors.clear();
    notifyListeners();
  }

  /// Displays a save confirmation dialog.
  /// Can be overridden or invoked by views or [viewCanCloseAsync].
  Future<ViewCloseBehaviour> askSaveAsync(
    BuildContext context, {
    String title = "Änderungen erkannt!",
    String message = "Sollen die Änderungen gespeichert werden?",
  }) async {
    DialogResultYesNoCancel dialogResult = await Dialog2.showQueryDialogAsync(
        context, title, message,
        actions: [Dialog2.noButton, Dialog2.yesButton], cancelButton: true);

    switch (dialogResult) {
      case DialogResultYesNoCancel.yes:
        return ViewCloseBehaviour.saveDataClose;
      case DialogResultYesNoCancel.no:
        return ViewCloseBehaviour.discardDataClose;
      case DialogResultYesNoCancel.cancel:
        return ViewCloseBehaviour.cancelClose;
    }
  }

  /// Check whether the current view can be closed.
  ///
  /// Intercepts back navigation or commands to prevent accidental data loss.
  /// Decoupled from hardcoded dialogs via optional [decisionIfDirtyAsync] callback.
  Future<bool> viewCanCloseAsync(
    BuildContext? context, {
    Future<ViewCloseBehaviour> Function()? decisionIfDirtyAsync,
    String? title,
    String? message,
  }) async {
    bool canCloseView;
    switch (closeViewRequestSource) {
      case CloseViewRequestSource.cancelAndCloseViewCommand:
        discardChanges();
        canCloseView = true;
        break;

      case CloseViewRequestSource.backButton:
        if (isDirty) {
          // Back Button and data has changed!
          if (validateControls()) {
            // Controls are ok to be saved
            // Data is dirty, the user has to make a decision
            ViewCloseBehaviour decision;
            if (decisionIfDirtyAsync != null) {
              decision = await decisionIfDirtyAsync();
            } else if (context != null) {
              decision = await askSaveAsync(
                context,
                title: title ?? "Änderungen erkannt!",
                message: message ?? "Sollen die Änderungen gespeichert werden?",
              );
            } else {
              decision = ViewCloseBehaviour.discardDataClose;
            }
            switch (decision) {
              case ViewCloseBehaviour.discardDataClose:
                discardChanges();
                canCloseView = true;
                break;
              case ViewCloseBehaviour.cancelClose:
                canCloseView = false;
                break;
              case ViewCloseBehaviour.saveDataClose:
                canCloseView = await saveAsync();
                break;
            }
          } else {
            // Back Button and Controls are not ok
            // Expect user wants to discard edits
            discardChanges();
            canCloseView = true;
          }
        } else {
          // Data not dirty and we can close the view
          canCloseView = true;
        }
        break;

      case CloseViewRequestSource.pushView:
      case CloseViewRequestSource.saveAndCloseViewCommand:
        canCloseView = await saveAsync();
        break;
      default:
        canCloseView = true;
        break;
    }

    // Important: After the close request has been evaluated,
    // we must reset the source for subsequent calls.
    closeViewRequestSource = CloseViewRequestSource.backButton;
    return canCloseView;
  }

  /// Validate the view controls to ensure the view's data can be saved.
  ///
  /// Use the [errors] collection to collect all validation errors.
  /// ````dart
  /// void onValidateControls(ViewErrors errors) {
  ///    if (salutation.length < 4 || Helper.nameInvalidChars.hasMatch(salutation))
  ///      errors.addError('salutation', 'Bitte geben sie ein...');
  /// }
  /// ```
  /// In the example, the error is filed under the key 'salutation'.
  /// You can access these errors in a [InputDecoration.errorText] property
  /// using the [getFieldError] method.
  /// ```dart
  /// child: TextField(
  ///   controller: viewModel.salutationController,
  ///   decoration: InputDecoration(
  ///     labelText: 'Anrede',
  ///     errorText: viewModel.getFieldError('salutation'),
  ///   ),
  /// )
  /// ```
  @protected
  void onValidateControls(ViewErrors errors) {}

  @protected
  TModel viewToModel();

  /// Validate all controls [onValidateControls]
  /// and save the view's data [onSaveAsync] if dirty.
  /// Returns `true` if validation passed and data was saved (or clean),
  /// `false` if validation failed.
  Future<bool> saveAsync() async {
    // letzte Absicherung, unabhängig von der UI
    if (!validateControls() || !canSave) return false;

    _isSaving = true;
    notifyListeners();
    bool saved = false;
    try {
      _draft = viewToModel();
      await repos.save(_draft);
      _saved = _draft; // Baseline aktualisieren -> isDirty wird false
      saved = true;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
    return saved;
  }

  // region Error messages

  /// Get a list with the view model's errors.
  final ViewErrors _viewErrors = new ViewErrors();

  bool validateControls() {
    _viewErrors.clear();
    onValidateControls(_viewErrors);
    return _viewErrors.isEmpty;
  }

  /// Get the view's error or null.
  ///
  /// The viewError contains the exception message when
  /// saving the ViewModel (@onSaveAsync).
  String? getViewError() => _viewErrors.getFirst('view')?.errorMessage;

  void setViewError(String errorMessage) {
    logger.severe(errorMessage);
    _viewErrors.addError('view', errorMessage);
    assert(false, 'saveAsync: $errorMessage');
  }

  String? getFieldError(String fieldKey) => _viewErrors.getFirst(fieldKey)?.errorMessage;

  // endregion

  Future<void> saveAndCloseView() async {
    closeViewRequestSource = CloseViewRequestSource.saveAndCloseViewCommand;
    await navigator.maybePop();
    notifyListeners();
  }
}
