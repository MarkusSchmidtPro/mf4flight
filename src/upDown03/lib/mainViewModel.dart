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

  //
  // endregion
  //

  void incrementCommand() {
    _counter++;
    canDo();
  }

  void decrementCommand() {
    --_counter;
    canDo();
  }

  void canDo() {
    _canIncrement = _counter < 3;
    _canDecrement = _counter > 0;
    notifyChanged("counter"); // send the changed properties name
  }

  dispose() => super.dispose();
}
