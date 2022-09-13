# virtual_dom

The Virtual DOM is a small, lightweight, low-level implementation of the Virtual DOM.

Version: 0.1.2

## What is this software and what is it not?

This software does not contain any ready-made user interface elements.  
This software is the basis and is intended for the implementation of user interface elements (application components) and client web applications from scratch.

## What is a virtual DOM?

Virtualization is a rather complex implementation, despite the small size, of the interaction of various virtual nodes, possibly in different states, the renderer, the mechanism for tracking their state, the procedures for their identification, comparison and decision-making about their reuse by rebuilding.  
The virtual DOM is a tree of virtual nodes that is used to build the DOM tree.  
The virtual tree supports partial updating of virtual nodes.  
In the case of applying the simplest operations (such as insert or remove) on the tree, only part of the DOM tree is updated.  
This causes the DOM tree to update very quickly.  
This is true when unique keys are used to identify virtual nodes of the same type.  
The use of non-unique keys is not allowed and will result in an exception.  
Keys need to be unique only at the same level (that is, at the parent node level).  
Simultaneous use of virtual nodes with and without keys is allowed.  

## What is the purpose of virtual DOM?

Using the virtual DOM, can be developed fast client-side browser applications such as admin panels, e-commerce applications, chat rooms and the like.  
Virtual DOM nodes are almost equivalent to DOM nodes.  
Those developers who are familiar with HTML and CSS can easily use virtual nodes.  
But since the use of only virtual nodes is not a sufficiently functional solution, virtual components are provided for full-fledged work.  
Virtual components are, in fact, the same elements of the virtual tree as virtual nodes, but they have significant differences.  
Virtual components do not have equivalent to DOM nodes.  
They should produce content (as a result of rendering) that consists of virtual nodes and/or virtual components.  
To be more precise, there are two kinds of components - virtual components and application components.  
A virtual component wraps an application component.  
Component usage is the usage of application components.  

## About the difference between virtual node keys and component keys

Virtual node keys must be unique within the parent.  
The main (and most logical) purpose of these keys is to index the elements of collections (similar to database primary keys).  
This is required in order to provide a quick computation of the presence of changes in the tree (performing only the key comparison operation).  

Why is this needed?  
There are two types of resource-intensive computations for the DOM tree changes.  
The first and most resource-intensive computation is the content painting performed by the browser.  
What is the meaning of these words?  
The point is that if some node of the DOM tree is moved to another place in the tree, then, despite the fact that this node has not been changed, it may take considerable time to repaint it.  
The virtual tree in this case performs the task of minimizing the removals of nodes from the tree.  
This is achieved by updating (replacing) the state (such as attributes and listeners) of the DOM node to the required state (new attributes and listeners), in case the nodes are physically and logically similar. Of course, this also implies processing (updating) child elements.  
Physical analogy implies an analogy in terms of the DOM, logical mapping implies the logic of the application and the principles of data virtualization (nodes and components).  
This prevents moving (actually removing) nodes from the DOM tree, replacing this operation with modifying (rebuilding) the comparable nodes.  
The operation of rebuilding the nodes is much more time efficient than the operation of the browser repainting the nodes again in a new tree location.  

The second and also quite resource-intensive computation is the rendering of the component content, which is performed by the application component when the `render` method is executed and by the renderer procedures after that.  
The need to perform these operations is minimized by itself in the first case, and at the same time, to minimize such (unreasonable, repeated) renderings, the method of caching the rendered content is used.  
In principle, rendered content caching is one of the essences of virtualization.  
To improve the identification of application components when using cached results (in fact, with multiple reuse of these results), application component keys are provided.  
Component keys are not used to identify the elements of the collection in the tree and therefore may not be unique.  
Component keys are used to determine the identity of components of the same runtime type (and in this context they must be unique).  

Why is this needed?  
This is required in order to determine whether the component state needs to be reset (and, as a result, it must be rendered as a new instance).  

From the point of view of virtualization, any component of the same runtime type looks the same regardless of what arguments are passed to the component when it is created.  
This happens because preprocessing, separate compilation and building are not used - everything is done in runtime.  
But the "outside world" does not have access to the component arguments, and the only possible way to do this is to use component keys for that purpose.  

Example:

```dart
StartFromThisValueWidget(0);
StartFromThisValueWidget(41);
```

