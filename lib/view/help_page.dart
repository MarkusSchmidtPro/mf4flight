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

  static StatelessWidget content(String helpKey, {Map<String, String>? values}) =>
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
    String? title,
    AppBar? appBar,
    this._bottomNavigationBar,
    super.key,
  }) : _appBar = appBar ?? AppBar(title: Text(title!));

  // @protected
  // static StatelessWidget content<TViewModel extends ChangeNotifier?>({
  //   required TViewModel Function() viewModelBuilder,
  // }) => ChangeNotifierProvider<TViewModel>(create: (_) => viewModelBuilder(), child: );

  final AppBar? _appBar;
  final Widget? _bottomNavigationBar;

  final Widget Function(BuildContext context, TViewModel vm) _contentBuilder;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TViewModel>();
    return Scaffold(
      appBar: _appBar,
      body: Padding(padding: const EdgeInsets.all(16), child: _contentBuilder(context, vm)),
      bottomNavigationBar: _bottomNavigationBar,
    );
  }
}
