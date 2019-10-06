import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

abstract class INotifyChanged<TEventData>
{
	void subscribe(void subscriber(TEventData eventData));
}

class NotifyChanged<TEventData>
	implements INotifyChanged
{
	Subject<EventArguments<TEventData>> _subject;

	void subscribe(void subscriber(EventArguments<TEventData> eventData)) {
		// lazy initialization, no subscriber, no _viewModelSubject 
		if (_subject == null) _subject = new PublishSubject <EventArguments<TEventData>>();
		_subject.stream.listen(subscriber);
	}

	@protected
	void notifyChanged(TEventData eventData) {
		if (_subject == null) return; // obviously no subscribers
		_subject.add(new EventArguments( source: this, data: eventData));
	}

	@mustCallSuper
	dispose() {
		if( _subject== null) return;	
		_subject.close();
		_subject=null;
	}
}


class EventArguments<T>
{
	EventArguments({ this.source, this.data});
	final dynamic source;
	final T data;
}