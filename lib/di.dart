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
  }

  Future<void> _initControllers () async {
    Get.put(NavController(), permanent: true);
    Get.lazyPut(() => AuthController(Get.find()), fenix: true);
    Get.lazyPut(() => ResumeBuilderController(Get.find()), fenix: true);
    Get.lazyPut(() => ChatBotController(), fenix: true);
  }
}