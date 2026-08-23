import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../models/cuenta_steam.dart';
import '../theme/palette.dart';

// Centinela para distinguir "canceló el popup" de "eligió sin elección"
class Sentinel {
  const Sentinel();
}

/// Ejecuta [action] mostrando un popup de "Aplicando cambios..." que dura
/// al menos 2 segundos (aunque la acción termine antes), y si algo falla
/// muestra el popup de error de siempre. Comparte el estado de "ocupado".
Future<void> ejecutarConCarga(
  BuildContext context,
  ValueChanged<bool> onBusyChanged,
  Future<void> Function() action,
) async {
  onBusyChanged(true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _LoadingPopup(),
  );

  final inicio = DateTime.now();
  Object? error;
  try {
    await action();
  } catch (e) {
    error = e;
  }

  final falta = const Duration(seconds: 2) - DateTime.now().difference(inicio);
  if (falta > Duration.zero) await Future.delayed(falta);

  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
    onBusyChanged(false);
  }

  if (error != null && context.mounted) {
    final msg = '$error'.replaceFirst(RegExp(r'^[A-Za-z]+Error:\s*'), '');
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(S.couldNotComplete, style: const TextStyle(color: Colors.white)),
        content: Text(msg, style: const TextStyle(color: textSub)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.ok, style: const TextStyle(color: cyanLight)),
          ),
        ],
      ),
    );
  }
}

