import 'package:get/get.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import 'package:virtual_career/features/auth/view/sign_in_view.dart';
import 'package:virtual_career/features/auth/view/sign_up_view.dart';
import '../../features/auth/view/forgot_password_view.dart';
import '../../features/nav/view/nav_view.dart';
import '../../features/splash/view/splash_view.dart';

class AppRoutes {
  static List<GetPage> routes = [
    GetPage(
      name: RouteNames.splash,
      page: () => const SplashView(),
    ),

    GetPage(
      name: RouteNames.login,
      page: () => const SignInView(),
    ),

    GetPage(
      name: RouteNames.register,
      page: () => const SignUpView(),
    ),

    GetPage(
      name: RouteNames.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),

    GetPage(
      name: RouteNames.navBar,
      page: () => const NavView(),
    ),


  ];
}