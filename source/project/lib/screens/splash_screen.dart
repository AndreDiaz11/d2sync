import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/palette.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: gradBg),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 3, color: cyanLight),
            ),
            const SizedBox(height: 22),
            const Text(
              'D2Sync',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              S.loading,
              style: const TextStyle(color: textSub, fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );
}
