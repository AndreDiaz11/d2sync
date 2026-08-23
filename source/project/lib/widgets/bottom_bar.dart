import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';
import 'common.dart';

String _formatearFecha(DateTime utc) {
  final local = utc.toLocal();
  return '${local.day} ${S.mes(local.month)} ${local.year}';
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.busy,
    required this.cooldown,
    required this.estado,
    required this.onRefresh,
    required this.version,
    this.lastUpdatedUtc,
    this.updateAvailableVersion,
    this.onUpdateTap,
  });

  final bool busy;
  final bool cooldown;
  final String estado;
  final VoidCallback onRefresh;
  final String version;
  final DateTime? lastUpdatedUtc;
  final String? updateAvailableVersion;
  final VoidCallback? onUpdateTap;

  @override
  Widget build(BuildContext context) {
    final hayUpdate = updateAvailableVersion != null && updateAvailableVersion != version;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.15),
            Colors.black.withValues(alpha: 0.30),
          ],
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_esports_rounded, color: cyanLight, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        estado,
                        style: const TextStyle(color: textSub, fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (busy) ...[
                      const SizedBox(width: 10),
                      const SizedBox(
                        width: 11,
                        height: 11,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: cyanLight),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              DarkPillButton(
                icon: Icons.refresh_rounded,
                label: S.updateAccounts,
                enabled: !busy && !cooldown,
                onTap: onRefresh,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                S.versionLine(version, lastUpdatedUtc == null ? null : _formatearFecha(lastUpdatedUtc!)),
                style: const TextStyle(color: Colors.white24, fontSize: 10.5),
              ),
              if (hayUpdate) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onUpdateTap,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      S.updateAvailableLink(updateAvailableVersion!),
                      style: const TextStyle(
                        color: cyanLight,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
