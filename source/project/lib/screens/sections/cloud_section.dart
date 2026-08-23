import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../models/cuenta_steam.dart';
import '../../services/steam_sync_service.dart';
import '../../theme/palette.dart';
import '../../widgets/common.dart';

class CloudSection extends StatefulWidget {
  const CloudSection({
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
  State<CloudSection> createState() => _CloudSectionState();
}

class _CloudSectionState extends State<CloudSection> {
  CuentaSteam? _seleccion;
  bool? _cloudStatus;
  bool _cloudVerificado = false;

  Future<void> _run(Future<void> Function() action) =>
      ejecutarConCarga(context, widget.onBusyChanged, action);

  @override
  Widget build(BuildContext context) {
    final busy = widget.busy;
    final bool sinCuenta = _seleccion == null;
    final bool sinVerificar = !_cloudVerificado;
    final bool cloudActivo = _cloudStatus == true;

    Color statusColor = Colors.white24;
    IconData statusIcon = Icons.person_off_rounded;
    String statusTitle = '';
    String statusSub = '';

    if (sinVerificar) {
      statusColor = Colors.white38;
      statusIcon = Icons.cloud_queue_rounded;
      statusTitle = S.unknownStatus;
      statusSub = S.cloudCheckPrompt;
    } else if (cloudActivo) {
      statusColor = const Color(0xFF2ECC71);
      statusIcon = Icons.cloud_done_rounded;
      statusTitle = S.cloudEnabledTitle;
      statusSub = S.cloudEnabledSub;
    } else if (_cloudStatus == false) {
      statusColor = const Color(0xFFFF6B6B);
      statusIcon = Icons.cloud_off_rounded;
      statusTitle = S.cloudDisabledTitle;
      statusSub = S.cloudDisabledSub;
    } else {
      statusColor = const Color(0xFFFFB74D);
      statusIcon = Icons.cloud_upload_rounded;
      statusTitle = S.cloudNoConfigTitle;
      statusSub = S.cloudNoConfigSub;
    }

    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccountCard(
          label: S.steamAccountLabel,
          value: _seleccion,
          iconColor: cyanLight,
          cuentas: widget.cuentas,
          busy: busy,
          onChanged: (v) => setState(() {
            _seleccion = v;
            _cloudStatus = null;
            _cloudVerificado = false;
          }),
        ),
        if (!sinCuenta) ...[
          const SizedBox(height: 16),
          StatusCard(color: statusColor, icon: statusIcon, title: statusTitle, sub: statusSub),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GradButton(
                icon: Icons.manage_search_rounded,
                label: S.checkButton,
                enabled: !busy && _seleccion != null,
                onTap: () => _run(() async {
                  widget.onEstadoChanged(S.checkingCloud);
                  final enabled = await widget.service.obtenerSteamCloudDota(_seleccion!);
                  setState(() {
                    _cloudStatus = enabled;
                    _cloudVerificado = true;
                  });
                  widget.onEstadoChanged(enabled == null
                      ? S.noCloudConfigForAccount
                      : enabled
                          ? S.cloudEnabledFor(_seleccion!.nombreVisible)
                          : S.cloudDisabledFor(_seleccion!.nombreVisible));
                }),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _cloudStatus == true
                  ? CloudToggleBtn(
                      icon: Icons.cloud_off_rounded,
                      label: S.disableButton,
                      color: const Color(0xFFCC2222),
                      hoverColor: const Color(0xFFDD3333),
                      enabled: !busy,
                      onTap: () => _run(() async {
                        widget.onEstadoChanged(S.disablingCloud);
                        await widget.service.cambiarSteamCloudDota(_seleccion!, false);
                        setState(() => _cloudStatus = false);
                        widget.onEstadoChanged(S.cloudDisabledForLower(_seleccion!.nombreVisible));
                      }),
                    )
                  : CloudToggleBtn(
                      icon: Icons.cloud_upload_rounded,
                      label: S.enableButton,
                      color: const Color(0xFF1A7A3A),
                      hoverColor: const Color(0xFF228844),
                      enabled: !busy && _cloudVerificado,
                      onTap: () => _run(() async {
                        widget.onEstadoChanged(S.enablingCloud);
                        await widget.service.cambiarSteamCloudDota(_seleccion!, true);
                        setState(() => _cloudStatus = true);
                        widget.onEstadoChanged(S.cloudEnabledForLower(_seleccion!.nombreVisible));
                      }),
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
