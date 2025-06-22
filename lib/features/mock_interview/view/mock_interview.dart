import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../generated/assets.dart';
import '../../auth/controller/auth_controller.dart';

class MockInterview extends StatelessWidget {
  const MockInterview({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    final AuthController authController = Get.find<AuthController>();
    return Obx(() {
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: responsive.responsivePadding(18.w, MediaQuery.of(context).padding.top, 18.w, 10.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  InkWell(
                    onTap: () => Get.back(),
                    child: const FaIcon(
                      FontAwesomeIcons.arrowLeft
                    ),
                  ),

                  14.verticalSpace,

                  Animate(
                    effects: const [SlideEffect(
                      begin: Offset(0.0, -0.5),
                      duration: Duration(seconds: 1),
                    ), FadeEffect(duration: Duration(seconds: 1))],
                    child: Container(
                      width: double.maxFinite,
                      padding: responsive.responsivePadding(12.w, 10.h, 12.w, 10.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome ${authController.user?.fullName ?? "Buddy"}",
                            style: AppTextStyles.headlineOpenSans.copyWith(
                              color: Colors.white,
                              fontSize: 24.sp,
                            ),
                          ),
                          5.verticalSpace,
                          Text(
                            "Let's upgrade your skills",
                            style: AppTextStyles.bodyOpenSans.copyWith(color: Colors.white),
                          ),
                        ],
                      )
                    ),
                  ),

                  20.verticalSpace,
                  Animate(
                    effects: const [SlideEffect(
                      begin: Offset(-0.5, 0.0),
                      duration: Duration(seconds: 1),
                    ), FadeEffect(duration: Duration(seconds: 1))],
                    child: _buildItem(
                      responsive: responsive,
                      leftIcon: Assets.imagesSocialMedia,
                      leftText: "Advertising & Marketing",
                      rightIcon: Assets.imagesArch,
                      rightText: "Architecture & Design",
                    ),
                  ),

                  10.verticalSpace,
                  Animate(
                    effects: const [SlideEffect(
                        begin: Offset(0.5, 0.0),
                        duration: Duration(seconds: 1)
                    ), FadeEffect(duration: Duration(seconds: 1))],
                    child: _buildItem(
                      responsive: responsive,
                      leftIcon: Assets.imagesPaint,
                      leftText: "Art",
                      rightIcon: Assets.imagesTravel,
                      rightText: "Aviation",
                    ),
                  ),

                  10.verticalSpace,
                  Animate(
                    effects: const [SlideEffect(
                        begin: Offset(-0.5, 0.0),
                        duration: Duration(seconds: 1)
                    ), FadeEffect(duration: Duration(seconds: 1))],
                    child: _buildItem(
                      responsive: responsive,
                      leftIcon: Assets.imagesBriefcase,
                      leftText: "Business Management",
                      rightIcon: Assets.imagesCommunity,
                      rightText: "Communication",
                    ),
                  ),

                  10.verticalSpace,
                  Animate(
                    effects: const [SlideEffect(
                      begin: Offset(0.5, 0.0),
                      duration: Duration(seconds: 1)
                    ), FadeEffect(duration: Duration(seconds: 1))],
                    child: _buildItem(
                      responsive: responsive,
                      leftIcon: Assets.imagesNetworking,
                      leftText: "Networking",
                      rightIcon: Assets.imagesCivil,
                      rightText: "Civil & Constructions",
                    ),
                  ),




                  10.verticalSpace,
                  Animate(
                    effects: const [SlideEffect(
                        begin: Offset(0.5, 0.0),
                        duration: Duration(seconds: 1)
                    ), FadeEffect(duration: Duration(seconds: 1))],
                    child: _buildItem(
                      responsive: responsive,
                      leftIcon: Assets.imagesAnd,
                      leftText: "Android Development",
                      rightIcon: Assets.imagesIos,
                      rightText: "iOS Development",
                    ),
                  ),

                  10.verticalSpace,
                  Animate(
                    effects: const [SlideEffect(
                        begin: Offset(0.5, 0.0),
                        duration: Duration(seconds: 1)
                    ), FadeEffect(duration: Duration(seconds: 1))],
                    child: _buildItem(
                      responsive: responsive,
                      leftIcon: Assets.imagesFluttter,
                      leftText: "Flutter Development",
                      rightIcon: Assets.imagesRn,
                      rightText: "React Native",
                    ),
                  ),

                  10.verticalSpace,
                  Animate(
                    effects: const [SlideEffect(
                        begin: Offset(0.5, 0.0),
                        duration: Duration(seconds: 1)
                    ), FadeEffect(duration: Duration(seconds: 1))],
                    child: _buildItem(
                      responsive: responsive,
                      leftIcon: Assets.imagesAi,
                      leftText: "AI",
                      rightIcon: Assets.imagesDs,
                      rightText: "Data Science",
                    ),
                  ),

                  10.verticalSpace,
                  Animate(
                    effects: const [SlideEffect(
                        begin: Offset(0.5, 0.0),
                        duration: Duration(seconds: 1)
                    ), FadeEffect(duration: Duration(seconds: 1))],
                    child: _buildItem(
                      responsive: responsive,
                      leftIcon: Assets.imagesGd,
                      leftText: "Graphic Design",
                      rightIcon: Assets.imagesWd,
                      rightText: "Web Development",
                    ),
                  ),




                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildItem({
    required Responsive responsive,
    required String leftIcon,
    required String leftText,
    required String rightIcon,
    required String rightText,
  }) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => Get.toNamed(RouteNames.interviewLevel, arguments: { "icon" : leftIcon, "name" : leftText }),
            child: Container(
              padding: responsive.responsivePadding(10.w, 10.h, 10.w, 10.h),
              height: 170.h,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.black12)
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      leftIcon,
                      width: 65.w,
                      height: 65.w,
                    ),
                    6.verticalSpace,
                    Text(
                      textAlign: TextAlign.center,
                      leftText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        10.horizontalSpace,
        Expanded(
          child: InkWell(
            onTap: () => Get.toNamed(RouteNames.interviewLevel, arguments: { "icon" : rightIcon, "name" : rightText }),
            child: Container(
              padding: responsive.responsivePadding(10.w, 15.h, 10.w, 10.h),
              height: 170.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.black12),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      rightIcon,
                      width: 65.w,
                      height: 65.w,
                    ),
                    6.verticalSpace,
                    Text(
                      textAlign: TextAlign.center,
                      rightText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
