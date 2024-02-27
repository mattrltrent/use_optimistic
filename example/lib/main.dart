import 'package:flutter/material.dart';
import 'package:use_optimistic/use_optimistic.dart'; // Ensure this is linked to your implementation

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: OptimisticUI(),
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
  final UseOptimistic<int> useOptimistic = UseOptimistic<int>(initialState: 0);

  @override
  void initState() {
    super.initState();
    useOptimistic.addListener(() => setState(() => {}));
  }

  @override
  void dispose() {
    useOptimistic.dispose();
    super.dispose();
  }

  Resolver<int> _addValue(int value) {
    return useOptimistic.fn(
      value,
      todo: (currentState, newValue) => currentState + newValue,
      undo: (currentState, oldValue) => currentState - oldValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Current value: ${useOptimistic.state}"),
          const SizedBox(height: 40),
          TextButton(
            onPressed: () async {
              final r = _addValue(1);
              await Future.delayed(const Duration(seconds: 2));
              r.accept();
            },
            child: const Text("add 1 (accept)"),
          ),
          TextButton(
            onPressed: () async {
              final r = _addValue(1);
              await Future.delayed(const Duration(seconds: 2));
              r.reject();
            },
            child: const Text("add 1 (reject)"),
          ),
          TextButton(
            onPressed: () async {
              final r = _addValue(1);
              await Future.delayed(const Duration(seconds: 2));
              r.acceptAs(2);
            },
            child: const Text("add 1 (accept as 2)"),
          ),
          TextButton(
            onPressed: () {
              useOptimistic.state = 10;
            },
            child: const Text("set to 10"),
          ),
          TextButton(
            onPressed: () => useOptimistic.clearQueue(),
            child: const Text("clear queue"),
          ),
          TextButton(
            onPressed: () => useOptimistic.reset(),
            child: const Text("reset"),
          ),
        ],
      ),
    );
  }
}
