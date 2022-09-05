import 'package:collection/collection.dart' show IterableExtension;

import 'view_error.dart';

class ViewErrors {
  List<ViewError> _errors = [];
  int _nextErrorId = 0;
  int _getNextErrorId() => _nextErrorId++; 

  /// Get the first error message for a given errorContext.
  ///
  /// The @errorContext is either 'view' for the view's error context
  /// or any field name foe a field's error context.
  ViewError? getFirst(String errorContext) => _errors.firstWhereOrNull((x) => x.errorContext == errorContext);

  Iterable<ViewError> getAll(String errorContext) => _errors.where((x) => x.errorContext == errorContext);

  void addError(String errorContext, String errorMessage) =>
      _errors.add(new ViewError(_getNextErrorId(), errorContext, errorMessage));

  void removeError(int errorId) => _errors.remove(_errors.where((x) => x.errorId == errorId));

  void removeAll(String errorContext) => _errors.remove(_errors.where((x) => x.errorContext == errorContext));

  bool get isEmpty => _errors.isEmpty;

  void clear() => _errors.clear();
}
