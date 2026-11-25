import 'dart:async';

import 'package:material_ui/material_ui.dart';
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
  @protected
  ViewModelEdit({required this.repos}) : super();

  final IRepository<TModel> repos;


  late TModel _savedModel; // zuletzt persistierter Stand (Baseline)
  set model(TModel v) => _savedModel = v;

  TModel get model => _savedModel;


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

  /// If [isDirty]
  /// Validate all controls [_validateControls]
  /// and save the view's data [onSaveAsync] if dirty.
  /// Returns `true` if validation passed and data was saved (or clean),
  /// `false` if validation failed.
  Future<bool> saveAsync() async {
    if (!isDirty()) return true;

    // Phase 1: Validate UI controls before taking them over
    if (!_validateControls()) {
      notifyListeners(); // Refresh UI to display errorText markers
      return false;
    }


    try {
      state = ViewModelState.saving;
      notifyListeners();

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
      state = ViewModelState.ready;
      notifyListeners();
    }
  }

  // region Error messages

  /// Get a list with the view model's errors.
  final ViewErrors _viewErrors = new ViewErrors();


  bool _validateControls() {
    _viewErrors.clear();
    onValidateControls(_viewErrors);
    return _viewErrors.isEmpty;
  }

  String? getViewError() => _viewErrors.getFirst('view')?.errorMessage;

  void setViewError(String errorMessage) {
    logger.severe(errorMessage);
    _viewErrors.addError('view', errorMessage);
    notifyListeners();
    assert(false, 'saveAsync: $errorMessage');
  }

  String? getFieldError(String fieldKey) => _viewErrors.getFirst(fieldKey)?.errorMessage;

  // endregion

  Future<void> saveAndCloseView() async {
    await navigator.maybePop();
    notifyListeners();
  }

  // region User interaction

  Future<void> closeViewAsk(CloseViewRequestSource source) async {
    if (await _canCloseView(source)) closeView();
  }


  /// Check whether the current view can be closed.
  Future<bool> _canCloseView(CloseViewRequestSource source) async {
    bool canCloseView;

    switch (source) {
      case CloseViewRequestSource.cancel:
        discardChanges();
        canCloseView = true;
        break;

      case CloseViewRequestSource.backButton:
        if (isDirty()) {
          // Back Button and data has changed!
          if (_validateControls()) {

            DialogResultYesNoCancel dialogResult = await Dialog2.showQueryDialogAsync(
              "Änderungen erkannt!",
              "Sollen die Änderungen gespeichert werden?",
              actions: [Dialog2.noButton, Dialog2.yesButton],
              cancelButton: true,
            );

            switch (dialogResult) {
              case DialogResultYesNoCancel.yes:
                canCloseView = await saveAsync();
                break;
              case DialogResultYesNoCancel.no:
                discardChanges();
                canCloseView = true;
                break;
              case DialogResultYesNoCancel.cancel:
                canCloseView = false;
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

      case CloseViewRequestSource.save:
        canCloseView = await saveAsync();
        break;
    }

    if( !canCloseView) notifyListeners();
    return canCloseView;
  }
}
