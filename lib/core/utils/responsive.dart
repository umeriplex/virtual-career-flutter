import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  // Breakpoints for different screen sizes
  static const int mobileBreakpoint = 600;
  static const int tabletBreakpoint = 1200;

  // Check if the device is a mobile device
  bool isMobile() {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  // Check if the device is a tablet
  bool isTablet() {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  // Check if the device is a desktop
  bool isDesktop() {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Get width of the device
  double deviceWidth({ double percent = 1.0 }) {
    return MediaQuery.of(context).size.width * percent;
  }

  // Get height of the device
  double deviceHeight({ double percent = 1.0 }) {
    return MediaQuery.of(context).size.height * percent;
  }

  // Determine if it's a portrait or landscape orientation
  bool isPortrait() {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // Determine if it's a landscape orientation
  bool isLandscape() {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Get responsive font size based on screen width
  double responsiveFontSize(double baseFontSize) {
    return baseFontSize *
        (deviceWidth() / 375.0); // Assuming 375 is the base width (iPhone 8)
  }

// Get responsive padding
  EdgeInsets responsivePadding(
      double left, double top, double right, double bottom) {
    return EdgeInsets.fromLTRB(
      left * (deviceWidth() / 375.0),
      top * (deviceHeight() / 667.0),
      right * (deviceWidth() / 375.0),
      bottom * (deviceHeight() / 667.0),
    );
  }
}