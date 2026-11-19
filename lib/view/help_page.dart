import 'dart:core';

import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:provider/provider.dart';

import '../view_model/viewmodel.dart';
import '../widgets/command_buttons.dart';
import 'help_page_vm.dart';

/// A help icon that naviates to (opens) a help page
/// for context [helpContext] when clicked.
class HelpIcon extends StatelessWidget {
  HelpIcon(String helpContext, {super.key})
    : _showHelpCommand = NavigateCommand(targetView: HelpPage.content(helpContext));

  final NavigateCommand _showHelpCommand;

  @override
  Widget build(BuildContext context) => CommandButton.iconLabel(
    icon: Icons.help_outline,
    iconColor: Theme.of(context).colorScheme.primary,
    command: _showHelpCommand,
  );
}

class HelpPage extends StatelessWidget {
  /* Private constructor to disallow ContactView instances.
     Instead ContactView.show( args) should be used to create
     a new ContactView with a bound ViewModel.
   */
  HelpPage._();

  // static Future<void> show(String helpKey,{Map<String, String>? values}) async =>
  //     await showView(HelpPage.content(helpKey, values));

  static StatelessWidget content(String helpKey, [Map<String, String>? values]) =>
      ChangeNotifierProvider(create: (_) => HelpViewModel(helpKey, values), child: HelpPage._());

  @override
  Widget build(BuildContext context) => MyPage<HelpViewModel>(
    title: "Help",
    contentBuilder: (_, vm) => MarkdownWidget(data: vm.markDown),
  );
}

/// A standard page with an [appBar] (represented by a text title
/// or by a provided appBar widget) and based on a [ViewModel].
///
/// ```dart
/// class HelpPage extends MyPage<HelpViewModel> {
///   /* Private constructor to disallow ContactView instances.
///      Instead ContactView.show( args) should be used to create
///      a new ContactView with a bound ViewModel.
///    */
///   HelpPage._() : super(
///       title: "Help",
///       childBuilder: (_, vm) => MarkdownWidget(data: vm.markDown)
///   );
///
///   /// Build the widget with the provided parameters,
///   /// which are used to create a new ViewModel instance of type [HelpViewModel].
///   static StatelessWidget build(String helpKey, {Map<String, String>? values}) =>
///       MyPage.content(HelpViewModel(helpKey, values));
/// }
/// ```
class MyPage<TViewModel extends ViewModel> extends StatelessWidget {
  @protected
  MyPage({
    required this._contentBuilder,
    this._appBarBuilder,
    this._bottomBarBuilder,
    this._title,
    super.key,
  }) : assert( _title != null || _appBarBuilder != null);

  final AppBar Function(BuildContext context, TViewModel vm)? _appBarBuilder;
  final Widget Function(BuildContext context, TViewModel vm)? _bottomBarBuilder;
  final Widget Function(BuildContext context, TViewModel vm) _contentBuilder;
  final String? _title;


  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TViewModel>();
    return Scaffold(
      appBar: _appBarBuilder != null ? _appBarBuilder(context, vm) : AppBar(title: Text(_title!)),
      body: Padding(padding: const EdgeInsets.all(16), child: _contentBuilder(context, vm)),
      bottomNavigationBar: _bottomBarBuilder != null ? _bottomBarBuilder(context, vm) : null,
    );
  }
}
