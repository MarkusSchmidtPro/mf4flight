import 'notifyChanged.dart';

class MainViewModel extends NotifyChanged<String> {
  int _counter = 0;
  bool _canIncrement = true; // initially we increment
  bool _canDecrement = false;

  //
  // region The public functionality that can be used in the view
  //
  int get counter => _counter;
  bool get canIncrement => _canIncrement;
  bool get canDecrement => _canDecrement;

  void upDownCommand() => _canIncrement 
  ? _incrementCommand() 
  : _decrementCommand();

  //
  // endregion
  //

  void _incrementCommand() {
    _counter++;
    if (_counter == 3) {
      _canIncrement = false;
      _canDecrement = true;
    }
    notifyChanged("counter"); // send the changed properties name
  }

  void _decrementCommand() {
    --_counter;
    if (_counter == 0) {
      _canIncrement = true;
      _canDecrement = false;
    }
    notifyChanged("counter");
  }


	dispose() => super.dispose();
}
