import 'package:flutter/cupertino.dart';

import 'core/managers/cache_manager.dart';

class DI{
  static void init(){

    // cache manager
    SharedPrefs.instance.init();



    // Get.lazyPut<AuthRepo>(() => AuthRepo(), fenix: true);
    // Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    // Get.lazyPut<LocalStorage>(() => LocalStorage(), fenix: true,);
    // debugPrint("DI initialized");
  }
}