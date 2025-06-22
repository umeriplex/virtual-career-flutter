import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:virtual_career/features/auth/controller/auth_controller.dart';
import '../../../config/routes/route_name.dart';
import '../../../generated/assets.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    initSplash();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(const AssetImage(Assets.imagesTextedLogo), context);
    });
  }

  initSplash () async {
    var isLoggedIn = await _authController.isLoggedIn();
    if(isLoggedIn){
      _authController.fetchCurrentUser();
      await Future.delayed(const Duration(seconds: 2));
      Get.offNamed(RouteNames.navBar);
    }
    else{
      await Future.delayed(const Duration(seconds: 2));
      Get.offNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          Assets.assetsAppIcon,
          width: 200.r,
          height: 200.r,
        ),
      ),
    );
  }
}
