import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:games/heatmap/flutter_heatmap_calendar.dart';

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
            return const Heatmap();
          },
        );
      },
    ),
  );
}

class Heatmap extends StatelessWidget {
  const Heatmap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Card(
                child: HeatMap(
                  datasets: {
                    DateTime(2021, 1, 6): 3,
                    DateTime(2021, 1, 7): 7,
                    DateTime(2021, 1, 8): 10,
                    DateTime(2021, 1, 9): 13,
                    DateTime(2021, 1, 13): 6,
                  },
                  colorMode: ColorMode.color,
                  showColorTip: false,
                  defaultColor: Colors.grey,
                  showText: false,
                  scrollable: true,
                  colorsets: {
                    1: Colors.red,
                    3: Colors.orange,
                    5: Colors.yellow,
                    7: Colors.green,
                    9: Colors.blue,
                    11: Colors.indigo,
                    13: Colors.purple,
                  },
                  onClick: (value) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(value.toString())));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
