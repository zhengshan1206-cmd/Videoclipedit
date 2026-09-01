import 'package:flutter/material.dart';

class PanToUnfocus extends StatelessWidget {
  const PanToUnfocus({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onPanStart: (details) {
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
  }
}
