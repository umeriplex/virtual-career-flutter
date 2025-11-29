import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:virtual_career/features/auth/repository/auth_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:virtual_career/features/chat_bot/controller/chatbot_controller.dart';
import 'package:virtual_career/features/splash/controller/nav_controller.dart';
import 'core/managers/cache_manager.dart';
import 'features/auth/controller/auth_controller.dart';
import 'features/connections/controller/connection_controller.dart';
import 'features/connections/repository/connection_repo.dart';
import 'features/events/controller/event_controller.dart';
import 'features/events/repository/event_repo.dart';
import 'features/jobs/controller/job_controller.dart';
import 'features/jobs/repository/job_repo.dart';
import 'features/notifications/controller/noti_controller.dart';
import 'features/notifications/repository/noti_repo.dart';
import 'features/resume_builder/controller/resumer_builder_controller.dart';
import 'features/resume_builder/repository/resume_builder_repository.dart';
import 'firebase_options.dart';

class DI{
  Future<void> init() async {

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    //Firebase Auth
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    // Firebase Firestore
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    // Firebase
    FirebaseStorage storageReference = FirebaseStorage.instance;

    // Firebase Storage
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;

    // cache manager
    SharedPrefs.instance.init();

    // init repositories
    await _initRepositories(firebaseFirestore, firebaseAuth,firebaseStorage);

    // init controllers
    await _initControllers();

  }

  Future<void> _initRepositories (FirebaseFirestore fs, FirebaseAuth fa, FirebaseStorage storage) async {
    Get.lazyPut(() => AuthRepository(fs, fa), fenix: true);
    Get.lazyPut(() => ResumeBuilderRepository(fs, storage), fenix: true);
    Get.lazyPut(() => JobRepository(fs), fenix: true);
    Get.lazyPut(() => EventRepository(fs), fenix: true);
    Get.lazyPut(() => ConnectionRepository(fs), fenix: true);
    Get.lazyPut(() => NotificationRepository(fs), fenix: true);
  }

  Future<void> _initControllers () async {
    Get.put(NavController(), permanent: true);
    Get.put(AuthController(Get.find()), permanent: true);
    Get.lazyPut(() => ResumeBuilderController(Get.find()), fenix: true);
    Get.lazyPut(() => ChatBotController(), fenix: true);
    Get.lazyPut(() => JobController(Get.find<JobRepository>()), fenix: true);
    Get.lazyPut(() => EventController(Get.find<EventRepository>()), fenix: true);
    Get.lazyPut(() => ConnectionController(Get.find<ConnectionRepository>()), fenix: true);
    Get.lazyPut(() => NotificationController(Get.find<NotificationRepository>()), fenix: true);

  }
}