import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/components/custom_text_field.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/features/auth/controller/auth_controller.dart';
import '../../../core/components/custom_button.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../generated/assets.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  TextEditingController emailController = TextEditingController();
  final _controller = Get.find<AuthController>();



  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: responsive.deviceHeight(percent: 0.25),
              width: responsive.deviceWidth(),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                image: const DecorationImage(
                  image: AssetImage(Assets.imagesLoginTexture),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Reset Password",
                          style: AppTextStyles.headlineOpenSans.copyWith(
                            color: Colors.white,
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        10.verticalSpace,
                        Padding(
                          padding: responsive.responsivePadding(12, 0, 12, 0),
                          child: Text(
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyPoppins.copyWith(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10.h,
                    left: responsive.deviceWidth(percent: 0.05),
                    right: 0,
                    child: InkWell(
                      onTap: () => Get.back(),
                      child: FaIcon(
                      FontAwesomeIcons.arrowLeft,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    ),
                  ),
                ],
              ),
            ),

            30.verticalSpace,
            Padding(
              padding: responsive.responsivePadding(18, 20, 18, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Email',
                    style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.w600),
                  ),
                  4.verticalSpace,
                  CustomTextField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    controller: emailController,
                    hintText: "Enter your email",
                  ),
                  20.verticalSpace,

                  20.verticalSpace,
                  Obx(() {
                    return CustomButton(
                      isLoading: _controller.isLoading.value,
                      title: "Send Reset Link",
                      onPressed: () async {
                        _handleForgotPassword();
                      },
                    );
                  }),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _handleForgotPassword() async {
    if (emailController.text.isEmpty) {
      showErrorMessage("Please enter your email");
      return;
    }
    await _controller.forgotPassword(emailController.text.trim());
  }
}
