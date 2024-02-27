# Flutter hook: `useOptimistic` 🪝

An easy-to-use hook to optimistically update generic state and then resolve it later (async or sync) by `accept`, `acceptAs`, or `reject`-ing.

----

### Documentation

- [Full example](https://pub.dev/packages/use_optimistic/example) of using this hook to manage integer state.
- GitHub repo found [here](https://github.com/mattrltrent/use_optimistic).
- Package found [here](https://pub.dev/packages/use_optimistic).

Documentation is largely found in the package itself via doc-comments (*i.e. hover over package functions in your editor and it'll tell you what they do*). First, however, view the above [full example](https://pub.dev/packages/use_optimistic/example) to get started.

### Simple usage

<p align="center">
  <img src="https://github.com/mattrltrent/use_optimistic/blob/main/assets/demo.png?raw=true" style="height: 600px;" alt="demo image" />
</p>

**Initialize the hook:**

```dart
  final UseOptimistic<int> useOptimistic = UseOptimistic<int>(initialState: 0)
```

**Ensure your widget listens to its state changes:**

```dart
@override
void initState() {
  super.initState();
  useOptimistic.addListener(() => setState(() => debugPrint("state changed to: ${useOptimistic.state}")));
}
```

**Ensure the hook will be disposed when your widget is:**

```dart
@override
void dispose() {
  super.dispose();
  useOptimistic.dispose();
}
```

**Update your state optimistically:**

```dart
TextButton(
  onPressed: () async {

    Resolver r = useOptimistic.fn(
      1, // the [newValue] to be passed to functions below
      todo: (currentState, newValue) => currentState + newValue,
      undo: (currentState, oldValue) => currentState - oldValue,
    );

    // simulating an API call
    await Future.delayed(const Duration(seconds: 1));

    // three mutually exclusive ways to deal with result
    r.acceptAs(2); // [undo] original function, then [todo] with new value
    r.accept(); // accept the original optimistic update
    r.reject(); // reject the original optimistic update and [undo] original function

  },
  child: const Text("optimistically add 1"),
),
```

You can call `useOptimistic.fn( ... )` multiple times with different `todo` and `undo` functions and it'll execute the proper `todo`/`undo` associated with `fn` at the moment you called it. This means you can call multiple *separate* `useOptimistic.fn( ... )`s safely together. It does *not mean* you can have a single `fn` like this (pseudo-code): `useOptimistic.fn( if x todo: () => {...} else todo: () => {...} )` that has conditionally rendered `todo`/`undo` functions.

**Listen to the state:**

```dart
Text("current value: ${useOptimistic.state}"),
```

### Extra

- The package is always open to [improvements](https://github.com/mattrltrent/use_optimistic/issues), [suggestions](mailto:me@matthewtrent.me), and [additions](https://github.com/mattrltrent/use_optimistic/pulls)!
- I'll look through GitHub PRs and Issues as soon as I can.

![analytics](https://hidden-coast-90561-45544df95b1b.herokuapp.com/api/v1/analytics/?kind=package-use-optimistic)