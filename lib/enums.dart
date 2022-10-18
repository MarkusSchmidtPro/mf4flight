/*
 * This file contains several enumeration to support mf4flight.
 */

class ViewResult {
  static const int None = 0;
  static const int Delete = 1;
}

/// Represents the state of a [ViewModel].
enum ViewModelState {
  /// The ViewModel is initializing, normally data is loaded in this state.
  initializing,
  /// The ViewModel is complete and ready to be used.
  ready,
  busy,
}

/// Define the source which requested the view to 'close'.
///
/// It would be more precise to say to "leave" to view because Nav.push()
/// is also considered.
enum CloseViewRequestSource {
  notDefined,
  backButton,
  saveAndCloseViewCommand,
  cancelAndCloseViewCommand,
  // Nav Push requests to leave the view.
  pushView
}

enum ViewCloseBehaviour {
  /// If data [ViewModelBase.isDirtyViewModel] it will be discarded and
  /// the view will be closed.
  discardDataClose,

  /// Cancel close view.
  cancelClose,

  /// Save data before closing. If save fails, of course,
  /// dialog remains open with an error message.
  saveDataClose
}
