class ViewError {
  final int _errorId;
  final String _errorContext;
  final String _errorMessage;

  ViewError(this._errorId, this._errorContext, this._errorMessage);

  String get errorContext => _errorContext;

  int get errorId => _errorId;

  String get errorMessage => _errorMessage;
}