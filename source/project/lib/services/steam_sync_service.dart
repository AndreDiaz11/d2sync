import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/cuenta_steam.dart';

/// Reconstrucción funcional basada en nombres, cadenas y rutas conservadas en
/// el AOT original. Véase ../../reverse_engineering/RECOVERY_REPORT.md.
class SteamSyncService {
  static const String dotaAppId = '570';
  static const String _steamRegistryKey = r'HKCU\Software\Valve\Steam';
  static const int _steamId64Base = 76561197960265728;

  String? _steamPath;

  Future<String> obtenerRutaSteam() async {
    if (_steamPath != null) return _steamPath!;
    final result = await Process.run('reg.exe', [
      'query',
      _steamRegistryKey,
      '/v',
      'SteamPath',
    ], runInShell: false);
    if (result.exitCode != 0) {
      throw StateError('No se encontró la instalación de Steam.');
    }
    final match = RegExp(
      r'SteamPath\s+REG_\w+\s+(.+)',
      caseSensitive: false,
    ).firstMatch(result.stdout.toString());
    if (match == null) {
      throw StateError('No se pudo leer SteamPath del registro de Windows.');
    }
    _steamPath = p.normalize(match.group(1)!.trim());
    return _steamPath!;
  }

  Future<List<CuentaSteam>> cargarCuentas() async {
    final steam = await obtenerRutaSteam();
    final userdata = Directory(p.join(steam, 'userdata'));
    if (!userdata.existsSync()) {
      throw StateError('No se encontró la carpeta userdata de Steam.');
    }

    final hidden = await _leerCuentasOcultas();
    final loginNames = await _obtenerMapeoCuentas();
    final accounts = <CuentaSteam>[];
    for (final entity in userdata.listSync(followLinks: false)) {
      if (entity is! Directory) continue;
      final id = p.basename(entity.path);
      if (!RegExp(r'^\d+$').hasMatch(id) || hidden.contains(id)) continue;
      final localName = _obtenerNombreLocalConfig(entity.path);
      final id64 = (int.parse(id) + _steamId64Base).toString();
      final name = localName ?? loginNames[id64] ?? id;
      accounts.add(
        CuentaSteam(
          steamId: id,
          nombre: name,
          rutaCuenta: entity.path,
          rutaConfigCuenta: p.join(entity.path, dotaAppId),
          rutaSteamCloudCuenta: p.join(
            entity.path,
            '7',
            'remote',
            'sharedconfig.vdf',
          ),
        ),
      );
    }
    accounts.sort(
      (a, b) => a.nombreVisible.toLowerCase().compareTo(
        b.nombreVisible.toLowerCase(),
      ),
    );
    return accounts;
  }

  Future<void> ejecutarSincronizacion(
    CuentaSteam origen,
    CuentaSteam destino,
  ) async {
    if (origen.steamId == destino.steamId) {
      throw ArgumentError(
        'La cuenta de origen y destino no pueden ser la misma.',
      );
    }
    final source = Directory(origen.rutaConfigCuenta);
    if (!source.existsSync()) {
      throw StateError('No existe la carpeta 570 de origen.');
    }
    await _validarRutaDentroDeUserData(destino.rutaConfigCuenta);

    final target = Directory(destino.rutaConfigCuenta);
    final restore = Directory(
      '${destino.rutaConfigCuenta}_restore_${DateTime.now().millisecondsSinceEpoch}',
    );
    try {
      if (target.existsSync()) {
        await _copiarDirectorio(target, restore);
        await target.delete(recursive: true);
      }
      await _copiarDirectorio(source, target);
      if (restore.existsSync()) await restore.delete(recursive: true);
    } catch (error) {
      if (target.existsSync()) await target.delete(recursive: true);
      if (restore.existsSync()) await _copiarDirectorio(restore, target);
      throw StateError(
        'La copia falló y se restauró la configuración anterior: $error',
      );
    } finally {
      if (restore.existsSync()) await restore.delete(recursive: true);
    }
  }

  Future<String> guardarBackupCuenta(
    CuentaSteam cuenta,
    String carpetaDestino,
  ) async {
    final source = Directory(cuenta.rutaConfigCuenta);
    if (!source.existsSync()) {
      throw StateError('La cuenta seleccionada no tiene carpeta 570.');
    }
    final base = Directory(carpetaDestino);
    if (!base.existsSync()) {
      throw StateError('La ubicación elegida para el backup no existe.');
    }
    final target = Directory(p.join(base.path, dotaAppId));
    if (target.existsSync() && target.listSync().isNotEmpty) {
      throw StateError('La carpeta 570 de backup ya existe y no está vacía.');
    }
    await _copiarDirectorio(source, target);
    return target.path;
  }

