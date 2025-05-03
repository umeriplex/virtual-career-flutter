import 'package:get/get.dart';

class NavController extends GetxController{

  RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

}