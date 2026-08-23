/// Ruta del lanzador (D2Sync_v*.exe) que abrió esta instancia de la app,
/// recibida como argumento de línea de comandos. Null si se ejecutó directo
/// (por ejemplo durante desarrollo con `flutter run`).
class LaunchArgs {
  static String? launcherPath;

  static void parse(List<String> args) {
    for (final arg in args) {
      if (arg.startsWith('--launcher=')) {
        var value = arg.substring('--launcher='.length);
        if (value.startsWith('"') && value.endsWith('"') && value.length >= 2) {
          value = value.substring(1, value.length - 1);
        }
        launcherPath = value;
      }
    }
  }
}
