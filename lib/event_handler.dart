

/// A method than can handler events according to the event-handler pattern.
/// 
/// Event-handler pattern:
/// A class that ca raise events accepts an optional event handlers in its constructor.
/// ```Dart
/// class SelectableItem {
///   SelectableItem( { this.onChangedHandler });
///   final EventHandler<OnChangedEventArgs>? onChangedHandler;
/// }
/// ```
/// To raise an event, the handler is called:
/// ```dart
/// onChanged?.call( this, new OnChangedEventArgs(itemData));
/// ```
typedef EventHandler<TArgs extends EventArgs> = void Function( Object sender, TArgs e);
typedef EventHandlerAsync<TArgs extends EventArgs> = Future<void> Function ( Object sender, TArgs e) ;


/// Event arguments base class.
class EventArgs {
  EventArgs.empty();

  EventArgs();
}



