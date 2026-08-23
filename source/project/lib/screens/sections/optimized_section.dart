import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../models/cuenta_steam.dart';
import '../../models/optimization_option.dart';
import '../../services/steam_sync_service.dart';
import '../../theme/palette.dart';
import '../../widgets/common.dart';

class OptimizedSection extends StatefulWidget {
  const OptimizedSection({
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
  State<OptimizedSection> createState() => _OptimizedSectionState();
}

class _OptimizedSectionState extends State<OptimizedSection> {
  CuentaSteam? _seleccion;
  bool _verificado = false;
  String _launchActual = '';
  final Set<String> _marcadas = {};

  Future<void> _run(Future<void> Function() action) =>
      ejecutarConCarga(context, widget.onBusyChanged, action);

  void _seleccionarCuenta(CuentaSteam? cuenta) {
    setState(() {
      _seleccion = cuenta;
      _verificado = false;
      _launchActual = '';
      _marcadas.clear();
    });
  }

  Future<void> _verificar() => _run(() async {
    widget.onEstadoChanged(S.checkingLaunchOptions);
    final actuales = await widget.service.obtenerLaunchOptionsDota(_seleccion!);
    final tokens = ' $actuales ';
    setState(() {
      _launchActual = actuales;
      _marcadas
        ..clear()
        ..addAll(kOptimizationOptions.where((o) => tokens.contains(' ${o.flag} ')).map((o) => o.id));
      _verificado = true;
    });
    widget.onEstadoChanged(actuales.isEmpty
        ? S.noLaunchOptionsFor(_seleccion!.nombreVisible)
        : S.launchOptionsCheckedFor(_seleccion!.nombreVisible));
  });

  @override
  Widget build(BuildContext context) {
    final busy = widget.busy;
    final bool sinCuenta = _seleccion == null;
    final bool sinVerificar = !_verificado;

    Color statusColor = Colors.white24;
    IconData statusIcon = Icons.person_off_rounded;
    String statusTitle = '';
    String statusSub = '';

    if (sinVerificar) {
      statusColor = Colors.white38;
      statusIcon = Icons.manage_search_rounded;
      statusTitle = S.unknownStatus;
      statusSub = S.optimizeCheckPrompt;
    } else if (_launchActual.isEmpty) {
      statusColor = const Color(0xFFFFB74D);
      statusIcon = Icons.info_outline_rounded;
      statusTitle = S.noLaunchOptionsTitle;
      statusSub = S.noLaunchOptionsSub;
    } else {
      statusColor = const Color(0xFF8BD4FF);
      statusIcon = Icons.terminal_rounded;
      statusTitle = S.currentLaunchOptionsTitle;
      statusSub = _launchActual;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccountCard(
          label: S.optimizeAccountLabel,
          value: _seleccion,
          iconColor: iconOrange,
          cuentas: widget.cuentas,
          busy: busy,
          onChanged: _seleccionarCuenta,
        ),
        if (!sinCuenta) ...[
          const SizedBox(height: 16),
          StatusCard(color: statusColor, icon: statusIcon, title: statusTitle, sub: statusSub),
        ],
        const SizedBox(height: 16),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView.separated(
              padding: const EdgeInsets.only(right: 10),
              itemCount: kOptimizationOptions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final option = kOptimizationOptions[index];
                final activa = _marcadas.contains(option.id);
                return _OptionCheckTile(
                  title: option.title,
                  description: option.description,
                  checked: activa,
                  enabled: !busy && !sinCuenta,
                  onChanged: (v) => setState(() {
                    if (v) {
                      _marcadas.add(option.id);
                    } else {
                      _marcadas.remove(option.id);
                    }
                  }),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GradButton(
                icon: Icons.manage_search_rounded,
                label: S.checkButton,
                enabled: !busy && !sinCuenta,
                height: 46,
                fontSize: 14,
                letterSpacing: 1.2,
                onTap: _verificar,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GradButton(
                icon: Icons.bolt_rounded,
                label: S.optimizeButton,
                enabled: !busy && !sinCuenta && _verificado,
                height: 46,
                fontSize: 14,
                letterSpacing: 1.2,
                onTap: () => _run(() async {
                  widget.onEstadoChanged(S.applyingOptimizations);
                  final activas = kOptimizationOptions
                      .where((o) => _marcadas.contains(o.id))
                      .map((o) => o.flag)
                      .toSet();
                  await widget.service.aplicarOptimizacionesDota(
                    _seleccion!,
                    kOptimizationOptions.map((o) => o.flag).toList(),
                    activas,
                  );
                  final nuevoValor = await widget.service.obtenerLaunchOptionsDota(_seleccion!);
                  setState(() => _launchActual = nuevoValor);
                  widget.onEstadoChanged(
                      S.optimizationsApplied(_seleccion!.nombreVisible, activas.length));
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _OptionCheckTile extends StatelessWidget {
  const _OptionCheckTile({
    required this.title,
    required this.description,
    required this.checked,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool checked;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? () => onChanged(!checked) : null,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: checked ? cyanDark.withValues(alpha: 0.10) : darkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: checked ? cyanLight.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Transform.scale(
              scale: 0.85,
              child: Checkbox(
                value: checked,
                onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                activeColor: cyanDark,
                checkColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: enabled ? Colors.white : Colors.white38,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(color: textSub, fontSize: 11.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
