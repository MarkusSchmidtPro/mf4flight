import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'viewmodel_base.dart';

class DynamicListItem<TViewModel extends ViewModel> extends StatelessWidget {
  DynamicListItem({required this.viewModelBuilder, required this.view});

  final StatelessWidget view;
  final Create<TViewModel> viewModelBuilder;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<TViewModel?>(
      create: viewModelBuilder,
      builder: (context, child) {
        Provider.of<TViewModel>(context).update();
        return child!;
      },
      child: view);
}
