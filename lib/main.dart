import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import 'package:virtual_career/config/routes/routes.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/generated/assets.dart';

import 'core/theme/app_colors.dart';
import 'di.dart';
import 'firebase_options.dart';

var ttfFont;
var materialIcon;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ttf = await fontFromAssetBundle(Assets.fontsRobotoRegular);
  ttfFont = ttf;

  final materialIconFont = pw.Font.ttf(
    await rootBundle.load(Assets.fontsMaterialIconsRegular),
  );
  materialIcon = materialIconFont;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await DI().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return ScreenUtilInit(
      designSize: Size(responsive.deviceWidth(), responsive.deviceHeight()),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child){
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              backgroundColor: AppColor.primaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: AppTextStyles.titleOpenSans.copyWith(
                color: Colors.white,
              ),
            ),
            primarySwatch: MaterialColor(
              AppColor.primaryColor.toARGB32(),
              const <int, Color>{
                50: AppColor.primaryColor,
                100: AppColor.primaryColor,
                200: AppColor.primaryColor,
                300: AppColor.primaryColor,
                400: AppColor.primaryColor,
                500: AppColor.primaryColor,
                600: AppColor.primaryColor,
                700: AppColor.primaryColor,
                800: AppColor.primaryColor,
                900: AppColor.primaryColor,
              },
            ),
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp, fontFamily: GoogleFonts.poppins().fontFamily, bodyColor: Colors.black    ),
            scaffoldBackgroundColor: AppColor.scaffoldBackgroundColor,
            primaryColor: AppColor.primaryColor,
          ),
          initialRoute: RouteNames.splash,
          getPages: AppRoutes.routes,
        );
      },
    );
  }
}
