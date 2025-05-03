import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:virtual_career/features/jobs/view/jobs_view.dart';
import 'package:virtual_career/features/resume_builder/view/resume_builder.dart';
import 'package:virtual_career/features/splash/controller/nav_controller.dart';

import '../../../generated/assets.dart';
import '../../chat_bot/view/chatbot_view.dart';
import '../../home/view/home_view.dart';

class NavView extends StatelessWidget {
  const NavView({super.key});
  @override
  Widget build(BuildContext context) {
    final NavController navController = Get.find<NavController>();
    return Obx(() {
        return Scaffold(
          body: _buildScreens(navController),
          bottomNavigationBar: _buildBottomNavigationBar(navController),
        );
      }
    );
  }

  _buildBottomNavigationBar(NavController navController) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: navController.currentIndex.value,
      onTap: (index) {
        navController.changeIndex(index);
      },
      items: [
        BottomNavigationBarItem(
          icon: navController.currentIndex.value == 0
              ? Image.asset(Assets.imagesNavHome, width: 24.w, height: 24.w, color: Colors.black87,)
              : Image.asset(Assets.imagesNavHome, width: 24.w, height: 24.w, color: Colors.black38,),
          label: '',
        ),

        BottomNavigationBarItem(
          icon: navController.currentIndex.value == 1
              ? Image.asset(Assets.imagesNavResume, width: 24.w, height: 24.w, color: Colors.black87,)
              : Image.asset(Assets.imagesNavResume, width: 24.w, height: 24.w, color: Colors.black38,),
          label: '',
        ),

        BottomNavigationBarItem(
          icon: navController.currentIndex.value == 2
              ? Image.asset(Assets.imagesNavJobs, width: 24.w, height: 24.w, color: Colors.black87,)
              : Image.asset(Assets.imagesNavJobs, width: 24.w, height: 24.w, color: Colors.black38,),
          label: '',
        ),

        BottomNavigationBarItem(
          icon: navController.currentIndex.value == 3
              ? Image.asset(Assets.imagesNavChatbot, width: 24.w, height: 24.w, color: Colors.black87,)
              : Image.asset(Assets.imagesNavChatbot, width: 24.w, height: 24.w, color: Colors.black38,),
          label: '',
        ),
      ],
    );
  }

  _buildScreens(NavController navController) {
    return IndexedStack(
      index: navController.currentIndex.value,
      children:  [
        const HomeView(),
        ResumeBuilderView(),
        const JobView(),
        const ChatBotView(),
      ],
    );
  }
}
