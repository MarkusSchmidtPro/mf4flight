import 'dart:core';

import 'package:mf4flight/mf4flight.dart' show serviceProvider, ViewModel;

import '../repository/markdown_repository.dart';



class HelpViewModel extends ViewModel {
  HelpViewModel(this.resourceKey, {this.values});

  final String resourceKey;
  final Map<String, String>? values;

  late final MarkdownRepository repos;
  String markDown = "---";

  @override
  Future<void> initAsync() async {
    repos = serviceProvider<MarkdownRepository>();
    markDown = await repos.fromResource(resourceKey, values:values);
  }
}
