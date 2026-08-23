import 'package:flutter/material.dart';

import '../models/app_section.dart';
import '../theme/palette.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/language_toggle.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onSectionTap,
    required this.busy,
    required this.cooldown,
    required this.estado,
    required this.onRefresh,
    required this.version,
    this.lastUpdatedUtc,
    this.updateAvailableVersion,
    this.onUpdateTap,
  });

  final ValueChanged<AppSection> onSectionTap;
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
      const SizedBox(height: 24),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                const Text(
                  'D2Sync',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    'by Nexo',
                    style: TextStyle(color: textSub, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: LanguageToggle(),
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(48, 0, 48, 28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
            ),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.2,
              children: [
                for (final section in AppSection.values)
                  _HomeGridButton(section: section, onTap: () => onSectionTap(section)),
              ],
            ),
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

class _HomeGridButton extends StatefulWidget {
  const _HomeGridButton({required this.section, required this.onTap});
  final AppSection section;
  final VoidCallback onTap;

  @override
  State<_HomeGridButton> createState() => _HomeGridButtonState();
}

class _HomeGridButtonState extends State<_HomeGridButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: _hover ? darkCard.withValues(alpha: 0.85) : darkCard.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hover ? cyanLight.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.10),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _hover ? cyanLight.withValues(alpha: 0.18) : Colors.black.withValues(alpha: 0.25),
              blurRadius: _hover ? 18 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.section.icono, color: _hover ? cyanLight : Colors.white70, size: 48),
            const SizedBox(height: 14),
            Text(
              widget.section.titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _hover ? Colors.white : Colors.white70,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
