import 'package:mf4flight/mf4flight.dart';

/// Provides functionality to manage a lists in a view model.
class SelectableList {
  EventHandler<ListChangedEventArgs>? _listChangedEvent;
  final List<SelectableItem> items = [];

  /// Register a handler to handle [ListChangedType] events.
  /// Do call this function once for each handler in the ViewModel constructor.
  void registerChangedHandler(
          EventHandler<ListChangedEventArgs>? listChangedHandler) =>
      _listChangedEvent = listChangedHandler;

  /// Bind a list as the new list [items].
  ///
  /// You can call this function as often as you want.
  ///
  /// Each item gets a corresponding [ItemState]
  /// object which track the state of the item, like selected.
  /// The link between the data item and the item state is the item.id.
  /// If [itemState] is provided, all items (incl. existing ones) will be initialized
  /// with itemState. Their state will actually be reset.
  /// If [itemState] is _not_ provided, no explicit initialisation takes place.
  /// All existing states will remain as-is, and new item's state is initialised
  /// with `new ItemState()`.
  void bindData(Iterable<SelectableItem> source) {
    items.clear();
    for (var item in source) {
      //item.list = this;
      items.add(item);
    }
    _listChangedEvent?.call(
        this, new ListChangedEventArgs(ListChangedType.bindData));
  }

  /// Remove and item and its state from the list.
  void remove(SelectableItem item) {
    items.remove(item);
    _listChangedEvent?.call(
        this, new ListChangedEventArgs(ListChangedType.listChanged));
  }

  int get length => items.length;

  /// Get all selected or unselected ([selected] = false) items .
  Iterable<SelectableItem> getSelectedItems({selected: true}) =>
      items.where((item) => item.state.selected == selected);

  /// Toggle the selected state of a given item.
  /// See also [setSelectionState] ans [isSelected].
  void toggleSelection(SelectableItem item) =>
      setSelectionState(item, !item.state.selected);

  /// Set the selected state and [notifyListeners] when state changed.
  void setSelectionState(SelectableItem item, bool value) {
    if (value != item.state.selected) {
      item.state.selected = value;
      _listChangedEvent?.call(
          this, new ListChangedEventArgs(ListChangedType.selectionChanged));
    }
  }

  /// Get the number of selected listItems.
  int getSelectedCount() => getSelectedItems().length;

  /// Clear all selections and [notifyListeners].
  void clearSelection() {
    for (var i in items) i.state.selected = false;
    _listChangedEvent?.call(
        this, new ListChangedEventArgs(ListChangedType.selectionChanged));
  }
}


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

