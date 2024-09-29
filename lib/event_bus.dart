// Copyright NgocKhanh 2024

import 'dart:async';
import 'package:flutter/foundation.dart';

abstract class BaseEvent<T> {
  final T? data;

  const BaseEvent([this.data]);
}

class EventBus {
  static final EventBus _instance = EventBus._();

  final Map<Type, StreamController> _streamControllerMap;

  EventBus._() : _streamControllerMap = <Type, StreamController>{};

  /// Consumer must close the sunscription after used
  @visibleForTesting
  StreamSubscription<T> registerEvent<T extends BaseEvent>(
    ValueChanged<T> onData, {
    bool sync = false,
  }) {
    if (!_streamControllerMap.containsKey(T)) {
      debugPrint('Register event type $T');
      // ignore: close_sinks
      final sc = StreamController<T>.broadcast(sync: sync);
      _streamControllerMap[T] = sc;
    }

    final stream = _streamControllerMap[T]!.stream.cast<T>();

    return stream.listen(onData);
  }

  static StreamSubscription<T> listen<T extends BaseEvent>(
    ValueChanged<T> onData, {
    bool sync = false,
  }) =>
      _instance.registerEvent(onData, sync: sync);

  static void emit<T extends BaseEvent>(T event) {
    final type = event.runtimeType;
    _instance._streamControllerMap[type]?.add(event);
  }

  static void dispose() {
    for (final controller in _instance._streamControllerMap.values) {
      controller.close();
    }

    _instance._streamControllerMap.clear();
  }
}