  Future<void> cargarBackupEnCuenta(
    String carpeta570,
    CuentaSteam destino,
  ) async {
    final source = Directory(carpeta570);
    if (p.basename(p.normalize(source.path)) != dotaAppId) {
      throw ArgumentError(
        'La carpeta seleccionada debe llamarse exactamente 570.',
      );
    }
    if (!source.existsSync()) {
      throw StateError('No existe la carpeta 570 de origen.');
    }
    await _validarRutaDentroDeUserData(destino.rutaConfigCuenta);
    final target = Directory(destino.rutaConfigCuenta);
    final restore = Directory(
      '${destino.rutaConfigCuenta}_restore_${DateTime.now().millisecondsSinceEpoch}',
    );
    try {
      if (target.existsSync()) {
        await _copiarDirectorio(target, restore);
        await target.delete(recursive: true);
      }
      await _copiarDirectorio(source, target);
      if (restore.existsSync()) await restore.delete(recursive: true);
    } catch (error) {
      if (target.existsSync()) await target.delete(recursive: true);
      if (restore.existsSync()) await _copiarDirectorio(restore, target);
      throw StateError(
        'La carga del backup falló y se restauró la configuración anterior: $error',
      );
    } finally {
      if (restore.existsSync()) await restore.delete(recursive: true);
    }
  }

  Future<void> eliminarCuenta(
    CuentaSteam cuenta, {
    bool quitarDelLauncher = false,
  }) async {
    await _validarRutaDentroDeUserData(cuenta.rutaCuenta);
    if (quitarDelLauncher) {
      await _validarSteamCerrado();
      await _eliminarCuentaDeLoginUsers(cuenta.steamId);
      await _agregarCuentaOculta(cuenta.steamId);
    }
    final directory = Directory(cuenta.rutaCuenta);
    if (directory.existsSync()) await directory.delete(recursive: true);
  }

  // Retorna true=activado, false=desactivado, null=sin datos (archivo no existe)
  Future<bool?> obtenerSteamCloudDota(CuentaSteam cuenta) async {
    final file = File(cuenta.rutaSteamCloudCuenta);
    if (!file.existsSync()) return null;
    final text = await _leerVdf(file);
    final block = _extraerBloqueApp(text, dotaAppId);
    if (block == null) return null;
    final match = RegExp(
      r'"cloudenabled"\s+"([01])"',
      caseSensitive: false,
    ).firstMatch(block.text);
    if (match == null) return null;
    return match.group(1) == '1';
  }

  Future<void> cambiarSteamCloudDota(CuentaSteam cuenta, bool activar) async {
    await _validarDotaCerrado();
    await _validarSteamCerrado();
    final file = File(cuenta.rutaSteamCloudCuenta);
    if (!file.existsSync()) await _crearSharedConfigCloud(file, activar);

    final originalBytes = await file.readAsBytes();
    var text = await _leerVdf(file);
    final block = _extraerBloqueApp(text, dotaAppId);
    final value = activar ? '1' : '0';
    if (block != null) {
      var replacement = block.text;
      final cloudPattern = RegExp(
        r'"cloudenabled"\s+"[01]"',
        caseSensitive: false,
      );
      replacement = cloudPattern.hasMatch(replacement)
          ? replacement.replaceFirst(cloudPattern, '"cloudenabled"\t\t"$value"')
          : replacement.replaceFirst(
              RegExp(r'}\s*$'),
              '\t"cloudenabled"\t\t"$value"\n}',
            );
      text = text.replaceRange(block.start, block.end, replacement);
    } else {
      // No hay entrada "570" todavía: insertarla dentro de la sección "apps"
      // existente (si la hay) en vez de al final del archivo, para no romper
      // la estructura que Steam espera.
      final appsMatch = RegExp(r'"apps"', caseSensitive: false).firstMatch(text);
      final appsBlock = appsMatch == null ? null : _extractBlockAt(text, appsMatch.start);
      final nuevoBloque = '\t\t"$dotaAppId"\n\t\t{\n\t\t\t"cloudenabled"\t\t"$value"\n\t\t}\n\t';
      if (appsBlock != null) {
        final closeIdx = appsBlock.start + appsBlock.text.lastIndexOf('}');
        text = text.replaceRange(closeIdx, closeIdx, nuevoBloque);
      } else {
        text = '$text\n"$dotaAppId"\n{\n\t"cloudenabled"\t\t"$value"\n}\n';
      }
    }
    await _escribirVdf(file, text, originalBytes);
  }

  // Launch Options de Dota 2 (localconfig.vdf, distinto del sharedconfig del cloud)
  String _rutaLocalConfig(CuentaSteam cuenta) =>
      p.join(cuenta.rutaCuenta, 'config', 'localconfig.vdf');

