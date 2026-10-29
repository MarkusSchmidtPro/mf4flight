import 'dart:core';

import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:provider/provider.dart';

import '../locator.dart';
import '../view_model/view_command.dart';
import 'bottom_action_bar.dart';
import 'help_page_vm.dart';

// class HelpCommand extends ButtonCommand {
// }

class HelpIcon extends CommandIcon {
  
  HelpIcon(String _helpContext, ) : super( 
    icon: Icons.help_outline,
    command: ViewCommand( action: () async => await showViewAsync(HelpPage.show(_helpContext))),
  );

  static Future<void> showViewAsync<TResult>(StatelessWidget view) async => 
      await navigator.push<TResult>(MaterialPageRoute(builder: (_) => view));
}

class HelpPage extends StatelessWidget {
  /* Private constructor to disallow ContactView instances.
     Instead ContactView.show( args) should be used to create
     a new ContactView with a bound ViewModel.
   */
  const HelpPage._();

  static StatelessWidget show(String helpKey, {Map<String, String>? values}) =>
      ChangeNotifierProvider<HelpViewModel>(
        create: (_) => HelpViewModel(helpKey, values: values),
        child: const HelpPage._(),
      );

  @override
  Widget build(BuildContext context) => _buildPage(context, context.watch<HelpViewModel>());

  Scaffold _buildPage(BuildContext context, HelpViewModel pageVM) => Scaffold(
        appBar: AppBar(title: const Text("Help!")),
        body: _buildPageBody(context, pageVM),
      );

  Widget _buildPageBody(BuildContext bodyContext, HelpViewModel pageVM) =>
      MarkdownWidget(data: pageVM.markDown);
}
