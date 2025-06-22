import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
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
import '../../mock_interview/model/interview_model.dart';
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
      final user = authController.user;
      if (user == null) {
        return const Scaffold(body: Center(child: CupertinoActivityIndicator()));
      }
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
                            InkWell(
                              onTap: () {
                                Get.toNamed(RouteNames.profile);
                              },
                              child: Container(
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
                            ),
                            InkWell(
                              // onTap: () async {
                              //   var success = await authController.signOut();
                              //   if (success) {
                              //     SharedPrefs.instance.removeUser();
                              //     Get.offAllNamed(RouteNames.login);
                              //   }
                              // },
                              onTap: (){},
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
                          user.fullName,
                          style: AppTextStyles.headlineOpenSans.copyWith(
                            color: Colors.white,
                            fontSize: 24.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: responsive.responsivePadding(18.w, 10.h, 18.w, 20.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Featured Tool & Resources",
                        style: AppTextStyles.subHeadlinePoppins,
                      ),
                      5.verticalSpace,
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
                            onTap: () => Get.toNamed(RouteNames.mockInterview),
                          ),

                          _buildFirstRowItem(
                            title: "Explore Events",
                            image: Assets.imagesEvents,
                            onTap: () {
                              //Get.offNamed(RouteNames.interviewResult, arguments: { "category" : dummyCategory, "level" : dummyLevel, "result" : dummyResult });
                            },
                          ),

                        ],
                      ),

                      Obx((){
                        if(controller.resumes.isNotEmpty){
                          List<UserResume> resumes = controller.resumes;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              15.verticalSpace,
                              Text(
                                "My Resumes",
                                style: AppTextStyles.subHeadlinePoppins,
                              ),
                              5.verticalSpace,
                              SizedBox(
                                width: double.maxFinite,
                                height: 250.h,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(
                                      resumes.length, (index) => GestureDetector(
                                      onTap: () async {
                                        Get.to(() => ResumeViewer(pdfUrl: resumes[index].pdfUrl, title: resumes[index].title,));
                                      },
                                      onLongPress: () async {

                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.warning,
                                          animType: AnimType.scale,
                                          title: 'Delete Resume',
                                          desc: 'Are you sure you want to delete this resume?',
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () {
                                            controller.deleteUserResume(resumes[index].id);
                                          },
                                        ).show();



                                      },
                                      child: Container(
                                          clipBehavior: Clip.antiAlias,
                                          height: 240.h,
                                          margin: EdgeInsets.only(right: 14.w),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColor.black20.withValues(alpha: 0.05),
                                                offset: const Offset(0, 2),
                                                blurRadius: 4,
                                              ),
                                              BoxShadow(
                                                color: AppColor.black20.withValues(alpha: 0.05),
                                                offset: const Offset(2, 0),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: UltimateCachedNetworkImage(imageUrl: resumes[index].thumbnailUrl, fit: BoxFit.contain,)
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

// Dummy InterviewCategory
final InterviewCategory dummyCategory = InterviewCategory(
  id: 'software_dev',
  name: 'Software Development',
  icon: Assets.imagesCivil,
);

// Dummy InterviewLevel
final InterviewLevel dummyLevel = InterviewLevel(
  id: 'intermediate',
  name: 'Intermediate',
  questionCount: 25,
);

// Dummy InterviewResult with realistic data
final InterviewResult dummyResult = InterviewResult(
  overallScore: 82.5,
  strengths: [
    'Strong problem-solving skills',
    'Excellent communication of technical concepts',
    'Good understanding of algorithms',
  ],
  improvements: [
    'Could improve knowledge of design patterns',
    'Needs more experience with cloud architecture',
    'Should practice more system design questions',
  ],
  questions: [
    InterviewQuestion(
      question: "Explain the difference between async and await in Dart",
      userAnswer: "Async marks a function as asynchronous, and await pauses execution until the Future completes",
      idealAnswer: "Async marks a function to return a Future and enables await. Await pauses execution until the Future completes, without blocking the thread.",
      score: 90,
    ),
    InterviewQuestion(
      question: "What are the main SOLID principles?",
      userAnswer: "Single responsibility, Open-closed, and Liskov substitution",
      idealAnswer: "Single responsibility, Open-closed, Liskov substitution, Interface segregation, and Dependency inversion",
      score: 75,
    ),
    InterviewQuestion(
      question: "How would you optimize a slow database query?",
      userAnswer: "I would add indexes to the columns being queried",
      idealAnswer: "Add indexes, analyze query execution plan, optimize joins, consider denormalization, and implement caching where appropriate",
      score: 80,
    ),
  ],
  summary: "The candidate demonstrated strong technical knowledge particularly in core programming concepts. "
      "They communicated clearly and showed good problem-solving approaches. "
      "Areas for improvement include deeper knowledge of system design patterns and cloud technologies. "
      "With some focused study in these areas, they would be ready for senior-level interviews.",
  completedAt: DateTime.now(),
);
