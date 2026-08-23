/// Modelo reconstruido a partir de los símbolos conservados en app.so.
class CuentaSteam {
  const CuentaSteam({
    required this.steamId,
    required this.nombre,
    required this.rutaCuenta,
    required this.rutaConfigCuenta,
    required this.rutaSteamCloudCuenta,
  });

  final String steamId;
  final String nombre;
  final String rutaCuenta;
  final String rutaConfigCuenta;
  final String rutaSteamCloudCuenta;

  String get nombreVisible =>
      nombre == steamId ? steamId : '$steamId - $nombre';

  @override
  String toString() => nombreVisible;
}
