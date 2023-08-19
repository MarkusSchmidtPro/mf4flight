import 'package:mf4flight/mf4flight.dart';

class SelectableViewItem<TRecord extends RecordBase> {
  SelectableViewItem(this.record, [this.selected = false]);

  final TRecord record;
  final bool selected;
}