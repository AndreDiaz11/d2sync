import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'core/launch_args.dart';
import 'i18n/app_language.dart';
import 'screens/app_shell.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  LaunchArgs.parse(args);
  await languageController.cargar();
  await windowManager.ensureInitialized();
  const options = WindowOptions(
    size: Size(860, 780),
    minimumSize: Size(720, 680),
    center: true,
    title: 'D2Sync by Nexo',
    titleBarStyle: TitleBarStyle.hidden,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const D2SyncApp());
}

class D2SyncApp extends StatelessWidget {
  const D2SyncApp({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: languageController,
    builder: (context, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'D2Sync by Nexo',
      theme: ThemeData.dark(useMaterial3: true),
      home: AppShell(),
    ),
  );
}
