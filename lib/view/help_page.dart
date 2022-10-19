import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:stacked/stacked.dart';

import '../command/i_command.dart';
import '../view_model/help_vm.dart';

class HelpPageArgs {
  HelpPageArgs(this.helpContext);

  final String helpContext;
}

class HelpIcon extends StatelessWidget {
  HelpIcon( this._helpContext, this._command);
  final String _helpContext;
  final ICommand _command;
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.help, color: Theme.of(context).colorScheme.primary),
        onPressed: () async => await _command.executeAsync(context, _helpContext));
  }
}

class HelpPage extends StatelessWidget {
  final HelpPageArgs _viewArgs;

  HelpPage(this._viewArgs) : super(key: new Key(_viewArgs.helpContext));

  @override
  Widget build(BuildContext context) => ViewModelBuilder<HelpViewModel>.reactive(
        viewModelBuilder: () => new HelpViewModel(_viewArgs),
        onModelReady: (pageVM) => pageVM.lazyLoad(),
        builder: (BuildContext context, HelpViewModel pageVM, _) => _buildPage(context, pageVM),
      );

  Scaffold _buildPage(BuildContext context, HelpViewModel pageVM) => Scaffold(
        appBar: AppBar(title: const Text("Help!")),
        body: _buildPageBody(context, pageVM),
      );

  Widget _buildPageBody(BuildContext bodyContext, HelpViewModel pageVM) =>
      Markdown(data: pageVM.markDown);
}
