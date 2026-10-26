import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
  }
}
