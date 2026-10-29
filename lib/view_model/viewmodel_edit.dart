import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mf4flight/repository/i_repository.dart';

import '../enums.dart';
import '../locator.dart';
import '../view/dialog2.dart';
import '../view/view_errors.dart';
import 'viewmodel.dart';

/// A [ViewModel] implementation that supports editable data and form workflows.
///
/// Protected methods start with "on.." when they are called from this super/base class.
/// on-methods should be implemented in the inheriting class but not called directly.
/// You may place them in a "// region ViewModel implementation"
///
/// Solves high-impact form problems: centralizes dirty checking, unifies
/// validation rules, prevents accidental data loss during navigation,
/// and standardizes save, discard, and close lifecycles across the application.
abstract class ViewModelEdit<TModel> extends ViewModel {
  /// The source which requests to close the view.
  CloseViewRequestSource closeViewRequestSource = CloseViewRequestSource.backButton;

  @protected
  ViewModelEdit({required this.repos}) : super();

  final IRepository<TModel> repos;

  bool get isSaving => _isSaving;

  late TModel _savedModel; // zuletzt persistierter Stand (Baseline)
  set model(TModel v) => _savedModel = v;

  TModel get model => _savedModel;

  bool _isSaving = false;

  /// Dynamic projection of the current form state into the domain model.
  //TModel getDraft() => viewToModel();

  /// Compares the current view projection against the last persisted baseline.
  bool isDirty() {
    try {
      return !dataLoading && !(viewToModel() == _savedModel);
    } catch (_) {
      return true; // Form contains unparseable/divergent input
    }
  }

  /// Clears any validation or view error state and discards pending form error markers.
  void discardChanges() {
    modelToView();
    _viewErrors.clear();
    notifyListeners();
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

  /// Optional override for domain/business invariant checks on the materialized model.
  @protected
  bool onValidateModel(TModel model) => true;

  /// Pupolate the view from the model.
  void modelToView() {}

  TModel viewToModel();

  /// Validate all controls [onValidateControls]
  /// and save the view's data [onSaveAsync] if dirty.
  /// Returns `true` if validation passed and data was saved (or clean),
  /// `false` if validation failed.
  Future<bool> saveAsync() async {
    if (!isDirty()) return true;

    // Phase 1: Validate UI controls before taking them over
    if (!validateControls()) {
      notifyListeners(); // Refresh UI to display errorText markers
      return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      // Phase 2: Materialize domain model from validated controls
      final entityToSave = viewToModel();

      // Optional Phase 2b: Domain-level validation hook
      if (!onValidateModel(entityToSave!)) return false;

      // Phase 3: Persist and synchronize baseline
      await repos.save(entityToSave);
      _savedModel = entityToSave; // Baseline updated -> isDirty becomes false
      _viewErrors.clear();
      return true;
    } catch (e, stackTrace) {
      logger.severe('Failed to save entity', e, stackTrace);
      setViewError('Speichern fehlgeschlagen: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
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

  // region User interaction

  /// Displays a save confirmation dialog.
  /// Can be overridden or invoked by views or [canCloseView].
  Future<ViewCloseBehaviour> askSaveAsync(
    BuildContext context, {
    String title = "Änderungen erkannt!",
    String message = "Sollen die Änderungen gespeichert werden?",
  }) async {
    DialogResultYesNoCancel dialogResult = await Dialog2.showQueryDialogAsync(
      context,
      title,
      message,
      actions: [Dialog2.noButton, Dialog2.yesButton],
      cancelButton: true,
    );

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
  Future<bool> canCloseView(
    BuildContext context, {
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
        if (isDirty()) {
          // Back Button and data has changed!
          if (validateControls()) {
            // Controls are ok to be saved
            // Data is dirty, the user has to make a decision
            ViewCloseBehaviour decision;
            if (decisionIfDirtyAsync != null) {
              decision = await decisionIfDirtyAsync();
            } else
            /*if (context != null)*/ {
              decision = await askSaveAsync(
                context,
                title: title ?? "Änderungen erkannt!",
                message: message ?? "Sollen die Änderungen gespeichert werden?",
              );
            }
            //else { decision = ViewCloseBehaviour.discardDataClose;            }
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
    notifyListeners();
    return canCloseView;
  }

  // endregion
}
