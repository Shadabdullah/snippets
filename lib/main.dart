import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) {
        return ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          useInheritedMediaQuery: true,
          builder: (context, child) {
            ScreenUtil.configure(data: MediaQuery.of(context));
            return MaterialApp(home: const HabitTrackerDemo());
          },
        );
      },
    ),
  );
}

// }
