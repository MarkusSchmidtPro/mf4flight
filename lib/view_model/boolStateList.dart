import 'dart:collection';

class BoolStateItemArgs<TData> {
  BoolStateItemArgs(this.data, [this.selected = false]);

  final TData data;
  final bool selected;
}

class BoolStateList<TKey> {
  final HashSet<TKey> _items = new HashSet();

  int get count => _items.length;

  bool set(TKey id, bool value) {
    if (value)
      _items.add(id);
    else
      _items.remove(id);

    return value;
  }

  Iterable<TKey> get list => _items;

  bool get(TKey id) => _items.contains(id);

  bool toggle(TKey id) => set(id, !get(id));

  void clear() => _items.clear();

  void cleanse(Iterable<TKey> fullList) {
    final itemsNotInFullList = _items.difference(fullList.toSet());
    _items.removeAll(itemsNotInFullList);
  }
}
