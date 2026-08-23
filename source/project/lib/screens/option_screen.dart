import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../models/app_section.dart';
import '../theme/palette.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/common.dart';
import '../widgets/language_toggle.dart';

class OptionScreen extends StatelessWidget {
  const OptionScreen({
    super.key,
    required this.section,
    required this.onBack,
    required this.content,
    required this.busy,
    required this.cooldown,
    required this.estado,
    required this.onRefresh,
    required this.version,
    this.lastUpdatedUtc,
    this.updateAvailableVersion,
    this.onUpdateTap,
  });

  final AppSection section;
  final VoidCallback onBack;
  final Widget content;
  final bool busy;
  final bool cooldown;
  final String estado;
  final VoidCallback onRefresh;
  final String version;
  final DateTime? lastUpdatedUtc;
  final String? updateAvailableVersion;
  final VoidCallback? onUpdateTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(32, 18, 32, 6),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 17),
                      const SizedBox(width: 8),
                      Text(
                        S.back,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'D2Sync',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Text(
              'by Nexo',
              style: TextStyle(color: textSub.withValues(alpha: 0.8), fontSize: 11.5),
            ),
            const SizedBox(width: 12),
            LanguageToggle(),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(44, 10, 44, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(section.icono, color: cyanLight, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        section.titulo,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    section.resumen,
                    style: const TextStyle(color: textSub, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _ComoFuncionaBoton(
              titulo: section.titulo,
              pasos: section.pasos,
            ),
          ],
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(44, 14, 44, 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
            ),
            child: content,
          ),
        ),
      ),
      BottomBar(
        busy: busy,
        cooldown: cooldown,
        estado: estado,
        onRefresh: onRefresh,
        version: version,
        lastUpdatedUtc: lastUpdatedUtc,
        updateAvailableVersion: updateAvailableVersion,
        onUpdateTap: onUpdateTap,
      ),
    ],
  );
}

/// Botón "Cómo funciona" que abre un popup con los pasos numerados,
/// en vez de ocupar espacio fijo en la pantalla.
class _ComoFuncionaBoton extends StatelessWidget {
  const _ComoFuncionaBoton({required this.titulo, required this.pasos});
  final String titulo;
  final List<String> pasos;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _mostrarPopup(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cyanDark.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: cyanLight.withValues(alpha: 0.30), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded, color: cyanLight, size: 15),
            const SizedBox(width: 6),
            Text(
              S.howItWorks,
              style: const TextStyle(color: cyanLight, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _mostrarPopup(BuildContext context) => showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    barrierLabel: '',
    pageBuilder: (dialogContext, _, _) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Center(
        child: Container(
          width: 440,
          constraints: const BoxConstraints(maxHeight: 480),
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
                      bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: cyanLight, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          S.howItWorksTitle(titulo),
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      CloseBtn(onTap: () => Navigator.of(dialogContext).pop()),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < pasos.length; i++)
                          Padding(
                            padding: EdgeInsets.only(bottom: i == pasos.length - 1 ? 0 : 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.only(top: 1),
                                  decoration: const BoxDecoration(color: cyanDark, shape: BoxShape.circle),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    pasos[i],
                                    style: const TextStyle(color: textSub, fontSize: 13, height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
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
