import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../core/launch_args.dart';
import '../i18n/strings.dart';
import '../models/app_section.dart';
import '../models/cuenta_steam.dart';
import '../models/update_status.dart';
import '../services/steam_sync_service.dart';
import '../services/update_status_service.dart';
import '../theme/palette.dart';
import '../widgets/common.dart';
import 'home_screen.dart';
import 'option_screen.dart';
import 'sections/backup_section.dart';
import 'sections/cloud_section.dart';
import 'sections/delete_section.dart';
import 'sections/optimized_section.dart';
import 'sections/sync_section.dart';
import 'splash_screen.dart';

const String _appVersion = '1.2.9';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _service = SteamSyncService();
  final _updateStatusService = UpdateStatusService();

  bool _showSplash = true;
  AppSection? _section;

  List<CuentaSteam> _cuentas = const [];
  bool _busy = false;
  bool _cooldown = false;
  String _estado = S.searchingAccounts;

  UpdateStatus? _updateStatus;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showSplash = false);
    });
    _cargar();
    _leerEstadoActualizacion();
  }

  Future<void> _leerEstadoActualizacion() async {
    final status = await _updateStatusService.leer();
    if (mounted && status != null) setState(() => _updateStatus = status);
  }

  Future<void> _cargar() async {
    setState(() {
      _busy = true;
      _estado = S.searchingAccounts;
    });
    try {
      final values = await _service.cargarCuentas();
      if (!mounted) return;
      setState(() {
        _cuentas = values;
        _estado = values.isEmpty ? S.noAccountsFound : S.accountsFound(values.length);
      });
    } catch (error) {
      if (!mounted) return;
      final msg = '$error'.replaceFirst(RegExp(r'^[A-Za-z]+Error:\s*'), '');
      setState(() => _estado = S.couldNotDetectAccounts(msg));
    } finally {
      if (mounted) setState(() => _busy = false);
      _iniciarCooldown();
    }
  }

  void _iniciarCooldown() {
    if (!mounted) return;
    setState(() => _cooldown = true);
    Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _cooldown = false);
    });
  }

  Future<void> _solicitarActualizacion() async {
    final status = _updateStatus;
    if (status == null || status.updateAvailableVersion == null) return;
    final ok = await confirmar(
      context,
      S.updateAppTitle,
      S.updateAppMessage(status.updateAvailableVersion!),
    );
    if (!ok) return;
    final launcherPath = LaunchArgs.launcherPath;
    if (launcherPath == null || !File(launcherPath).existsSync()) {
      if (!mounted) return;
      setState(() => _estado = S.installerNotFound);
      return;
    }
    await Process.start(launcherPath, ['--auto-update'], mode: ProcessStartMode.detached);
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: gradBg),
        child: Column(
          children: [
            _dragStrip(),
            Expanded(
              child: _section == null
                  ? HomeScreen(
                      onSectionTap: (s) => setState(() => _section = s),
                      busy: _busy,
                      cooldown: _cooldown,
                      estado: _estado,
                      onRefresh: _cargar,
                      version: _appVersion,
                      lastUpdatedUtc: _updateStatus?.lastUpdatedUtc,
                      updateAvailableVersion: _updateStatus?.updateAvailableVersion,
                      onUpdateTap: _solicitarActualizacion,
                    )
                  : OptionScreen(
                      section: _section!,
                      onBack: () => setState(() => _section = null),
                      busy: _busy,
                      cooldown: _cooldown,
                      estado: _estado,
                      onRefresh: _cargar,
                      version: _appVersion,
                      lastUpdatedUtc: _updateStatus?.lastUpdatedUtc,
                      updateAvailableVersion: _updateStatus?.updateAvailableVersion,
                      onUpdateTap: _solicitarActualizacion,
                      content: _contenidoSeccion(_section!),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenidoSeccion(AppSection section) {
    switch (section) {
      case AppSection.sync:
        return SyncSection(
          cuentas: _cuentas,
          service: _service,
          busy: _busy,
          onBusyChanged: (v) => setState(() => _busy = v),
          onEstadoChanged: (v) => setState(() => _estado = v),
        );
      case AppSection.backup:
        return BackupSection(
          cuentas: _cuentas,
          service: _service,
          busy: _busy,
          onBusyChanged: (v) => setState(() => _busy = v),
          onEstadoChanged: (v) => setState(() => _estado = v),
        );
      case AppSection.delete:
        return DeleteSection(
          cuentas: _cuentas,
          service: _service,
          busy: _busy,
          onBusyChanged: (v) => setState(() => _busy = v),
          onEstadoChanged: (v) => setState(() => _estado = v),
        );
      case AppSection.cloud:
        return CloudSection(
          cuentas: _cuentas,
          service: _service,
          busy: _busy,
          onBusyChanged: (v) => setState(() => _busy = v),
          onEstadoChanged: (v) => setState(() => _estado = v),
        );
      case AppSection.optimized:
        return OptimizedSection(
          cuentas: _cuentas,
          service: _service,
          busy: _busy,
          onBusyChanged: (v) => setState(() => _busy = v),
          onEstadoChanged: (v) => setState(() => _estado = v),
        );
    }
  }

  Widget _dragStrip() => GestureDetector(
    onPanStart: (_) => windowManager.startDragging(),
    child: Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          WinBtn(Icons.remove, S.minimize, () => windowManager.minimize()),
          const SizedBox(width: 4),
          WinBtn(Icons.close, S.closeWindow, () => windowManager.close(), closeStyle: true),
        ],
      ),
    ),
  );
}
