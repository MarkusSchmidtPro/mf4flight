import 'package:mf4flight/mf4flight.dart';

/// Represents a list item in a grid and list view.
class ListItem<TModel> {
  /// Create new new instance with a unique [id] and the 'connected' [model].
  ListItem( this.id, this.model);

  final String id;
  final TModel model;
  
  /// Get the list this item belongs to.
  /// The [list] is automatically set when the item is added to the [ListVM].
  late final ListVM<TModel> list;

  bool get isSelected => list.isSelected(this);
  void toggleSelection() => list.toggleSelection(this);
}

/// A [ListItem] state.
class ItemState {
  bool selected = false;
}

enum ListChangedType {
  selectionChanged,

  /// One or more List items has been added or removed.
  listChanged, bindData
}

class ListChangedEventArgs extends EventArgs{
  ListChangedEventArgs( this.change);
  final ListChangedType change;
}

/// Provides functionality to manage a lists in a view model.
class ListVM<TItemData> {
  EventHandler<ListChangedEventArgs>? _listChangedEvent;

  /// Register a handler to handle [ListChangedType] events.
  /// Do call this function once for each handler in the ViewModel constructor.
  void registerChangedHandler( EventHandler<ListChangedEventArgs>? listChangedHandler) =>
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
  void bindData(Iterable<ListItem<TItemData>> source, {bool? selected}) {
    items.clear();
    for (var item in source) {
      item.list = this;
      items.add(item);
      if (selected != null) {
        // Reset item state
        itemStates[item.id] = new ItemState()..selected = selected;
      } else if (!itemStates.containsKey(item.id)) {
        // no explicit initialization, keep existing intact
        itemStates[item.id] = new ItemState();
      }
    }
    //_listChangedEvent?.call(this, new ListChangedEventArgs( ListChangedType.bindData));
  }

  /// Remove and item and its state from the list.
  void remove(ListItem item) {
    items.remove(item);
    itemStates.remove(item.id);
    _listChangedEvent?.call(this, new ListChangedEventArgs( ListChangedType.listChanged));
  }

  final List<ListItem<TItemData>> items = [];
  final Map<String, ItemState> itemStates = <String, ItemState>{};

  int get length => items.length;

  /// Get all selected or unselected ([selected] = false) items .
  List<ListItem<TItemData>> getSelectedItems({selected: true}) =>
      items.where((item) => itemStates[item.id]!.selected == selected).toList();

  /// Toggle the selected state of a given item.
  /// See also [setSelectionState] ans [isSelected].
  void toggleSelection(ListItem item) => setSelectionState(item, !isSelected(item));

  /// Set the selected state and [notifyListeners] when state changed.
  void setSelectionState(ListItem item, bool value) {
    if (value != isSelected(item)) {
      itemStates[item.id]!.selected = value;
      _listChangedEvent?.call(this, new ListChangedEventArgs( ListChangedType.selectionChanged));
    }
  }

  /// Get the selected state of a given item
  bool isSelected(ListItem item) => itemStates[item.id]!.selected;

  /// Get the number of selected listItems.
  int getSelectedCount() => itemStates.values.where((item) => item.selected).length;

  /// Clear all selections and [notifyListeners].
  void clearSelection() {
    for (var md in itemStates.values) md.selected = false;
    _listChangedEvent?.call(this, new ListChangedEventArgs( ListChangedType.selectionChanged));
  }
}
