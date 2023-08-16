import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

/// Provides functionality to manage a lists in a view model.
class SelectableList<TData> {
  var logger = Logger('SelectableList');
  /* ViewState and Data lists must be two different lists, 
      so that we can keep existing view states when data changes.
   */
  Iterable<ViewItem<TData>> get items => _items;
  List<ViewItem<TData>> _items = [];

  /// Bind a new list of items by keeping the [ItemViewState]
  /// of already existing items.
  ///
  /// * Update existing data
  /// * Remove existing items which are no longer part of [newItems].
  /// * Add [newItems] which do not yet exist in [items]
  void bindData(Iterable<ViewItem<TData>> newItems) {
    logger.finer( "Bind Data new-len=${newItems.length}, old-len=${_items.length}");
    for (var item in _items) item.viewState.obsolete = true;
    _bindDataAppend(newItems);
    _items.removeWhere((item) => item.viewState.obsolete);
  }

  void clear() => _items.clear();

  /// Append or update [newItems] on an existing list.
  ///
  /// Use this function over [bindData]() when you want to incrementally add items,
  /// after calling [clear](). This function does not delete any item, only update or insert.
  void _bindDataAppend(Iterable<ViewItem<TData>> newItems) {
    for (ViewItem<TData> newItem in newItems) add( newItem);
  }

  void add(ViewItem<TData> newItem) {
    ViewItem<TData>? existingItem = _items.firstWhereOrNull((e) => e.id == newItem.id);
    if (existingItem == null) {
      _items.add(newItem);
    } else {
      existingItem.data = newItem.data;
      existingItem.viewState.obsolete = false;
    }
  }

  operator [](index) => _items[index];

  int get length => _items.length;

  Iterable<ViewItem<TData>> getSelectedItems({bool selected = true}) =>
      _items.where((element) => element.viewState.selected == true);

  Iterable<String> getSelectedIds({bool selected = true}) =>
      getSelectedItems(selected: selected).map((e) => e.id);

  /// Get the number of selected listItems.
  int getSelectedCount() => getSelectedItems().length;

  void removeAt(int index) => _items.removeAt(index);

  void clearSelection() {
    for (var item in _items) item.viewState.selected = false;
  }
}

/// Represents an item in a list view that has a [ViewState]
/// and no data - only an [id]].
class ItemViewState {
  bool selected = false;

  /// Used internally to mark existing view-states as obsolete when binding new data.
  bool obsolete = false;

  void toggleSelection() => selected = !selected;
}

/// Represents an item in a list view that has a [ViewState]
/// and no data - only an [id]].
class ViewItem<TData>  {
  /// Create new new instance with a unique [id],
  ViewItem({required this.id, this.data});

  final String id;

  ItemViewState viewState = new ItemViewState();
  TData? data;
}
