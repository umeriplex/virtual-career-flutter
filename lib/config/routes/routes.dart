import 'package:get/get.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import 'package:virtual_career/features/auth/view/sign_in_view.dart';
import 'package:virtual_career/features/auth/view/sign_up_view.dart';
import 'package:virtual_career/features/events/view/create_event.dart';
import 'package:virtual_career/features/jobs/view/create_job_view.dart';
import 'package:virtual_career/features/jobs/view/edit_job_view.dart';
import 'package:virtual_career/features/profile/view/profile_view.dart';
 import 'package:virtual_career/features/profile/view/user_profile_view.dart';
import '../../features/events/view/edit_event_view.dart';
import '../../features/jobs/view/job_application_form_view.dart';
import '../../features/jobs/view/job_applications_list_view.dart';
import '../../features/events/view/event_registration_form_view.dart';
import '../../features/events/view/event_registrations_list_view.dart';
import '../../features/auth/view/forgot_password_view.dart';
import '../../features/connections/view/connection_list_view.dart';
import '../../features/events/view/event_details.dart';
import '../../features/jobs/view/job_details_page.dart';
import '../../features/mock_interview/model/interview_model.dart';
import '../../features/mock_interview/view/interview.dart';
import '../../features/mock_interview/view/interview_level.dart';
import '../../features/mock_interview/view/mock_interview.dart';
import '../../features/mock_interview/view/result_view.dart';
import '../../features/nav/view/nav_view.dart';
import '../../features/notifications/view/noti_view.dart';
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

    GetPage(
      name: RouteNames.createJob,
      page: () {
        return CreateJobView();
      },
    ),

    GetPage(
      name: RouteNames.jobDetails,
      page: () {
        return JobDetailsView();
      },
    ),

    GetPage(
      name: RouteNames.createEvent,
      page: () {
        return CreateEventPage();
      },
    ),

    GetPage(
      name: RouteNames.eventDetails,
      page: () {
        return EventDetailsView();
      },
    ),



    GetPage(
      name: RouteNames.connections,
      page: () => const ConnectionsView(),
    ),
    GetPage(
      name: RouteNames.userProfile,
      page: () => const UserProfileView(),
    ),
    GetPage(
      name: RouteNames.notifications,
      page: () => const NotificationsView(),
    ),
    GetPage(
      name: RouteNames.editJob,
      page: () => const EditJobView(),
    ),
    GetPage(
      name: RouteNames.editEvent,
      page: () => const EditEventView(),
    ),
    GetPage(
      name: RouteNames.jobApplication,
      page: () => const JobApplicationFormView(),
    ),
    GetPage(
      name: RouteNames.jobApplicationsList,
      page: () => const JobApplicationsListView(),
    ),
    GetPage(
      name: RouteNames.eventRegistration,
      page: () => const EventRegistrationFormView(),
    ),
    GetPage(
      name: RouteNames.eventRegistrationsList,
      page: () => const EventRegistrationsListView(),
    ),







  ];
}