  Future<String> obtenerLaunchOptionsDota(CuentaSteam cuenta) async {
    final file = File(_rutaLocalConfig(cuenta));
    if (!file.existsSync()) return '';
    final text = await _leerVdf(file);
    final block = _extraerBloqueApp(text, dotaAppId);
    if (block == null) return '';
    final match = RegExp(
      r'"LaunchOptions"\s+"([^"]*)"',
      caseSensitive: false,
    ).firstMatch(block.text);
    return match?.group(1) ?? '';
  }

  // Reescribe el Launch Options completo: quita todas las flags que este programa
  // gestiona (estén o no activas) y vuelve a poner solo las que están en [activas].
  // Cualquier otro texto que el usuario haya puesto a mano se conserva intacto.
  Future<void> aplicarOptimizacionesDota(
    CuentaSteam cuenta,
    List<String> flagsGestionadas,
    Set<String> flagsActivas,
  ) async {
    await _validarSteamCerrado();
    final file = File(_rutaLocalConfig(cuenta));
    if (!file.existsSync()) {
      throw StateError('No se encontró la configuración local de esta cuenta.');
    }
    final originalBytes = await file.readAsBytes();
    var text = await _leerVdf(file);
    final block = _extraerBloqueApp(text, dotaAppId);
    if (block == null) {
      throw StateError('No se encontró Dota 2 en la configuración de Steam de esta cuenta.');
    }

    final match = RegExp(
      r'"LaunchOptions"\s+"([^"]*)"',
      caseSensitive: false,
    ).firstMatch(block.text);

    // Algunas opciones son de dos palabras (ej. "-refresh 60"), así que se
    // quitan como texto completo en vez de palabra por palabra.
    var restante = ' ${match?.group(1) ?? ''} ';
    for (final flag in flagsGestionadas) {
      restante = restante.replaceAll(' $flag ', ' ');
    }
    final conservadas = restante.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    final nuevoValor = [...conservadas, ...flagsActivas].join(' ');

    String replacement;
    if (match != null) {
      replacement = block.text.replaceRange(
        match.start,
        match.end,
        '"LaunchOptions"\t\t"$nuevoValor"',
      );
    } else {
      replacement = block.text.replaceFirst(
        RegExp(r'}\s*$'),
        '\t"LaunchOptions"\t\t"$nuevoValor"\n}',
      );
    }
    text = text.replaceRange(block.start, block.end, replacement);
    await _escribirVdf(file, text, originalBytes);
  }

  Future<bool> estaSteamAbierto() => _estaProcesoAbierto('steam.exe');
  Future<bool> estaDotaAbierto() => _estaProcesoAbierto('dota2.exe');

  Future<bool> _estaProcesoAbierto(String imageName) async {
    final result = await Process.run('tasklist.exe', [
      '/FI',
      'IMAGENAME eq $imageName',
      '/NH',
    ], runInShell: false);
    return result.stdout.toString().toLowerCase().contains(imageName);
  }

  Future<void> _validarSteamCerrado() async {
    if (await estaSteamAbierto()) {
      throw StateError('Cierra Steam completamente antes de continuar.');
    }
  }

  Future<void> _validarDotaCerrado() async {
    if (await estaDotaAbierto()) {
      throw StateError('Cierra Dota 2 completamente antes de continuar.');
    }
  }

  Future<void> _validarRutaDentroDeUserData(String candidate) async {
    final userdata = p.normalize(
      p.absolute(p.join(await obtenerRutaSteam(), 'userdata')),
    );
    final checked = p.normalize(p.absolute(candidate));
    if (!p.isWithin(userdata, checked)) {
      throw StateError('Ruta fuera de userdata bloqueada por seguridad.');
    }
  }

  Future<void> _copiarDirectorio(Directory source, Directory target) async {
    await target.create(recursive: true);
    await for (final entity in source.list(followLinks: false)) {
      final destination = p.join(target.path, p.basename(entity.path));
      if (entity is Directory) {
        await _copiarDirectorio(entity, Directory(destination));
      } else if (entity is File) {
        await entity.copy(destination);
      }
    }
  }

  String? _obtenerNombreLocalConfig(String accountPath) {
    final file = File(p.join(accountPath, 'config', 'localconfig.vdf'));
    if (!file.existsSync()) return null;
    final match = RegExp(
      r'"PersonaName"\s+"([^"]+)"',
      caseSensitive: false,
    ).firstMatch(file.readAsStringSync());
    return match?.group(1);
  }

