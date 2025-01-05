library repo_notifier;

import 'dart:async';
import 'package:flutter/material.dart';

export 'package:flutter/foundation.dart' show ChangeNotifier;

/// Represents the possible states of data in a repository.
sealed class DataState<T> {}

/// Represents a null state where no data is present.
class DataNull<T> extends DataState<T> {}

/// Represents a loading state while data is being fetched or processed.
class DataLoading<T> extends DataState<T> {}

/// Represents a state where data has been successfully loaded.
class DataLoaded<T> extends DataState<T> {
  /// The loaded data.
  final T data;

  /// Creates a new [DataLoaded] state with the given data.
  DataLoaded(this.data);
}

/// Represents an error state when data operations fail.
class DataError<T> extends DataState<T> {
  /// The error that occurred.
  final Object error;

  /// The stack trace associated with the error.
  final StackTrace? stackTrace;

  /// Creates a new [DataError] state with the given error and stack trace.
  DataError(this.error, this.stackTrace);
}

/// A base class for implementing repository pattern with built-in state management.
///
/// [T] is the type of data being managed.
/// [ID] is the type of the identifier used for the data.
abstract class RepoNotifier<T, ID> extends ChangeNotifier {
  DataState<T> _prev = DataNull<T>();
  DataState<T> _state = DataNull<T>();

  /// Gets the current state of the repository.
  DataState<T> get currentState {
    return _state;
  }

  /// Pattern matches on the current state to handle different cases.
  ///
  /// This method provides a type-safe way to handle different states of the repository.
  R match<R>({
    required R Function(T data) onData,
    R Function()? onWaiting,
    R Function(Object error, StackTrace? stackTrace)? onError,
    required R Function() onNull,
  }) {
    final currentSubscriber = SubscriberState._currentState;
    if (currentSubscriber != null) {
      currentSubscriber.addNotifier(this);
    }
    return switch (_state) {
      DataLoading() => onWaiting != null
          ? onWaiting()
          : _prev is DataLoaded<T>
              ? onData(((_prev as DataLoaded<T>).data))
              : onNull(),
      DataError(:final error, :final stackTrace) => onError != null
          ? onError(error, stackTrace)
          : _prev is DataLoaded<T>
              ? onData((_prev as DataLoaded<T>).data)
              : onNull(),
      DataLoaded<T>() => onData((_state as DataLoaded<T>).data),
      DataNull<T>() => onNull()
    };
  }

  /// Creates a new data entry in the repository.
  Future<void> create(T data) async {
    try {
      _prev = _state;
      _state = DataLoading();
      notifyListeners();
      await onCreate(data);
      _state = DataLoaded(data);
    } catch (e, s) {
      _state = DataError(e, s);
    } finally {
      notifyListeners();
    }
  }

  /// Reads data from the repository.
  Future<DataState<T>> read([ID? id, bool notify = true]) async {
    try {
      _prev = _state;
      _state = DataLoading();
      notifyListeners();
      final result = await onRead(id);
      _state = DataLoaded(result);
      if (notify) notifyListeners();
      return _state;
    } catch (e, s) {
      _state = DataError(e, s);
      if (notify) notifyListeners();
      return DataError(e, s);
    }
  }

  /// Updates existing data in the repository.
  Future<void> update(T data) async {
    try {
      _prev = _state;
      _state = DataLoading();
      notifyListeners();
      await onUpdate(data);
      _state = DataLoaded(data);
    } catch (e, s) {
      _state = DataError(e, s);
    } finally {
      notifyListeners();
    }
  }

  /// Deletes data from the repository.
  Future<void> delete([ID? id]) async {
    try {
      _prev = _state;
      _state = DataLoading();
      notifyListeners();
      await onDelete(id);
      _state = DataNull();
    } catch (e, s) {
      _state = DataError(e, s);
    } finally {
      notifyListeners();
    }
  }

  /// Implement this method to handle data creation.
  @protected
  Future<void> onCreate(T data);

  /// Implement this method to handle data reading.
  @protected
  Future<T> onRead([ID? id]);

  /// Implement this method to handle data updates.
  @protected
  Future<void> onUpdate(T data);

  /// Implement this method to handle data deletion.
  @protected
  Future<void> onDelete([ID? id]);
}

/// A widget that subscribes to repository changes and rebuilds its children.
class Subscriber extends StatefulWidget {
  /// Creates a new [Subscriber] widget.
  const Subscriber(this.builder, {super.key});

  /// The builder function that creates the widget tree.
  final Widget Function(BuildContext context) builder;

  @override
  State<Subscriber> createState() => SubscriberState();
}

/// The state for the [Subscriber] widget.
class SubscriberState extends State<Subscriber> {
  static SubscriberState? _currentState;
  final Set<ChangeNotifier> _notifiers = {};

  /// Adds a notifier to the subscription list.
  void addNotifier(ChangeNotifier notifier) {
    if (_notifiers.add(notifier)) {
      notifier.addListener(_update);
    }
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (var notifier in _notifiers) {
      notifier.removeListener(_update);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previousSubscriber = _currentState;
    _currentState = this;
    final result = widget.builder(context);
    _currentState = previousSubscriber;
    return result;
  }
}
