import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import 'package:virtual_career/core/components/custom_image_view.dart';
import 'package:virtual_career/core/managers/cache_manager.dart';
import 'package:virtual_career/core/theme/app_colors.dart';
import 'package:virtual_career/features/auth/controller/auth_controller.dart';
import 'package:virtual_career/features/splash/controller/nav_controller.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../generated/assets.dart';
import '../../resume_builder/controller/resumer_builder_controller.dart';
import '../../resume_builder/model/user_resume.dart';
import '../../resume_builder/view/resume_viewer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  final AuthController authController = Get.find<AuthController>();
  final ResumeBuilderController controller = Get.find<ResumeBuilderController>();


  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return Obx(() {
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
                  height: responsive.deviceHeight(percent: 0.24),
                  width: responsive.deviceWidth(),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    image: const DecorationImage(
                      image: AssetImage(Assets.imagesHomeTexture),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.r),
                      bottomRight: Radius.circular(30.r),
                    ),
                  ),
                  child: Padding(
                    padding: responsive.responsivePadding(18.w, MediaQuery.of(context).padding.top + 6.h, 18.h, 10.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: AppColor.buttonColor,
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.user,
                                  color: Colors.black,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                var success = await authController.signOut();
                                if (success) {
                                  SharedPrefs.instance.removeUser();
                                  Get.offAllNamed(RouteNames.login);
                                }
                              },
                              child: Image.asset(Assets.imagesNoti, width: 40.w, height: 40.w,),
                            ),
                          ],
                        ),


                        15.verticalSpace,
                        Text(
                          "Hello",
                          style: AppTextStyles.bodyOpenSans.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          authController.user?.fullName ?? "Unknown",
                          style: AppTextStyles.headlineOpenSans.copyWith(
                            color: Colors.white,
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                10.verticalSpace,
                Padding(
                  padding: responsive.responsivePadding(18.w, 10.h, 18.w, 20.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Featured Tool & Resources",
                        style: AppTextStyles.headlineOpenSans.copyWith(
                        ),
                      ),
                      10.verticalSpace,

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildFirstRowItem(
                            title: "Resume Builder",
                            image: Assets.imagesResumeBuilder,
                            onTap: () => Get.find<NavController>().currentIndex.value = 1,
                          ),

                          _buildFirstRowItem(
                            title: "Mock Interview",
                            image: Assets.imagesMockInterview,
                            onTap: () {},
                          ),

                          _buildFirstRowItem(
                            title: "Explore Events",
                            image: Assets.imagesEvents,
                            onTap: () {},
                          ),

                        ],
                      ),
                      20.verticalSpace,




                      Obx((){
                        if(controller.resumes.isNotEmpty){
                          List<UserResume> resumes = controller.resumes;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              30.verticalSpace,
                              Text(
                                "My Resumes",
                                style: AppTextStyles.headlineOpenSans,
                              ),
                              10.verticalSpace,
                              SizedBox(
                                width: double.maxFinite,
                                height: 250.h,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(
                                      resumes.length, (index) => GestureDetector(
                                      onTap: () async {
                                        Get.to(() => ResumeViewer(pdfUrl: resumes[index].pdfUrl,));
                                      },
                                      child: Container(
                                        clipBehavior: Clip.antiAlias,
                                        width: 180.w,
                                        height: 240.h,
                                        margin: EdgeInsets.only(right: 10.w),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20.r),
                                          border: Border.all(
                                            color: AppColor.white20.withValues(alpha: 0.09),
                                            width: 1.w,
                                          ),
                                        ),
                                          child: UltimateCachedNetworkImage(imageUrl: resumes[index].thumbnailUrl)

                                      ),
                                    ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }else{
                          return const SizedBox.shrink();
                        }
                      }),


                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  _buildFirstRowItem ({ required String title, required String image, required void Function() onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: AppColor.black20.withValues(alpha: 0.2),
              width: 1.w,
            ),
          ),
          padding: EdgeInsets.all(20.r),
          margin: title == "Resume Builder" ? EdgeInsets.only(right: 10.w) : title == "Explore Events" ? EdgeInsets.only(left: 10.w) : EdgeInsets.zero,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(image, width: 50.w, height: 50.w,),
                5.verticalSpace,
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleOpenSans.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
