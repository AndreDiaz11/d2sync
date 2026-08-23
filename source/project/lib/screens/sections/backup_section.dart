import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../models/cuenta_steam.dart';
import '../../services/steam_sync_service.dart';
import '../../theme/palette.dart';
import '../../widgets/common.dart';

class BackupSection extends StatefulWidget {
  const BackupSection({
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
  State<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends State<BackupSection> {
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
          label: S.accountLabel,
          value: _seleccion,
          iconColor: iconBlue,
          cuentas: widget.cuentas,
          busy: busy,
          onChanged: (v) => setState(() => _seleccion = v),
        ),
        if (seleccion != null) ...[
          const SizedBox(height: 16),
          StatusCard(
            color: const Color(0xFF8BD4FF),
            icon: Icons.folder_copy_rounded,
            title: seleccion.nombreVisible,
            sub: S.backupSub,
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GradButton(
                icon: Icons.save_rounded,
                label: S.saveBackupButton,
                enabled: !busy && _seleccion != null,
                onTap: () => _run(() async {
                  final folder = await FilePicker.getDirectoryPath(
                    dialogTitle: S.pickSaveFolderTitle,
                  );
                  if (folder == null) return;
                  widget.onEstadoChanged(S.savingBackup);
                  final path = await widget.service.guardarBackupCuenta(_seleccion!, folder);
                  widget.onEstadoChanged(S.backupSavedAt(path));
                }),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GradButton(
                icon: Icons.restore_rounded,
                label: S.loadBackupButton,
                enabled: !busy && _seleccion != null,
                onTap: () async {
                  final ok = await confirmar(
                    context,
                    S.loadBackupConfirmTitle,
                    S.loadBackupConfirmMessage(_seleccion!.nombreVisible),
                    destructivo: true,
                  );
                  if (!ok) return;
                  final folder = await FilePicker.getDirectoryPath(
                    dialogTitle: S.pickLoadFolderTitle,
                  );
                  if (folder == null) return;
                  await _run(() async {
                    widget.onEstadoChanged(S.loadingBackup);
                    await widget.service.cargarBackupEnCuenta(folder, _seleccion!);
                    widget.onEstadoChanged(S.backupLoadedInto(_seleccion!.nombreVisible));
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
