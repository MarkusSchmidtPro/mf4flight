# mvvm4flight - MVVM for Flutter Light

An approach to separate presentation logic from the view: 

> *Flutter with MVVM (Model - View - ViewModel) pattern*

## About the author

I am coming from C# - from the Microsoft and Windows world. In the past 30 years, I have written many applications from real-time applications over large enterprise apps in service oriented environments to simple desktop or console applications. I love C# and I am used to Microsoft's world. 

As some kind of natural evolution I started with Xamarin making my first mobile experiences: I had done it for two years, dropped it ... came to Dart / Flutter, in February 2019.

## Introduction

When I started with Flutter I tried to understand its patterns and best practices. I found *bloc*, *stream* and many other useful things. However, what confused me a lot





## MVVM vs. Bloc 

I got used to the MVVM model which was introduced many years ago, as a pattern to separate logic from the view. (Please notice, I said 'logic' not 'business logic' - more later.) 

### Plain Flutter goes bloc

When I started with *Flutter* I was very confused to see how everything is mixed within a single dart file:

```dart
... // UI = View - that's how it looks like
floatingActionButton: FloatingActionButton(
     onPressed: _incrementCounter,
     tooltip: 'Increment',
     child: Icon(Icons.add),
), 
...
```

This is probably fine to demonstrate how *Hello Flutter!* works, but with your second view (or screen - however you may call it) the struggle will start and you will finally end up in a nightmare.

```dart
// ViewModel - that is what view logic is suppsed to do when a user clicks.
void _incrementCounter() {
	setState(() => _counter++ );
}
```

I continued reading about how *Flutter* tackles architecture and I found the *[Bloc](https://felangel.github.io/bloc/#/architecture) (the business logic component)* pattern: *Presentation - Business Logic (bloc) - Data*. Well, a good idea to split *business logic* from *presentation*. 

But, what about *presentation logic*?

### Presentation logic

You need to know, Microsoft uses a declarative (XAML) approach to design a UI. XAML simply defines how your UI looks like. For example: fancy UI, old fashioned, Material or not, green or red. 

I am developer and I am really not good at building fancy, modern UIs - neither with XAML, nor with Widgets. Creating and using a (material) template, applying it on all controls, providing visual effects, swipe left/up/down etc. - this all is UI design!

Looking at the sample above, `FloatingActionButton` together with all its designer properties is UI (aka. View). `_incrementCounter`  - or, to be more precise - `_counter++` is not view, this is *ViewModel* aka presentation logic!

### Presentation logic in Flutter

Let's extend the sample from above a bit, and let's disable the button when counter is greater than three. What you Flutter folks do?  You would probably change a single line to 

`.. floatingActionButton: (_counter>3) ? null : FloatingActionButton( ...`

Well, this works, and you will see the button disappearing. However, you started adding presentation logic to the view: when this property has a certain value disable a widget. 

In Flutter everything's a Widget - even a State is a Widget: `State<T extends StatefulWidget>`.  

I would really prefer to say: 

> A Widget *has a* State !
>
> instead of reading extends (inheritance) as 'A Widget is a State'.

<sub>Markus Schmidt, 2019-10-06</sub>