class _LoadingPopup extends StatelessWidget {
  const _LoadingPopup();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 3, color: cyanLight),
          ),
          const SizedBox(height: 16),
          Text(
            S.applyingChanges,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

Future<bool> confirmar(
  BuildContext context,
  String titulo,
  String mensaje, {
  bool destructivo = false,
}) async {
  final ok = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    barrierLabel: '',
    pageBuilder: (dialogContext, _, _) {
      void cerrar(bool v) => Navigator.of(dialogContext).pop(v);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Center(
          child: Container(
            width: 420,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F38),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: (destructivo
                                    ? const Color(0xFFCC3333)
                                    : cyanDark)
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            destructivo
                                ? Icons.warning_rounded
                                : Icons.help_outline_rounded,
                            color: destructivo
                                ? const Color(0xFFFF5555)
                                : cyanLight,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      mensaje,
                      style: const TextStyle(
                        color: textSub,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ConfirmBtn(
                            label: S.cancel,
                            onTap: () => cerrar(false),
                            red: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ConfirmBtn(
                            label: S.confirm,
                            onTap: () => cerrar(true),
                            red: destructivo,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  return ok ?? false;
}

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.cuentas,
    required this.busy,
    required this.onChanged,
    this.excluded,
  });
  final String label;
  final CuentaSteam? value;
  final Color iconColor;
  final List<CuentaSteam> cuentas;
  final bool busy;
  final ValueChanged<CuentaSteam?> onChanged;
  final CuentaSteam? excluded;

  Future<void> _abrirPopup(BuildContext context) async {
    final result = await showGeneralDialog<Object?>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      barrierLabel: '',
      pageBuilder: (dialogContext, _, _) => AccountPickerDialog(
        cuentas: cuentas,
        selected: value,
        excluded: excluded,
        iconColor: iconColor,
        onClose: (v) => Navigator.of(dialogContext).pop(v),
      ),
    );
    if (result is Sentinel) return; // X presionada — no cambiar nada
    onChanged(result is CuentaSteam ? result : null);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 5),
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2),
          ),
        ),
        GestureDetector(
          onTap: busy ? null : () => _abrirPopup(context),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: busy ? darkCard.withValues(alpha: 0.6) : darkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.person_rounded,
                    color: hasValue ? iconColor : Colors.white24, size: 21),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    hasValue ? value!.nombreVisible : S.noSelection,
                    style: TextStyle(
                      color: hasValue ? Colors.white : Colors.white38,
                      fontSize: 13.5,
                      fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: busy ? Colors.white12 : Colors.white30,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AccountPickerDialog extends StatelessWidget {
  const AccountPickerDialog({
    super.key,
    required this.cuentas,
    required this.selected,
    required this.excluded,
    required this.iconColor,
    required this.onClose,
  });
  final List<CuentaSteam> cuentas;
  final CuentaSteam? selected;
  final CuentaSteam? excluded;
  final Color iconColor;
  final void Function(Object?) onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Center(
        child: Container(
          width: 360,
          constraints: const BoxConstraints(maxHeight: 420),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F38),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.07), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people_rounded, color: iconColor, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          S.selectAccount,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      CloseBtn(onTap: () => onClose(const Sentinel())),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    children: [
                      PickerItem(
                        icon: Icons.remove_circle_outline_rounded,
                        label: S.noSelection,
                        isSelected: selected == null,
                        isLocked: false,
                        iconColor: Colors.white24,
                        onTap: () => onClose(null),
                      ),
                      const Divider(
                          color: Color(0xFF252B4A), height: 1, indent: 16, endIndent: 16),
                      ...cuentas.asMap().entries.map((entry) {
                        final i = entry.key;
                        final c = entry.value;
                        final isSelected = selected?.steamId == c.steamId;
                        final isLocked = excluded?.steamId == c.steamId;
                        return Column(
                          children: [
                            if (i > 0)
                              Divider(
                                color: Colors.white.withValues(alpha: 0.06),
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                            PickerItem(
                              icon: Icons.person_rounded,
                              steamId: c.steamId,
                              nombre: c.nombre == c.steamId ? '' : c.nombre,
                              isSelected: isSelected,
                              isLocked: isLocked,
                              iconColor: iconColor,
                              onTap: isLocked ? null : () => onClose(c),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CloudToggleBtn extends StatefulWidget {
  const CloudToggleBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.hoverColor,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color hoverColor;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<CloudToggleBtn> createState() => _CloudToggleBtnState();
}

class _CloudToggleBtnState extends State<CloudToggleBtn>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 80),
    lowerBound: 0,
    upperBound: 0.03,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) { if (enabled) setState(() => _hover = true); },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: enabled ? (_) => _ctrl.forward() : null,
        onTapUp: enabled ? (_) { _ctrl.reverse(); widget.onTap(); } : null,
        onTapCancel: () => _ctrl.reverse(),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Transform.scale(scale: 1.0 - _ctrl.value, child: child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            height: 52,
            decoration: BoxDecoration(
              color: enabled
                  ? (_hover ? widget.hoverColor : widget.color)
                  : const Color(0xFF1E2438),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: enabled
                    ? widget.color.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: _hover ? 0.40 : 0.25),
                        blurRadius: _hover ? 18 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon,
                      size: 17,
                      color: enabled ? Colors.white : Colors.white24),
                  const SizedBox(width: 9),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.white24,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConfirmBtn extends StatefulWidget {
  const ConfirmBtn({super.key, required this.label, required this.onTap, required this.red});
  final String label;
  final VoidCallback onTap;
  final bool red;
  @override
  State<ConfirmBtn> createState() => _ConfirmBtnState();
}

class _ConfirmBtnState extends State<ConfirmBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final baseColor = widget.red ? const Color(0xFFCC2222) : const Color(0xFF252B4A);
    final hoverColor = widget.red ? const Color(0xFFDD3333) : const Color(0xFF2E3A58);
    final borderColor = widget.red
        ? Colors.red.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.10);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 42,
          decoration: BoxDecoration(
            color: _hover ? hoverColor : baseColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.red ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CloseBtn extends StatefulWidget {
  const CloseBtn({super.key, required this.onTap});
  final VoidCallback onTap;
  @override
  State<CloseBtn> createState() => _CloseBtnState();
}

class _CloseBtnState extends State<CloseBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _hover
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white38, size: 18),
      ),
    ),
  );
}

class PickerItem extends StatefulWidget {
  const PickerItem({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.isLocked,
    required this.iconColor,
    required this.onTap,
    this.label,
    this.steamId,
    this.nombre,
  });
  final IconData icon;
  final String? label;
  final String? steamId;
  final String? nombre;
  final bool isSelected;
  final bool isLocked;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  State<PickerItem> createState() => _PickerItemState();
}

class _PickerItemState extends State<PickerItem> {
  bool _hover = false;

  Color get _textColor => widget.isLocked
      ? Colors.white.withValues(alpha: 0.20)
      : widget.isSelected
          ? Colors.white
          : Colors.white70;

  @override
  Widget build(BuildContext context) {
    final active = !widget.isLocked;
    return MouseRegion(
      cursor: active ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) { if (active) setState(() => _hover = true); },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? cyanDark.withValues(alpha: 0.18)
                : _hover
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: widget.isSelected
                ? Border.all(color: cyanLight.withValues(alpha: 0.30), width: 1)
                : Border.all(color: Colors.transparent, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isLocked
                    ? Colors.white12
                    : widget.isSelected
                        ? cyanLight
                        : widget.iconColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: widget.label != null
                    ? Text(
                        widget.label!,
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 13.5,
                          fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      )
                    : Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              widget.steamId ?? '',
                              style: TextStyle(
                                color: widget.isLocked
                                    ? Colors.white.withValues(alpha: 0.20)
                                    : cyanLight.withValues(alpha: widget.isSelected ? 1.0 : 0.75),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          if ((widget.nombre ?? '').isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.nombre!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _textColor,
                                  fontSize: 13.5,
                                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              if (widget.isLocked)
                Icon(Icons.lock_rounded, size: 14, color: Colors.white.withValues(alpha: 0.20)),
              if (widget.isSelected && !widget.isLocked)
                const Icon(Icons.check_rounded, size: 16, color: cyanLight),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón con gradiente cyan + gloss + sombra + animación de escala.
class GradButton extends StatefulWidget {
  const GradButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.enabled = true,
    this.height = 44,
    this.fontSize = 13,
    this.letterSpacing = 0.8,
  });
  final IconData? icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final double height;
  final double fontSize;
  final double letterSpacing;

  @override
  State<GradButton> createState() => _GradButtonState();
}

class _GradButtonState extends State<GradButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
    lowerBound: 0.0,
    upperBound: 0.04,
  );
  bool _hover = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      onTapDown: widget.enabled ? (_) => _ctrl.forward() : null,
      onTapUp: widget.enabled
          ? (_) {
              _ctrl.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _ctrl.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.enabled
                ? (_hover
                    ? const LinearGradient(
                        colors: [Color(0xFF7AECFF), Color(0xFF28A8F0)])
                    : gradCyan)
                : gradDisabled,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: widget.enabled
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: cyanLight.withValues(alpha: _hover ? 0.45 : 0.28),
                      blurRadius: _hover ? 20 : 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 17,
                    color: widget.enabled ? darkTab : Colors.white30,
                  ),
                  const SizedBox(width: 9),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.enabled ? darkTab : Colors.white30,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.fontSize,
                    letterSpacing: widget.letterSpacing,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Botón oscuro pill (Actualizar cuentas).
class DarkPillButton extends StatefulWidget {
  const DarkPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<DarkPillButton> createState() => _DarkPillButtonState();
}

class _DarkPillButtonState extends State<DarkPillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
    lowerBound: 0.0,
    upperBound: 0.03,
  );
  bool _hover = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      onTapDown: widget.enabled ? (_) => _ctrl.forward() : null,
      onTapUp: widget.enabled
          ? (_) {
              _ctrl.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) =>
            Transform.scale(scale: 1.0 - _ctrl.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _hover && widget.enabled
                ? const Color(0xFF252B4A)
                : darkCard,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon,
                  color: widget.enabled ? Colors.white70 : Colors.white30,
                  size: 15),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.enabled ? Colors.white : Colors.white30,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.sub,
  });
  final Color color;
  final IconData icon;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 220),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.22), width: 1),
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color == Colors.white24 ? Colors.white38 : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  color: color == Colors.white24 ? Colors.white24 : textSub,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Botón de ventana (minimizar/cerrar).
class WinBtn extends StatefulWidget {
  const WinBtn(this.icon, this.tooltip, this.onTap, {super.key, this.closeStyle = false});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool closeStyle;

  @override
  State<WinBtn> createState() => _WinBtnState();
}

class _WinBtnState extends State<WinBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: widget.tooltip,
    child: MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hover
                ? (widget.closeStyle
                    ? const Color(0xFFCC3333)
                    : Colors.white.withValues(alpha: 0.15))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(widget.icon, size: 14, color: Colors.white60),
        ),
      ),
    ),
  );
}
