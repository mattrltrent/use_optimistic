import 'package:flutter/material.dart';
import 'package:use_optimistic/use_optimistic.dart'; // Ensure this is linked to your implementation

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("useOptimistic hook int example 🔥"),
        ),
        body: const OptimisticUI(),
      ),
    );
  }
}

class OptimisticUI extends StatefulWidget {
  const OptimisticUI({super.key});

  @override
  OptimisticUIState createState() => OptimisticUIState();
}

class OptimisticUIState extends State<OptimisticUI> {
  // create a new instance of the hook, setting its initial state to 0 and defining it be of type int
  final UseOptimistic<int> useOptimistic = UseOptimistic<int>(initialState: 0);

  @override
  void initState() {
    super.initState();
    // listen to the changes in the state and update the UI
    // triggers for both the original optimistic updates and resolving the resolver with resolver.[someMethod]
    // also triggered by [clearQueue] and [reset] once
    //
    // THIS IS IMPORTANT, YOUR UI WILL NOT UPDATE REACTIVELY TO STATE CHANGE UNLESS YOU CALL THIS!!!!!
    useOptimistic.addListener(() => setState(() => debugPrint("state changed to: ${useOptimistic.state}")));
  }

  @override
  void dispose() {
    // remove the listener to avoid memory leaks upon the disposal of the widget
    useOptimistic.dispose();
    super.dispose();
  }

  // create a new resolver to handle the optimistic update for some integer values
  Resolver<int> _addValue(int newValToFunctions) {
    return useOptimistic.fn(
      newValToFunctions, // the value to be fed to functions below
      todo: (currentState, newValue) =>
          currentState + newValue, // the optimistic update that uses the [value] above as the [newValue]
      undo: (currentState, oldValue) =>
          currentState - oldValue, // the undo function that uses the [value] above as the [oldValue]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("current value: ${useOptimistic.state}"),
          const SizedBox(height: 40),
          // buttons to test the optimistic updates
          TextButton(
            onPressed: () async {
              final r = _addValue(1);
              await Future.delayed(const Duration(seconds: 1)); // simulate a server response
              // example: assume the server responds with an error, so we want to reject the optimistic update
              r.accept();
              // note: calling r.[someMethod] N times has no effect; it only considers the first call
              r.reject();
            },
            child: const Text("optimistically add 1 (async accept)"),
          ),
          // use a new .fn directly to handle the optimistic update for some new function todo and undo
          TextButton(
            onPressed: () async {
              final r = useOptimistic.fn(
                5, // the value to be fed to functions below
                todo: (currentState, newValue) => currentState ~/ newValue, // the optimistic update
                undo: (currentState, oldValue) =>
                    currentState *
                    oldValue, // the undo function (as shown, can technically not match the exact opposite of [todo])
              );
              await Future.delayed(const Duration(seconds: 1)); // simulate a server response
              r.reject();
            },
            child: const Text("optimistically feed 5 into custom func (async reject)"),
          ),
          TextButton(
            onPressed: () {
              useOptimistic
                  .fn(
                    1,
                    todo: (currentState, newValue) => currentState + newValue,
                    undo: (currentState, oldValue) => currentState - oldValue,
                  )
                  .accept(); // again, this triggers the state lister TWICE -> once for the original optimistic update and once for the resolver
            },
            child: const Text("optimistically add 1 (sync accept)"),
          ),
          TextButton(
            onPressed: () async {
              final r = _addValue(1);
              await Future.delayed(const Duration(seconds: 5)); // simulate a server response
              // example: assume the server responds with an error, so we want to reject the optimistic update
              r.reject();
            },
            child: const Text("optimistically add 1 (async reject)"),
          ),
          TextButton(
            onPressed: () async {
              final r = _addValue(1);
              await Future.delayed(const Duration(seconds: 1)); // simulate a server response
              // example: assume the server responds with 2, so we want to change our initial +1 to +2
              r.acceptAs(2);
            },
            child: const Text("optimistically add 1 (async accept as 2)"),
          ),
          TextButton(
            onPressed: () {
              // example: set the state to 10
              useOptimistic.state = 10;
            },
            child: const Text("set to 10"),
          ),
          TextButton(
            // clear the pending updates queue
            onPressed: () => useOptimistic.clearQueue(),
            child: const Text("clear queue"),
          ),
          TextButton(
            // reset the state to the initial state
            onPressed: () => useOptimistic.reset(),
            child: const Text("reset"),
          ),
        ],
      ),
    );
  }
}
