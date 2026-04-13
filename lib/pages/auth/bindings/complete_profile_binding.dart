// lib/pages/auth/bindings/complete_profile_binding.dart
import 'package:get/get.dart';
import '../controllers/complete_profile_controller.dart';

class CompleteProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompleteProfileController>(
      () => CompleteProfileController(),
    );
  }
}
