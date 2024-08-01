import 'package:flutter/material.dart';

Widget customPadding({required Widget child}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
    child: child,
  );
}
