import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../models/cuenta_steam.dart';
import '../../services/steam_sync_service.dart';
import '../../widgets/common.dart';

class DeleteSection extends StatefulWidget {
  const DeleteSection({
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
  State<DeleteSection> createState() => _DeleteSectionState();
}

class _DeleteSectionState extends State<DeleteSection> {
  CuentaSteam? _seleccion;

  Future<void> _run(Future<void> Function() action) =>
      ejecutarConCarga(context, widget.onBusyChanged, action);

  @override
  Widget build(BuildContext context) {
    final busy = widget.busy;
    final seleccion = _seleccion;

    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccountCard(
          label: S.deleteAccountLabel,
          value: _seleccion,
          iconColor: Colors.redAccent,
          cuentas: widget.cuentas,
          busy: busy,
          onChanged: (v) => setState(() => _seleccion = v),
        ),
        if (seleccion != null) ...[
          const SizedBox(height: 16),
          StatusCard(
            color: const Color(0xFFFF6B6B),
            icon: Icons.warning_rounded,
            title: S.willDeleteData(seleccion.nombreVisible),
            sub: S.deleteWarningSub,
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GradButton(
                icon: Icons.delete_forever_rounded,
                label: S.deleteButton,
                enabled: !busy && _seleccion != null,
                onTap: () async {
                  final ok = await confirmar(
                    context,
                    S.deleteNoBackupTitle,
                    S.deleteNoBackupMessage(_seleccion!.nombreVisible),
                    destructivo: true,
                  );
                  if (!ok) return;
                  await _run(() async {
                    widget.onEstadoChanged(S.deletingAccount);
                    await widget.service.eliminarCuenta(_seleccion!);
                    widget.onEstadoChanged(S.accountDeleted);
                    setState(() => _seleccion = null);
                  });
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GradButton(
                icon: Icons.manage_accounts_rounded,
                label: S.deleteAndRemoveButton,
                enabled: !busy && _seleccion != null,
                onTap: () async {
                  final ok = await confirmar(
                    context,
                    S.deleteAndRemoveTitle,
                    S.deleteAndRemoveMessage(_seleccion!.nombreVisible),
                    destructivo: true,
                  );
                  if (!ok) return;
                  await _run(() async {
                    widget.onEstadoChanged(S.deletingAndRemoving);
                    await widget.service.eliminarCuenta(_seleccion!, quitarDelLauncher: true);
                    widget.onEstadoChanged(S.accountDeletedAndRemoved);
                    setState(() => _seleccion = null);
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
      ),
    );
  }
}
