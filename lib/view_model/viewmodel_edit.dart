import 'dart:async';

import 'package:flutter/material.dart';

import '../mf4flight.dart';

/// A [ViewModelBase] implementation that supports editable data.
abstract class ViewModelEdit extends ViewModelBase {
  @mustCallSuper
  ViewModelEdit() : super() {
    _createCommands();
  }

  /// Check whether the current view can be closed.
  ///
  /// There are three options how a view can be closed:
  /// [CloseViewRequestSource]
  /// *Back Button*: In that case there is no default behaviour, it is not
  /// generally defined how the view should behave.
  /// In such case *the view's* [decisionIfDirtyAsync] will be called and ask for a
  /// decision. You may display a pop-up and aks the user what to do, or simply
  /// return a [ViewCloseBehaviour]. The default for [decisionIfDirtyAsync] is
  /// [ViewCloseBehaviour.discardDataClose] so that dirty data will be discarded
  /// when the Back-Button is used.
  /// decisionIfDirty: () async => await queryViewCloseDialog(context)
  ///
  /// *closeView Command*: The [saveAndCloseViewCommand] tries to save data and
  /// then close the view. Of course, if saving fails the view remains open
  /// showing the error src.api.v1.messages.
  ///
  /// *cancelView Command*: The [cancelEditCloseViewCommand] closes the view without
  /// saving dirty data - discard data.
  Future<bool> viewCanCloseAsync(
      {Future<ViewCloseBehaviour> Function() decisionIfDirtyAsync =
          Dialog2.viewCloseDialogAsync}) async {
    // bool dataValid = onViewValidateControls();
    // if (dataValid && !await onViewIsDirtyAsync()) return true;

    bool closeView;
    switch (closeViewRequestSource) {
      case CloseViewRequestSource.cancelAndCloseViewCommand:
        closeView = true;
        break;

      case CloseViewRequestSource.backButton:
        bool isDirty = await onViewIsDirtyAsync();
        if (isDirty) {
          // Back Button and data has changed!
          if (onViewValidateControls()) {
            // Controls are ok to be saved
            // Data is dirty, the user has to make a decision
            ViewCloseBehaviour decision = await decisionIfDirtyAsync();
            switch (decision) {
              case ViewCloseBehaviour.discardDataClose:
                closeView = true;
                break;
              case ViewCloseBehaviour.cancelClose:
                closeView = false;
                break;
              case ViewCloseBehaviour.saveDataClose:
                closeView = await validateAndSaveChangesAsync();
                break;
            }
          } else {
            // Back Button and Controls are not ok
            // Expect user want to discard edits
            closeView = true;
          }
        } else {
          // Data not dirty and we can close the View
          closeView = true;
        }
        break;

      case CloseViewRequestSource.pushView:
      case CloseViewRequestSource.saveAndCloseViewCommand:
        closeView = await validateAndSaveChangesAsync();
        break;
      default:
        throw "upps";
    }

    // Important: After the close request has been evaluated,
    // we must reset the source for subsequent calls.
    closeViewRequestSource = CloseViewRequestSource.backButton;
    return closeView;
  }

  /// Validate the view controls to ensure the view's data can be saved.
  ///
  /// Use the [errors] collection to collect all validation errors.
  /// ````dart
  /// void onValidateControls() {
  ///    if (salutation.length < 4 || Helper.nameInvalidChars.hasMatch(salutation))
  ///      errors.addError('salutation', 'Bitte geben sie ei..
  ///  }
  /// ```
  /// In the example, the error is filed under the key 'salutation'.
  /// You can access these errors in a [InputDecoration.errorText] property
  /// using the [getFieldError] method.
  /// ```dart
  /// child: new TextField(
  ///   controller: viewModel.salutationController,
  ///   decoration: InputDecoration(
  ///   labelText: 'Anrede',
  ///   errorText: viewModel.getFieldError('salutation'),
  /// ))),
  /// ```
  @protected
  bool onViewValidateControls() {
    logger.finest("onViewValidateControlsBase()");
    return true;
  }

  /// Checks if the current view is dirty (contains changes).
  @protected
  Future<bool> onViewIsDirtyAsync() async => throw 'isDirty() must be overridden';

  /// Get and persist the view's data.
  ///
  /// When this method is called the view is considered to be
  /// valid (passed the [onViewValidateControls] checks).
  /// In case the view's data is a [DatabaseRecord] the record fields
  /// are updated with the data from the view and then the record is saved
  /// to the database. To avoid updating the database with unchanged data use
  /// the [DatabaseRecord.trackChanges] pattern.
  ///
  /// ```dart
  /// /// The record that was used to populate the view.
  /// FriendRecord get _original => _args.item;
  ///
  /// @override
  /// Future onViewSaveAsync() async {
  ///   // Track Changes Pattern
  ///   _original.trackChanges(new FriendRecord());
  ///   _viewToRecord(_original);
  ///   await _c.friends.saveChangesAsync(_original);
  ///   showSnackBar('${_original.toString()} gespeichert!');
  ///   serviceProvider<SyncRequestService>().triggerSyncRequest();
  /// }
  /// ```
  @protected
  Future onViewSaveAsync() async => throw 'onSaveChangesAsync() must be overridden';

  /// Validate all controls and save the view's data.
  ///
  /// Returns [true] if data has not been modified or
  /// if it was saved successfully, otherwise [false]
  Future<bool> validateAndSaveChangesAsync() async {
    logger.finest(">validateAndSaveChangesAsyncBase");
    if (!onViewValidateControls()) {
      // if validation fails we want to
      // notify the view to show error messages
      logger.finest('validateControls() failed');
      notifyListeners();
      return false;
    }

    // Do not call isDirty before validating the controls.
    // IsDirty requires a valid DB record from the view,
    // and if validation fails, the record is not valid.
    if (!await onViewIsDirtyAsync()) return true;
    await onViewSaveAsync();
    return errors.isEmpty;
  }

  // region Error view.Messages

  /// Get a list with the view model's errors.
  final ViewErrors errors = new ViewErrors();

  /// Get the view's error or null.
  ///
  /// The viewError contains the exception message, when
  /// the @viewModelEdit is saved (@onSaveChangesAsync).
  String? getViewError() => errors.getFirst('view')?.errorMessage;

  void setViewError(String errorMessage) {
    logger.severe(errorMessage);
    errors.addError('view', errorMessage);
    // for now it is not expected the view has errors
    assert(false, 'saveChangesAsync: $errorMessage');
  }

  /// Get the error message for a specified field
  /// or null on case of no error
  String? getFieldError(String fieldKey) => errors.getFirst(fieldKey)?.errorMessage;

  // endregion

  // region Commands

  /// Request view close (navigator.maybePop()) with
  /// [CloseViewRequestSource.saveAndCloseViewCommand].
  ///
  /// See [viewCanCloseAsync] if and how the view will be closed.
  late ICommand saveAndCloseViewCommand;

  void _createCommands() {
    saveAndCloseViewCommand = new RelayCommand((context) async {
      closeViewRequestSource = CloseViewRequestSource.saveAndCloseViewCommand;
      await navigator.maybePop();
    });
  }

  // endregion
}
