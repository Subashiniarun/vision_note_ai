import 'package:flutter/material.dart';

class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;
  static const double full = 9999;

  static BorderRadius get smBorder => BorderRadius.circular(sm);
  static BorderRadius get mdBorder => BorderRadius.circular(md);
  static BorderRadius get lgBorder => BorderRadius.circular(lg);
  static BorderRadius get xlBorder => BorderRadius.circular(xl);
  static BorderRadius get xxlBorder => BorderRadius.circular(xxl);

  static RoundedRectangleBorder get mdShape => RoundedRectangleBorder(borderRadius: mdBorder);
  static RoundedRectangleBorder get lgShape => RoundedRectangleBorder(borderRadius: lgBorder);
  static RoundedRectangleBorder get fullShape => RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(full)));
}
