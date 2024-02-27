import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

const String _originalKey = "OG";
const String _updatedKey = "UP";

class Resolver<T> {
  final void Function() reject;
  final void Function() accept;
  final void Function(T newValue) acceptAs;

  Resolver({required this.reject, required this.accept, required this.acceptAs});
}

class UseOptimistic<T> extends ChangeNotifier {
  T _state;
  final T initialState;
  final Map<String, Map<String, T>> _pendingUpdates = {};

  T get state => _state;

  set state(T newState) {
    _state = newState;
    notifyListeners();
  }

  void clearQueue() => _pendingUpdates.clear();

  void reset() {
    _state = initialState;
    notifyListeners();
  }

  UseOptimistic({required this.initialState}) : _state = initialState;

  Resolver<T> fn(T newValue,
      {required T Function(T currentState, T newValue) todo, required T Function(T currentState, T oldValue) undo}) {
    final String id = const Uuid().v4();
    _pendingUpdates[id] = {_originalKey: newValue, _updatedKey: newValue};

    _state = todo(_state, newValue);
    notifyListeners();

    return Resolver(
      reject: () {
        if (_pendingUpdates.containsKey(id)) {
          var originalValue = _pendingUpdates[id]?[_originalKey];
          if (originalValue != null) {
            _state = undo(_state, originalValue);
          }
          _pendingUpdates.remove(id);
          notifyListeners();
        }
      },
      accept: () {
        _pendingUpdates.remove(id);
        notifyListeners();
      },
      acceptAs: (T updatedValue) {
        if (_pendingUpdates.containsKey(id)) {
          var originalValue = _pendingUpdates[id]?[_originalKey];
          if (originalValue != null) {
            _state = undo(_state, originalValue);
          }
          _state = todo(_state, updatedValue);
          _pendingUpdates[id] = {_originalKey: updatedValue, _updatedKey: updatedValue};
          notifyListeners();
        }
      },
    );
  }
}
