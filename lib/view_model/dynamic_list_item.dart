import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'viewmodel_base.dart';

class DynamicListItem<TViewModel extends ViewModelBase> extends StatelessWidget {
  DynamicListItem(
      this.argumentBuilder, {
        required this.viewModelBuilder,
        required this.view,
        super.key,
      }) ;

  final StatelessWidget view;
  final Create<TViewModel> viewModelBuilder;
  final dynamic Function() argumentBuilder;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<TViewModel?>(
      create: viewModelBuilder,
      builder: (context, child) {
        var args = argumentBuilder();
        Provider.of<TViewModel>(context).update(args);
        return child!;
      },
      child: view);
}