import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxnInt selectedContactId = RxnInt();

  void selectContact(int? id) => selectedContactId.value = id;
}
