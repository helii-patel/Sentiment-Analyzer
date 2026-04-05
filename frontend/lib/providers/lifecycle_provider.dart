import 'package:flutter/material.dart';

class LifecycleProvider extends ChangeNotifier {
  AppLifecycleState _state = AppLifecycleState.resumed;

  AppLifecycleState get state => _state;

  void update(AppLifecycleState state) {
    _state = state;
    notifyListeners();
  }
}
