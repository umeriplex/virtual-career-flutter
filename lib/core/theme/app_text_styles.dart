import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // ----------- POPPINS STYLES -----------

  static TextStyle headlinePoppins = GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static TextStyle subHeadlinePoppins = GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: Colors.black87,

  );

  static TextStyle titlePoppins = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static TextStyle bodyPoppins = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );

  static TextStyle captionPoppins = GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w300,
    color: Colors.grey,
  );

  static TextStyle customPoppins({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = Colors.black,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // ----------- OPEN SANS STYLES -----------

  static TextStyle headlineOpenSans = GoogleFonts.openSans(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static TextStyle subHeadlineOpenSans = GoogleFonts.openSans(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle titleOpenSans = GoogleFonts.openSans(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static TextStyle bodyOpenSans = GoogleFonts.openSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );

  static TextStyle captionOpenSans = GoogleFonts.openSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w300,
    color: Colors.grey,
  );

  static TextStyle customOpenSans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = Colors.black,
  }) {
    return GoogleFonts.openSans(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
