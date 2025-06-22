import 'dart:math';

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

import 'core/components/custom_button.dart';
import 'core/theme/app_colors.dart';
import 'di.dart';
import 'firebase_options.dart';

var ttfFont;
var materialIcon;
Future<void> main() async {


  WidgetsFlutterBinding.ensureInitialized();
  final ttf = await fontFromAssetBundle(Assets.fontsOpenSansRegular);
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
      designSize: const Size(390, 844), // Standard design size (iPhone 13 dimensions)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);

        // Constrain both text scaling and display size
        final constrainedMediaQuery = mediaQueryData.copyWith(
          textScaler: const TextScaler.linear(1.0), // Fixed text scale
          size: Size(
            min(mediaQueryData.size.width, 500), // Max logical width
            mediaQueryData.size.height,
          ),
        );

        return MediaQuery(
          data: constrainedMediaQuery,
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return BotToastInit()(
                  context,
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0),),
                    child: child!,
                  ),
                );
            },
            navigatorObservers: [BotToastNavigatorObserver()],
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                backgroundColor: AppColor.primaryColor,
                iconTheme: const IconThemeData(color: Colors.white),
                titleTextStyle: AppTextStyles.titleOpenSans.copyWith(
                  color: Colors.white,
                  fontSize: 18.sp, // Use sp units for responsive text
                ),
              ),
              primarySwatch: MaterialColor(
                AppColor.primaryColor.value,
                <int, Color>{
                  50: AppColor.primaryColor.withOpacity(0.1),
                  100: AppColor.primaryColor.withOpacity(0.2),
                  200: AppColor.primaryColor.withOpacity(0.3),
                  300: AppColor.primaryColor.withOpacity(0.4),
                  400: AppColor.primaryColor.withOpacity(0.5),
                  500: AppColor.primaryColor.withOpacity(0.6),
                  600: AppColor.primaryColor.withOpacity(0.7),
                  700: AppColor.primaryColor.withOpacity(0.8),
                  800: AppColor.primaryColor.withOpacity(0.9),
                  900: AppColor.primaryColor,
                },
              ),
              textTheme: TextTheme(
                displayLarge: AppTextStyles.headlinePoppins,
                displayMedium: AppTextStyles.bodyPoppins,
                displaySmall: AppTextStyles.captionPoppins,
                // Add all other text styles as needed
              ),
              scaffoldBackgroundColor: AppColor.scaffoldBackgroundColor,
              primaryColor: AppColor.primaryColor,
            ),
            initialRoute: RouteNames.splash,
            getPages: AppRoutes.routes,
          ),
        );
      },
    );
  }
}
