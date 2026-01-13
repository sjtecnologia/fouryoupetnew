// models/page_manager.dart
import 'package:flutter/material.dart';

class PageManager extends ChangeNotifier {
  static PageManager? _instance;
  static PageManager get instance {
    _instance ??= PageManager._internal();
    return _instance!;
  }

  PageManager._internal();

  // Removido o PageController - agora apenas gerencia o state
  // O controle do PageView é feito localmente na BaseScreen

  int _page = 0;
  int get page => _page;

  void setPage(int value) {
    if (value < 0) return;
    if (_page != value) {
      _page = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Método para resetar o manager (útil para testes ou reinicializações)
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }
}
