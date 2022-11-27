import 'package:mf4flight/mf4flight.dart';

/// Represents a list item in a grid and list view.
class SelectableItem {
  /// Create new new instance with a unique [id], a [_viewModelData] and a [state]
  SelectableItem(this.id, {ItemState? initialState})
      : state = initialState ?? new ItemState();

  final int id;
  final ItemState state;
  void toggleSelection() => state.selected=!state.selected;
}

/// A [ListItem] state.
class ItemState {
  ItemState( {this.selected=false});
  bool selected;
}

enum ListChangedType {
  selectionChanged,

  /// One or more List items has been added or removed.
  listChanged,
  bindData
}

class ListChangedEventArgs extends EventArgs {
  ListChangedEventArgs(this.change);

  final ListChangedType change;
}

