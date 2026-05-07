import 'package:get/get.dart';

class LoadingController extends GetxController {
  final RxBool isLoading = false.obs;

  void start() => isLoading.value = true;
  void stop() => isLoading.value = false;

  Future<T> wrap<T>(Future<T> future) async {
    start();
    try {
      return await future;
    } finally {
      stop();
    }
  }
}

