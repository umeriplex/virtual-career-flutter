import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import 'package:virtual_career/core/theme/app_colors.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../generated/assets.dart';
import '../model/interview_model.dart';

class InterviewLevels extends StatelessWidget {
  final String icon;
  final String name;
  const InterviewLevels({super.key, required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
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
                child: Row(
                  children: [
                    Container(
                      width: 140.w,
                      height: 80.w,
                      padding: responsive.responsivePadding(12.w, 10.h, 12.w, 10.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Center(
                        child: Image.asset(icon, width: 70.w, height: 70.w,),
                      ),
                    ),
                    10.horizontalSpace,
                    Text(
                      name,
                      style: AppTextStyles.titleOpenSans,
                    ),
                  ],
                ),
              ),

              20.verticalSpace,
              Animate(
                effects: const [SlideEffect(
                    begin: Offset(0.0, -0.5),
                    duration: Duration(seconds: 1),
                  ), FadeEffect(duration: Duration(seconds: 1))],
                child: const Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla ac purus et eros luctus facilisis a ut lectus. Aenean ac fringilla justo. Sed vel ipsum pulvinar, semper risus eu, ullamcorper odio. Phasellus sodales est nec maximus commodo."),
              ),

              20.verticalSpace,
              Animate(
                effects: const [SlideEffect(
                  begin: Offset(-0.5, 0.0),
                  duration: Duration(seconds: 1),
                ), FadeEffect(duration: Duration(seconds: 1))],
                child: Container(
                  padding: responsive.responsivePadding(10.w, 10.h, 10.w, 20.h),
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Select Level of Interview", style: AppTextStyles.titleOpenSans,),

                      30.verticalSpace,
                      _buildItem(responsive, icon: Assets.imagesBeginner, name: name, level: "Beginner", questions: 10),

                      10.verticalSpace,
                      _buildItem(responsive, icon: Assets.imagesIntermediate, name: name, level: "Intermediate", questions: 15),

                      10.verticalSpace,
                      _buildItem(responsive, icon: Assets.imagesExpert, name: name, level: "Expert", questions: 20),


                    ],
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  InkWell _buildItem(Responsive responsive, { required String name, required String icon, required String level, required int questions }) {
    return InkWell(
      onTap: () {
        InterviewCategory category = InterviewCategory(id: name, name: name, icon: icon);
        InterviewLevel interviewLevel = InterviewLevel(id: level ,name: level, questionCount: questions);
        Get.toNamed(RouteNames.interviewScreen, arguments: { "category" : category, "level" : interviewLevel });
      },
      child: Container(
        padding: responsive.responsivePadding(10.w, 10.h, 10.w, 10.h),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 50.w, height: 50.w,),
            10.horizontalSpace,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.captionPoppins.copyWith(color: AppColor.primaryColor),),
                  Text(level, style: AppTextStyles.titleOpenSans,)
                ],
              ),
            ),
            10.horizontalSpace,
            const FaIcon(
              FontAwesomeIcons.arrowRight
            ),
          ],
        ),
      ),
    );
  }
}
