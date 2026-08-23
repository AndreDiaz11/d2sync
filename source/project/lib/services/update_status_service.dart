import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/update_status.dart';

class UpdateStatusService {
  String get _rutaStatus {
    final appData = Platform.environment['LOCALAPPDATA'] ?? Directory.current.path;
    return p.join(appData, 'D2Sync', 'status.json');
  }

  Future<UpdateStatus?> leer() async {
    final file = File(_rutaStatus);
    if (!file.existsSync()) return null;
    try {
      final text = await file.readAsString();
      final version = _extraerValor(text, 'version');
      if (version == null) return null;
      final lastUpdatedRaw = _extraerValor(text, 'lastUpdatedUtc');
      final updateAvailable = _extraerValor(text, 'updateAvailableVersion');
      return UpdateStatus(
        version: version,
        lastUpdatedUtc: lastUpdatedRaw == null ? null : DateTime.tryParse(lastUpdatedRaw),
        updateAvailableVersion: updateAvailable,
      );
    } catch (_) {
      return null;
    }
  }

  String? _extraerValor(String json, String key) {
    final match = RegExp('"$key"\\s*:\\s*"([^"]*)"').firstMatch(json);
    return match?.group(1);
  }
}
