import 'package:flutter/material.dart';

const ink = Color(0xff0e0e0e);
const orange = Color(0xfffa963a);
const muted = Color(0xff999999);
const warmGradient = LinearGradient(
  colors: [Color(0xfffc9a36), Color(0xffff5038)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const panelGradient = LinearGradient(
  colors: [Color(0xff3b2423), Color(0xff49493f)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
ThemeData get musicTheme => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: ink,
  fontFamily: 'Roboto',
  fontFamilyFallback: const [
    'Noto Sans CJK SC',
    'Noto Sans CJK JP',
    'Microsoft YaHei',
    'Yu Gothic',
    'PingFang SC',
    'Hiragino Sans',
  ],
  colorScheme: const ColorScheme.dark(
    primary: orange,
    surface: ink,
    secondary: orange,
  ),
  splashFactory: InkRipple.splashFactory,
  appBarTheme: const AppBarTheme(
    backgroundColor: ink,
    elevation: 0,
    centerTitle: true,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 15, color: Colors.white),
    bodySmall: TextStyle(fontSize: 12, color: muted),
  ),
  dividerTheme: const DividerThemeData(color: Color(0xff303030), thickness: .6),
  sliderTheme: const SliderThemeData(
    activeTrackColor: orange,
    thumbColor: orange,
    inactiveTrackColor: Color(0xff666661),
    trackHeight: 2,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xff777777)),
    ),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: orange)),
  ),
);