With virtualization, it is impossible to distinguish these two components from each other, because each of them is a `black box`.  
Considering that caching is very heavily used during virtualization, if a component of the same runtime type is created with different arguments, then it will be considered an instance of an already existing component and its state will not be destroyed.  
The only way to determine differences is to let the component itself decide this.  
An example when the component itself decides this:

```dart
class StartFromThisValueWidget extends Component {
  int value;

  StartFromThisValueWidget(this.value) : super(key: value);
}
```

Now it will be impossible not to distinguish these components from each other and everything will work correctly and the component will be re-rendered only following its logic of work or if its parameters are changed by the "outside world".  

## Helper functions

Helper function means some global function to simplify the use of this software.  
This is a pseudo concepts and is not a convention.  
Currently there are several helper functions:  
- h
- mount
- styles
- vHtml
- vKey

The `h` function helps to declare virtual elements.  
Using this function is optional and you can write your own similar function (a hundred times better than this one).  
But, in any case, the author of this software considers this function to be at least a little, but useful, and therefore considered it possible to include it in this software.  

Example:

```dart
return h('div', [
  h('div', 'Counter: $count'),
  h('button', 'Click', {
    'click': (Event event) {
      setCount(count + 1);
    }
  }),
]);
```

The `mount` function helps to mount virtual components to browser DOM elements.  
It is usually used at the beginning of the program start.  

Example:

```dart
final app = document.getElementById('app')!;
mount(app, App());
```

The `styles` function helps to create HTML `style` attribute.

Example:

```dart
final style = styles({
  'background-color': 'black',
  'color': 'red',
  'display': 'block',
  'margin': '8px',
  'padding': '8px',
});
return h(
  'div',
  {'style': style},
  h('div', [for (final line in lines) h('div', line)]),
);
```

The `vHtml` function helps to create `VHtml` node.  
In fact, it only calls the constructor, but it plays an important role - it hides implementation details. Since it is not recommended to use virtual nodes directly in the `Component.render()` method.

Example:

```dart
Object render() {
  final style = styles({
   'color': color,
  });
  return h('div', {
    'style': style
  }, [
    vHtml('style', _style),
    h('div', {
      'class': 'spinner'
    }, [
      h('div', {'class': 'bounce1'}),
      h('div', {'class': 'bounce2'}),
      h('div', {'class': 'bounce3'}),
    ]),
   ])
    ..useShadowRoot();
}
```

The `vKey` function helps to add a key (most often a collection element key) to a virtual node.  

Example:

```dart
Object render() {
  final changeState = State.change();
  final application = App.get();
  Listener.use(application.windows, changeState);
  final uiFactory = application.uiFactory;
  final list = [];
  final windows = application.windows.value;
  for (final window in windows.values) {
    final windowListItem = uiFactory.createWindowListItem(window);
    final item = h('div', windowListItem);
    list.add(vKey(window.uri, item));
  }
   return h('div', list);
}
```

## Application component

An application component (or, more simply, a component) is a component that represents the part of an application that is responsible for rendering user interface elements.

Example:

```dart
import 'dart:html';

import 'package:virtual_dom/features.dart';
import 'package:virtual_dom/virtual_dom.dart';

void main(List<String> args) {
  final app = document.getElementById('app')!;
  mount(app, Counter());
}

class Counter extends Component {
  @override
  Object render() {
    final count = State.get('count', () => 0);
    final setCount = State.set<int>('count');
    return h('div', [
      h('div', 'Counter: $count'),
      h('button', 'Click', {
        'click': (Event event) {
          setCount(count + 1);
        }
      }),
    ]);
  }
}
```

Warning regarding manual mounting.  
Since this `mount` method is a manual mount, when unmounting (if required) you must explicitly call the `dispose()` method on the component (if required).  
The reason is that the top components do not have a parent. Only the parent calls the `dispose()` method on the child node, or the renderer called by the parent.  
In most cases, this is not required, just close the page tab in the browser.

## Features

The component itself is not very functional, it is only responsible for returning what can be rendered.  
Special classes are intended to give the component some features.  
Again, this is just a pseudo concept, not a convention.  
At the moment there are several classes that implement the features:  
- InheritedProperty
- InheritedValue
- Init
- Listener
- State
- ValueListener
- useErrorReport
- useValueWatcher
- useWatcher

And, of course, nothing prevents from independently implementing other features to expand the functionality.  
If you think that it is difficult, then it is not so - it is very simple (it will be enough to look at the source code of these classes).  

