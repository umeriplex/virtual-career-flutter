import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/components/custom_text_field.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/features/auth/controller/auth_controller.dart';
import '../../../config/routes/route_name.dart';
import '../../../core/components/custom_button.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../generated/assets.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _controller = Get.find<AuthController>();
  bool isPasswordVisible = false;
  setPasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }


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
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome Back",
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
                    textInputAction: TextInputAction.next,
                    controller: emailController,
                    hintText: "Enter your email",
                  ),
                  20.verticalSpace,


                  Text(
                    'Password',
                    style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.w600),
                  ),
                  4.verticalSpace,
                  CustomTextField(
                    controller: passwordController,
                    hintText: "Enter your password",
                    isPassword: true,
                  ),

                  10.verticalSpace,
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(RouteNames.forgotPassword);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.bodyOpenSans.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  20.verticalSpace,
                  Obx(() {
                      return CustomButton(
                        isLoading: _controller.isLoading.value,
                        title: "Sign In",
                        onPressed: () async {
                          _handleSignIn();
                        },
                      );
                    }),

                  10.verticalSpace,
                  Obx(() {
                    return CustomButton(
                      isLoading: _controller.isLoading.value,
                      isSecondButton: true,
                      prefixIcon: const FaIcon(FontAwesomeIcons.google, color: Colors.black),
                      title: "Continue with Google",
                      onPressed: () async {
                        _handleSignInWithGoogle();
                      },
                    );
                  }),

                  20.verticalSpace,
                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: AppTextStyles.bodyOpenSans.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: AppTextStyles.bodyOpenSans.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed(RouteNames.register);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _handleSignIn () async {
    if (emailController.text.isEmpty) {
      showErrorMessage("Please enter your email");
    } else if (passwordController.text.isEmpty) {
      showErrorMessage("Please enter your password");
    } else {
      final user = await _controller.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      if(user != null){
        showSuccessMessage("Login successful");
        Get.offAllNamed(RouteNames.navBar);
      }
    }
  }

  _handleSignInWithGoogle () async {
    final user = await _controller.signInWithGoogle();
    if(user != null){
      showSuccessMessage("Login successful");
      Get.offAllNamed(RouteNames.navBar);
    }
  }
}
