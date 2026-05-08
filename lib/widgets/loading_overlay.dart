import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/utils/loading_controller.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, required this.child, this.controllerTag});

  final Widget child;
  final String? controllerTag;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoadingController>(tag: controllerTag);

    return Stack(
      children: <Widget>[
        child,
        Obx(() {
          if (!controller.isLoading.value) return const SizedBox.shrink();

          return Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
