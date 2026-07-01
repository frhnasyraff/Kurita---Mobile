import 'package:flutter/material.dart';

void goToModule(BuildContext context, int index) {
  if (index == 3) return;
  Navigator.of(context).popUntil((route) => route.isFirst);
}
