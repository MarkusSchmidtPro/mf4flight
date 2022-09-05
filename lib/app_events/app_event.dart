class AppEvent<TArgs extends AppEventArgs> {
  AppEvent(this.sender, this.eventArgs);

  final Object sender;
  final TArgs eventArgs;
}

class AppEventArgs {
  AppEventArgs.empty();

  AppEventArgs();
}