  Future<Map<String, String>> _obtenerMapeoCuentas() async {
    final file = File(
      p.join(await obtenerRutaSteam(), 'config', 'loginusers.vdf'),
    );
    if (!file.existsSync()) return const {};
    final text = await _leerVdf(file);
    final result = <String, String>{};
    for (final id in RegExp(r'"(7656119\d+)"').allMatches(text)) {
      final block = _extractBlockAt(text, id.start);
      if (block == null) continue;
      final name = RegExp(
        r'"PersonaName"\s+"([^"]+)"',
        caseSensitive: false,
      ).firstMatch(block.text)?.group(1);
      if (name != null) result[id.group(1)!] = name;
    }
    return result;
  }

  Future<void> _eliminarCuentaDeLoginUsers(String accountId) async {
    final file = File(
      p.join(await obtenerRutaSteam(), 'config', 'loginusers.vdf'),
    );
    if (!file.existsSync()) return;
    final originalBytes = await file.readAsBytes();
    var text = await _leerVdf(file);
    final id64 = (int.parse(accountId) + _steamId64Base).toString();
    final match = RegExp('"$id64"').firstMatch(text);
    if (match == null) return;
    final block = _extractBlockAt(text, match.start);
    if (block != null) {
      text = text.replaceRange(block.start, block.end, '');
      await _escribirVdf(file, text, originalBytes);
    }
  }

  String get _rutaCuentasOcultas {
    final appData = Platform.environment['APPDATA'] ?? Directory.current.path;
    return p.join(appData, 'D2Sync', 'd2sync_hidden_accounts.txt');
  }

  Future<Set<String>> _leerCuentasOcultas() async {
    final file = File(_rutaCuentasOcultas);
    if (!file.existsSync()) return <String>{};
    return (await file.readAsLines())
        .map((line) => line.trim())
        .where((line) => RegExp(r'^\d+$').hasMatch(line))
        .toSet();
  }

  Future<void> _agregarCuentaOculta(String id) async {
    final values = await _leerCuentasOcultas()
      ..add(id);
    final file = File(_rutaCuentasOcultas);
    await file.parent.create(recursive: true);
    await file.writeAsString('${values.join('\n')}\n', flush: true);
  }

  Future<void> _crearSharedConfigCloud(File file, bool enabled) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(
      '"UserRoamingConfigStore"\n{\n\t"apps"\n\t{\n'
      '\t\t"$dotaAppId"\n\t\t{\n'
      '\t\t\t"cloudenabled"\t\t"${enabled ? 1 : 0}"\n'
      '\t\t}\n\t}\n}\n',
      flush: true,
    );
  }

  // Lee un archivo VDF intentando UTF-8 primero; si hay error usa Latin-1
  Future<String> _leerVdf(File file) async {
    final bytes = await file.readAsBytes();
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes);
    }
  }

  Future<void> _escribirVdf(File file, String text, List<int> originalBytes) async {
    // Escribe con el mismo encoding que tenía el archivo original
    try {
      utf8.decode(originalBytes);
      await file.writeAsBytes(utf8.encode(text), flush: true);
    } catch (_) {
      await file.writeAsBytes(latin1.encode(text), flush: true);
    }
  }

  // localconfig.vdf y sharedconfig.vdf son archivos grandes con muchas
  // secciones (noticias, amigos, streaming, etc.) donde el appid puede
  // aparecer mencionado en varios lugares. Para no agarrar el "570"
  // equivocado, primero se ubica la sección "apps" y recién ahí se busca
  // el appid dentro de ella.
  _VdfBlock? _extraerBloqueApp(String text, String appId) {
    final appsMatch = RegExp(r'"apps"', caseSensitive: false).firstMatch(text);
    if (appsMatch == null) return null;
    final appsBlock = _extractBlockAt(text, appsMatch.start);
    if (appsBlock == null) return null;

    final appMatch = RegExp('"${RegExp.escape(appId)}"').firstMatch(appsBlock.text);
    if (appMatch == null) return null;
    final relativo = _extractBlockAt(appsBlock.text, appMatch.start);
    if (relativo == null) return null;

    final start = appsBlock.start + relativo.start;
    final end = appsBlock.start + relativo.end;
    return _VdfBlock(start, end, text.substring(start, end));
  }

  _VdfBlock? _extractBlockAt(String text, int keyStart) {
    final open = text.indexOf('{', keyStart);
    if (open < 0) return null;
    var depth = 0;
    for (var index = open; index < text.length; index++) {
      if (text[index] == '{') depth++;
      if (text[index] == '}') {
        depth--;
        if (depth == 0) {
          var start = keyStart;
          while (start > 0 && text[start - 1] != '\n') {
            start--;
          }
          var end = index + 1;
          while (end < text.length &&
              (text[end] == '\r' || text[end] == '\n')) {
            end++;
          }
          return _VdfBlock(start, end, text.substring(start, end));
        }
      }
    }
    return null;
  }
}

class _VdfBlock {
  const _VdfBlock(this.start, this.end, this.text);
  final int start;
  final int end;
  final String text;
}
