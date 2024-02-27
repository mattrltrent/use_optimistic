import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// key to store the original value of the state
const String _originalKey = "OG";

/// key to store the updated value of the state
const String _updatedKey = "UP";

/// [Resolver] class to handle the [accept], reject and acceptAs methods
class Resolver<T> {
  /// [reject] is used to reject the optimistic update; it will call the [undo] function to
  /// revert the original [todo] call of the optimistic update
  final void Function() reject;

  /// [accept] is used to accept the optimistic update; you don't TECHNICALLY need to [accept] an optimistic update, but
  /// it's good practice to do so and saves memory
  final void Function() accept;

  /// [acceptAs] is used to update the value of the state to a new value; it may be used if you assume optimistically
  /// a value should be +1 for example, but after the server responds, it really should be +2
  ///
  /// it will revert the state to the original value and then update it to the new value
  final void Function(T newValue) acceptAs;

  Resolver(
      {required this.reject, required this.accept, required this.acceptAs});
}

/// [UseOptimistic] class to handle state and the optimistic updates
class UseOptimistic<T> extends ChangeNotifier {
  /// current state of the state
  T _state;

  /// initial state of the state
  final T initialState;

  /// pending updates to the state
  final Map<String, Map<String, T>> _pendingUpdates = {};

  /// getter for the current state
  T get state => _state;

  /// setter for the current state
  ///
  /// calling this updates the state and notifies the listeners
  set state(T newState) {
    _state = newState;
    notifyListeners();
  }

  /// clear the pending updates queue
  ///
  /// this means that all the pending updates will be removed
  /// such that if you [reject], [accept], or [acceptAs] them, they
  /// will not have any effect on the state
  void clearQueue() => _pendingUpdates.clear();

  /// resets the state to the [initialState] and
  /// notifies the listeners
  void reset() {
    _state = initialState;
    notifyListeners();
  }

  UseOptimistic({required this.initialState}) : _state = initialState;

  /// optimistic update function
  ///
  /// this function takes in the new [value], the [todo] function, and the [undo] function
  ///
  /// the [todo] function is called when the state is updated
  ///
  /// the [undo] function is called when the state is rejected
  ///
  /// returns a [Resolver] object that has the [accept], [reject], and [acceptAs] methods
  Resolver<T> fn(T newValue,
      {required T Function(T currentState, T newValue) todo,
      required T Function(T currentState, T oldValue) undo}) {
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
          _pendingUpdates[id] = {
            _originalKey: updatedValue,
            _updatedKey: updatedValue
          };
          notifyListeners();
        }
      },
    );
  }
}
