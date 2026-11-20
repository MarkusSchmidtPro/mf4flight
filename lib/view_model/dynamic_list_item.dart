/// Support list item widget with dynamic content
/// that reloads its content (the viewmodel) every time
/// the list item widget is built.
///
/// List Items need some thoughts when the display "dynamic" content:
/// content that needs to be refreshed every time when the list is
/// reloaded. The list item state may have change.
///
/// Using the following example does not work:
/// ```dart
/// // In the parent (list) view
/// //    child: FavoriteListItem.content( ..
///
/// // The list item widget
/// static StatelessWidget content(Favorite favorite, {required bool selected, Key? key}) =>
///    ChangeNotifierProvider(
///     create: (_) => FavoriteListItemViewModel(favorite.grid, selected),
///     child: FavoriteListItem._(),
///   );
/// ```
///
///  Junie: _Flutter rebuilds widgets, but reuses the existing provider element
///  when its type and key remain the same.
///  `create: ()` initializes the view model once per provider lifetime;
///  A new selected value does not rerun it. Also, selected is final in FavoriteListItemViewModel._
///
///  That means, that subsequent calls of `FavoriteListItem.content(` won't
///  create new `FavoriteListItemViewModel` instances, and the `selected` property is not passed,
///  neither is `initAsync()` called on the [ViewModel].
///
///
/// DynamicListItem acts somehow as a proxy or glue between the view model and the view
// class DynamicListItem<TViewModel extends ViewModel> extends StatelessWidget {
//   DynamicListItem({required this.viewModelBuilder, required this.view});
//
//   final StatelessWidget view;
//   final Create<TViewModel> viewModelBuilder;
//
//   @override
//   Widget build(BuildContext context) => ChangeNotifierProvider<TViewModel?>(
//       create: viewModelBuilder,
//       builder: (context, child) {
//         Provider.of<TViewModel>(context).update();
//         return child!;
//       },
//       child: view);
// }
