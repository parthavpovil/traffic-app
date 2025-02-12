import 'package:flutter/material.dart';

class CustomFabLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double centerX = scaffoldGeometry.scaffoldSize.width / 2.0;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;

    // Calculate position to align with nav items
    final double bottomBarHeight = scaffoldGeometry.contentBottom;
    final double fabY = bottomBarHeight - (fabHeight / 2);

    return Offset(centerX - fabHeight / 2.0, fabY);
  }
}
