library foundation;

typedef VoidCallback = void Function();
typedef ValueChanged<T> = void Function(T value);

abstract class Listenable {
  const Listenable();
  void addListener(VoidCallback listener);
  void removeListener(VoidCallback listener);
}

abstract class ValueListenable<T> extends Listenable {
  const ValueListenable();
  T get value;
}

class ChangeNotifier implements Listenable {
  final List<VoidCallback> _listeners = [];
  bool _disposed = false;

  bool get hasListeners => _listeners.isNotEmpty;

  @override
  void addListener(VoidCallback listener) {
    if (_disposed) return;
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    if (_disposed) return;
    final List<VoidCallback> local = List.of(_listeners);
    for (final listener in local) {
      listener();
    }
  }

  void dispose() {
    _disposed = true;
    _listeners.clear();
  }
}

class ValueNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  ValueNotifier(this._value);
  T _value;

  @override
  T get value => _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }
}

class Key {
  final String value;
  const Key(this.value);
  @override
  bool operator ==(Object other) => other is Key && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => "[#$value]";
}
