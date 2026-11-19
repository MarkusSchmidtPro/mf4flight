import 'dart:core';

import 'package:mf4flight/mf4flight.dart' show serviceProvider, ViewModel;

import '../repository/markdown_repository.dart';



class HelpViewModel extends ViewModel {
  HelpViewModel(this._resourceKey, this._values);

  final String _resourceKey;
  final Map<String, String>? _values;

  String markDown = "---";

  @override
  Future<void> initAsync() async {
    final repos = serviceProvider<MarkdownRepository>();
    markDown = await repos.fromResource(_resourceKey, values:_values);
  }
}
