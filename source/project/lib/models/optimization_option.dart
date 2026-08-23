import '../i18n/app_language.dart';

class OptimizationOption {
  const OptimizationOption({
    required this.id,
    required this.title,
    required this.descriptionEs,
    required this.descriptionEn,
    required this.flag,
  });

  final String id;
  final String title; // Es el flag literal de Steam, no se traduce.
  final String descriptionEs;
  final String descriptionEn;
  final String flag;

  String get description => languageController.isEn ? descriptionEn : descriptionEs;
}

const List<OptimizationOption> kOptimizationOptions = [
  OptimizationOption(
    id: 'novid',
    title: '-novid',
    descriptionEs: 'Se salta el video de introducción al abrir el juego, para que cargue más rápido.',
    descriptionEn: 'Skips the intro video when opening the game, so it loads faster.',
    flag: '-novid',
  ),
  OptimizationOption(
    id: 'high',
    title: '-high',
    descriptionEs: 'Le pide a Windows que le dé más prioridad de procesador a Dota 2, mejorando el rendimiento general.',
    descriptionEn: 'Asks Windows to give Dota 2 higher processor priority, improving overall performance.',
    flag: '-high',
  ),
  OptimizationOption(
    id: 'nojoy',
    title: '-nojoy',
    descriptionEs: 'Desactiva el soporte de mando/joystick, liberando recursos que no necesitas si juegas con teclado y mouse.',
    descriptionEn: 'Disables gamepad/joystick support, freeing up resources you don\'t need if you play with keyboard and mouse.',
    flag: '-nojoy',
  ),
  OptimizationOption(
    id: 'console',
    title: '-console',
    descriptionEs: 'Activa la consola de desarrollador dentro del juego, útil para ver mensajes técnicos.',
    descriptionEn: 'Enables the developer console inside the game, useful for seeing technical messages.',
    flag: '-console',
  ),
  OptimizationOption(
    id: 'refresh',
    title: '-refresh 60',
    descriptionEs: 'Fuerza que el juego corra a 60Hz de refresco, evitando problemas de sincronización en monitores de 60Hz.',
    descriptionEn: 'Forces the game to run at 60Hz refresh rate, avoiding sync issues on 60Hz monitors.',
    flag: '-refresh 60',
  ),
  OptimizationOption(
    id: 'fps_max',
    title: '+fps_max 0',
    descriptionEs: 'Quita el límite de FPS (cuadros por segundo) en partida, dejando que el juego corra tan rápido como tu PC pueda.',
    descriptionEn: 'Removes the FPS (frames per second) cap in-match, letting the game run as fast as your PC can.',
    flag: '+fps_max 0',
  ),
  OptimizationOption(
    id: 'fps_max_ui',
    title: '+fps_max_ui 35',
    descriptionEs: 'Limita los FPS a 35 mientras estás en los menús (fuera de partida), para que la PC no se esfuerce de más ahí.',
    descriptionEn: 'Caps FPS at 35 while in menus (outside of matches), so your PC doesn\'t work harder than it needs to there.',
    flag: '+fps_max_ui 35',
  ),
  OptimizationOption(
    id: 'gamestateintegration',
    title: '-gamestateintegration',
    descriptionEs: 'Activa la integración de estado del juego, usada por overlays o herramientas externas que muestran información en vivo de la partida.',
    descriptionEn: 'Enables Game State Integration, used by overlays or external tools that show live match information.',
    flag: '-gamestateintegration',
  ),
];