The `InheritedValue` feature allows to define some `Listenable` value (specifying its name and type) in the parent component, which will be available to child elements by its name.  
When the `value` is changed, all components using it will be automatically rendered.  

There is nothing to prevent this feature from being used with values that do not need to be changed to make that value available to other child elements (although for this, perhaps, it would be worth creating another feature).

Example:

```dart
// Parent
final value = InheritedValue.add('value', () => 0);

// Child
final value = InheritedValue.get<int>('value');
```

The `Init` feature allows to define `init` and  `dispose` (`dispose` is optional) handlers that will be executed exactly once, at the right moment.

Example:

```dart
Init.use(() {
  _count++;
  return () {
    _count--;
  };
});
```

The `Listener` feature allows to automatically add and remove a listener to a `ChangeNotifier` with specified action.  
This is a feature, which will do everything itself - add a listener (during initialization) and remove it (when disposing).  

Example:

```dart
final changeState = State.change();
Listener.use(_value, changeState);
```

The `State` feature allows to define a value that will be stored in the component internal context until component is disposed of.  
Also, this feature allows to get a function to change this value.  
Any change to this value will render the component.  
And, of course, the function definition is available to unconditionally render the component.  

```dart
final step = State.get('step', () => 0);
final setStep = State.set<int>('step');
final changeState = State.change();
```

The `ValueListener` feature allows to automatically add and remove a listener to a `ValueNotifier` with specified action.  
This is a feature, which will do everything itself - add a listener (during initialization) and remove it (when disposing).  

Example:

```dart
final val = State.get('val', () => 0);
final setVal = State.set<int>('val');
ValueListener.use(_value, setVal);
```

TODO: Add explanation for other features

## Using Shadow DOM

Using a Shadow DOM is not much more complicated than using a regular DOM.  
In other words, everything is simple.  
Shadow DOM can be used with the `VElement` virtual node.  
In order to indicate the need to use the Shadow DOM, it is enough to configure such a virtual node before using it.  
For these purposes, the `VElement.useShadowRoot()` method is used.  

Example:

```dart
class _Component1 extends Component {
  final String color;

  final String text;

  _Component1(this.text, this.color) : super(key: '$text#$color');

  @override
  Object render() {
    final style = '''
.specialColor {
  color: $color
}''';

    return h('div', [
      vHtml('style', style),
      h('div', {'class': 'specialColor'}, text),
    ])
      ..useShadowRoot();
  }
}
```

The `..useShadowRoot()` in this case will be applied to the returned element (in this case, the topmost `h('div')`) and, as a result, the same element will be returned (and configured to use Shadow Root).  
Configuring an already used node (already placed in the tree) leads to incorrect operation.  
But this does not mean that it is impossible to return a new, any node. All these states are tracked, recognized as different, and everything will work correctly.  

## Render error reporting

When errors occur during rendering, the best way in this situation is to report this error.  
For these purposes, virtual nodes have special procedures that are able to render safely.  
Safely, in this case means using try/catch statements.  
But what to do with the information about these errors?  
There is a special class `ErrorReport` for this purpose.  
The virtual component contains a field `ValueNotifier<ErrorReport?>? errorReport`.  
By default, this field is not initialized, which means that this virtual component does not take responsibility for error reporting.  
But as soon as this value is set (in some component), it will mean that this component takes over the task of displaying error messages.  

It would seem that everything is simple, but not everything is so simple.  
What happens if a rendering error occurs in this component, which itself should display error messages?  
Since this component will no longer be re-rendered, this will result in no error report being displayed.  
In this case, it would be more correct to pass the value `ValueNotifier<ErrorReport?>` to the child component.  
Because the principles of virtualization do not prevent children from "living their own life" (being rendered at least once) they will continue to exist and function even in a "broken" parent.  
And in this case, they will be quite capable of displaying error reports.  

All the parent has to do is initialize the `VComponent.errorReport` field and render the child element to which this value will be passed.  
The child element (component) should track changes to this value (watch) and output the changes (error reports).  

Example can be found here: https://github.com/mezoni/virtual_dom/blob/master/example/example.dart

This is not the only possible way to accomplish this task, but it is a fairly optimal way.  

The nesting of components that take responsibility for displaying error messages can be any, and in case of an error, the closest one will be used.  
The `VNode.findErrorReport()` method is responsible for finding the closest or only component.  
It checks the current component and then iterates through all the parents up to the very top.
