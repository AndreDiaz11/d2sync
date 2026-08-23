import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../i18n/app_language.dart';
import '../theme/palette.dart';

const String _svgFlagUs = '''
<svg viewBox="0 0 60 40" xmlns="http://www.w3.org/2000/svg">
  <rect width="60" height="40" fill="#B22234"/>
  <g fill="#FFFFFF">
    <rect y="3.08" width="60" height="3.08"/>
    <rect y="9.23" width="60" height="3.08"/>
    <rect y="15.38" width="60" height="3.08"/>
    <rect y="21.54" width="60" height="3.08"/>
    <rect y="27.69" width="60" height="3.08"/>
    <rect y="33.85" width="60" height="3.08"/>
  </g>
  <rect width="24" height="21.54" fill="#3C3B6E"/>
</svg>
''';

const String _svgFlagEs = '''
<svg viewBox="0 0 60 40" xmlns="http://www.w3.org/2000/svg">
  <rect width="60" height="40" fill="#AA151B"/>
  <rect y="10" width="60" height="20" fill="#F1BF00"/>
</svg>
''';

/// Par de botones EN/ES con banderas para elegir el idioma de toda la app.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final en = languageController.isEn;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LangPill(
          flagSvg: _svgFlagUs,
          label: 'EN',
          active: en,
          onTap: () => languageController.elegir(AppLanguage.en),
        ),
        const SizedBox(width: 8),
        _LangPill(
          flagSvg: _svgFlagEs,
          label: 'ES',
          active: !en,
          onTap: () => languageController.elegir(AppLanguage.es),
        ),
      ],
    );
  }
}

class _LangPill extends StatefulWidget {
  const _LangPill({
    required this.flagSvg,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String flagSvg;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_LangPill> createState() => _LangPillState();
}

class _LangPillState extends State<_LangPill> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: widget.active
              ? cyanDark.withValues(alpha: 0.22)
              : (_hover ? Colors.black.withValues(alpha: 0.26) : Colors.black.withValues(alpha: 0.18)),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: widget.active
                ? cyanLight.withValues(alpha: 0.55)
                : (_hover ? cyanLight.withValues(alpha: 0.30) : Colors.white.withValues(alpha: 0.10)),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SvgPicture.string(widget.flagSvg, width: 20, height: 14, fit: BoxFit.cover),
            ),
            const SizedBox(width: 7),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.active ? Colors.white : Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
