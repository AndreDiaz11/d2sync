import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

enum AppLanguage { es, en }

class LanguageController extends ChangeNotifier {
  AppLanguage _current = AppLanguage.es;
  AppLanguage get current => _current;
  bool get isEn => _current == AppLanguage.en;

  String get _rutaArchivo {
    final appData = Platform.environment['LOCALAPPDATA'] ?? Directory.current.path;
    return p.join(appData, 'D2Sync', 'language.txt');
  }

  Future<void> cargar() async {
    try {
      final file = File(_rutaArchivo);
      if (!file.existsSync()) return;
      final texto = (await file.readAsString()).trim();
      if (texto == 'en') {
        _current = AppLanguage.en;
        notifyListeners();
      }
    } catch (_) {
      // Sin preferencia guardada: se queda en español por defecto.
    }
  }

  Future<void> alternar() async {
    await elegir(_current == AppLanguage.es ? AppLanguage.en : AppLanguage.es);
  }

  Future<void> elegir(AppLanguage idioma) async {
    if (_current == idioma) return;
    _current = idioma;
    notifyListeners();
    try {
      final file = File(_rutaArchivo);
      await file.parent.create(recursive: true);
      await file.writeAsString(_current == AppLanguage.en ? 'en' : 'es');
    } catch (_) {
      // Preferencia no persistida: no es crítico, solo dura la sesión actual.
    }
  }
}

final languageController = LanguageController();
