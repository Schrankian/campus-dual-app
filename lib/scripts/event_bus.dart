//bus, which can be called to evoke methods through the whole project
typedef EventCallBack = void Function(dynamic args);

final EventBus mainBus = EventBus();

class EventBus {
  EventBus._internal();
  static final EventBus _bus = EventBus._internal();
  factory EventBus() => _bus;

  final _eventMap = <String, List<EventCallBack>>{};

  void onBus({required String event, required EventCallBack onEvent}) {
    _eventMap[event] ??= <EventCallBack>[];
    _eventMap[event]!.add(onEvent);
  }

  void offBus({required String event, EventCallBack? callBack}) {
    if (callBack == null) {
      _eventMap.remove(event);
    } else {
      _eventMap[event]?.remove(callBack);
    }
  }

  void emit({required String event, dynamic args}) {
    if (_eventMap[event] != null) {
      for (int i = _eventMap[event]!.length - 1; i >= 0; i--) {
        _eventMap[event]![i](args);
      }
    }
  }
}
