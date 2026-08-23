import 'package:flutter/material.dart';

const bgTop      = Color(0xFF5878B8);
const bgBot      = Color(0xFF384E8A);
const darkCard   = Color(0xFF1A1F38);
const darkTab    = Color(0xFF12172A);
const cyanLight  = Color(0xFF5AE4FF);
const cyanDark   = Color(0xFF1890D8);
const iconBlue   = Color(0xFF5B9BD5);
const iconOrange = Color(0xFFE8924E);
const textSub    = Color(0xFFB0C4E8);

const gradCyan = LinearGradient(colors: [cyanLight, cyanDark]);
const gradDisabled = LinearGradient(
  colors: [Color(0xFF2E3A58), Color(0xFF222E48)],
);
const gradBg = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [bgTop, bgBot],
);
