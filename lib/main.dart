import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import 'package:virtual_career/config/routes/routes.dart';

import 'core/theme/app_colors.dart';
import 'di.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DI.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child){
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          theme: ThemeData(
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
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp, fontFamily: GoogleFonts.poppins().fontFamily),
          ),
          initialRoute: RouteNames.splash,
          getPages: AppRoutes.routes,
        );
      },
    );
  }
}
