import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../models/cuenta_steam.dart';
import '../../services/steam_sync_service.dart';
import '../../theme/palette.dart';
import '../../widgets/common.dart';

class SyncSection extends StatefulWidget {
  const SyncSection({
    super.key,
    required this.cuentas,
    required this.service,
    required this.busy,
    required this.onBusyChanged,
    required this.onEstadoChanged,
  });

  final List<CuentaSteam> cuentas;
  final SteamSyncService service;
  final bool busy;
  final ValueChanged<bool> onBusyChanged;
  final ValueChanged<String> onEstadoChanged;

  @override
  State<SyncSection> createState() => _SyncSectionState();
}

class _SyncSectionState extends State<SyncSection> {
  CuentaSteam? _origen;
  CuentaSteam? _destino;

  Future<void> _run(Future<void> Function() action) =>
      ejecutarConCarga(context, widget.onBusyChanged, action);

  @override
  Widget build(BuildContext context) {
    final busy = widget.busy;
    final bool listos = _origen != null && _destino != null;

    final bool sinNada = _origen == null && _destino == null;

    Color statusColor = Colors.white24;
    IconData statusIcon = Icons.swap_horiz_rounded;
    String statusTitle = '';
    String statusSub = '';

    if (_origen == null) {
      statusColor = iconBlue;
      statusIcon = Icons.arrow_back_rounded;
      statusTitle = S.syncMissingSource;
      statusSub = S.syncMissingSourceSub;
    } else if (_destino == null) {
      statusColor = iconOrange;
      statusIcon = Icons.arrow_forward_rounded;
      statusTitle = S.syncMissingTarget;
      statusSub = S.syncMissingTargetSub(_origen!.nombreVisible);
    } else {
      statusColor = const Color(0xFF2ECC71);
      statusIcon = Icons.sync_rounded;
      statusTitle = S.syncReady;
      statusSub = '"${_origen!.nombreVisible}"  →  "${_destino!.nombreVisible}"';
    }

    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccountCard(
          label: S.syncSourceLabel,
          value: _origen,
          iconColor: iconBlue,
          cuentas: widget.cuentas,
          busy: busy,
          excluded: _destino,
          onChanged: (v) => setState(() => _origen = v),
        ),
        const SizedBox(height: 14),
        AccountCard(
          label: S.syncTargetLabel,
          value: _destino,
          iconColor: iconOrange,
          cuentas: widget.cuentas,
          busy: busy,
          excluded: _origen,
          onChanged: (v) => setState(() => _destino = v),
        ),
        if (!sinNada) ...[
          const SizedBox(height: 16),
          StatusCard(color: statusColor, icon: statusIcon, title: statusTitle, sub: statusSub),
        ],
        const SizedBox(height: 16),
        GradButton(
          icon: Icons.sync_rounded,
          label: S.syncButton,
          enabled: !busy && listos,
          height: 46,
          fontSize: 14,
          letterSpacing: 1.2,
          onTap: () async {
            final ok = await confirmar(
              context,
              S.syncConfirmTitle,
              S.syncConfirmMessage(_destino!.nombreVisible, _origen!.nombreVisible),
            );
            if (ok) {
              await _run(() async {
                widget.onEstadoChanged(S.syncing);
                await widget.service.ejecutarSincronizacion(_origen!, _destino!);
                widget.onEstadoChanged(S.syncDone);
              });
            }
          },
        ),
        const SizedBox(height: 16),
      ],
      ),
    );
  }
}
