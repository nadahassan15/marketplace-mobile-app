import 'package:flutter/material.dart';

/// Responsive wrapper that adapts layout based on screen size
class ResponsiveWrapper extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWrapper({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return 16.0;
    } else if (isTablet(context)) {
      return 24.0;
    } else {
      return 32.0;
    }
  }

  static double getResponsiveWidth(BuildContext context, {
    double mobile = 300,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.5;
    } else {
      return desktop ?? mobile * 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

/// Widget that adapts to orientation changes
class AppOrientationBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Orientation orientation) builder;

  const AppOrientationBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final orientation = constraints.maxWidth > constraints.maxHeight
            ? Orientation.landscape
            : Orientation.portrait;
        return builder(context, orientation);
      },
    );
  }
}

