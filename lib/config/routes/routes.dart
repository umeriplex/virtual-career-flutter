import 'package:get/get.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import 'package:virtual_career/features/auth/view/sign_in_view.dart';
import 'package:virtual_career/features/auth/view/sign_up_view.dart';
import 'package:virtual_career/features/profile/view/profile_view.dart';
import '../../features/auth/view/forgot_password_view.dart';
import '../../features/mock_interview/model/interview_model.dart';
import '../../features/mock_interview/view/interview.dart';
import '../../features/mock_interview/view/interview_level.dart';
import '../../features/mock_interview/view/mock_interview.dart';
import '../../features/mock_interview/view/result_view.dart';
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

    GetPage(
      name: RouteNames.mockInterview,
      page: () => const MockInterview(),
    ),

    GetPage(
      name: RouteNames.profile,
      page: () => ProfileView(),
    ),

    GetPage(
      name: RouteNames.interviewLevel,
      page: () {
        final icon = Get.arguments['icon'] as String;
        final name = Get.arguments['name'] as String;
        return InterviewLevels(
          name: name,
          icon: icon,
        );
      },
    ),

    GetPage(
      name: RouteNames.interviewScreen,
      page: () {
        final category = Get.arguments['category'] as InterviewCategory;
        final level = Get.arguments['level'] as InterviewLevel;
        return InterviewScreen(
          category: category,
          level: level,
        );
      },
    ),

    GetPage(
      name: RouteNames.interviewResult,
      page: () {
        final category = Get.arguments['category'] as InterviewCategory;
        final level = Get.arguments['level'] as InterviewLevel;
        final result = Get.arguments['result'] as InterviewResult;
        return ResultScreen(
          category: category,
          level: level,
          result: result,
        );
      },
    ),


  ];
}