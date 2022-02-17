import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';

getColor(int index, int rowCount, bool solved) {
  if (solved) {
    return Colors.green;
  }

  if (rowCount * rowCount * 3 <= Colors.primaries.length) {
    return Colors.primaries[index * 3];
  } else if (rowCount * rowCount * 2 <= Colors.primaries.length) {
    return Colors.primaries[index * 2];
  } else if (rowCount * rowCount <= Colors.primaries.length) {
    return Colors.primaries[index];
  } else if (index < Colors.primaries.length) {
    return Colors.primaries[index];
  } else {
    return Colors.primaries[index % Colors.primaries.length];
  }
}

double getTileWidth(int rowCount) {
  if (Get.size.aspectRatio < 1) {
    if (Get.context != null) {
      return (ResponsiveWrapper.of(Get.context!).scaledWidth * 0.75) / rowCount;
    } else {
      return (Get.size.width * 0.75) / rowCount;
    }
  } else {
    if (Get.context != null) {
      return (ResponsiveWrapper.of(Get.context!).scaledHeight * 0.6) / rowCount;
    } else {
      return (Get.size.height * 0.6) / rowCount;
    }
  }
}
