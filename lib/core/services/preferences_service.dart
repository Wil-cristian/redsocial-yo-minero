import 'package:flutter/material.dart';

/// Servicio simple de preferencias usando un ValueNotifier global
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  // ValueNotifier para el estado del menú flotante
  final ValueNotifier<bool> floatingMenuEnabled = ValueNotifier<bool>(false);

  /// Toggle del menú flotante
  void toggleFloatingMenu(bool enabled) {
    floatingMenuEnabled.value = enabled;
  }

  /// Obtener estado actual
  bool get isFloatingMenuEnabled => floatingMenuEnabled.value;
}
