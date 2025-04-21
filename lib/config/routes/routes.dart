import 'package:get/get.dart';
import 'package:virtual_career/config/routes/route_name.dart';

import '../../features/splash/view/splash_view.dart';

class AppRoutes {
  static List<GetPage> routes = [
    GetPage(
      name: RouteNames.splash,
      page: () => const SplashView(),
    ),
  ];
}