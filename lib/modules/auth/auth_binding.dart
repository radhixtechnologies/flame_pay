import 'package:get/get.dart';
import 'controllers/login_controller.dart';
import 'controllers/otp_controller.dart';
import 'controllers/registration_controller.dart';
import 'controllers/mpin_setup_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(() => OtpController());
  }
}

class RegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegistrationController>(() => RegistrationController());
  }
}

class MpinSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MpinSetupController>(() => MpinSetupController());
  }
}
