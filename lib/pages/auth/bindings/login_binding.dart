// login_binding.dart
import 'package:e_pasar/pages/auth/controllers/login_controller.dart';
import 'package:e_pasar/pages/auth/controllers/register_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
  }
}

// register_binding.dart
class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController(), fenix: true);
  }
}
