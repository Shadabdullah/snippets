import 'package:flutter/material.dart';
import 'package:games/reponsive/Reponsive_widget.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      mobile: buildMobile(),
      tablet: buildTablet(),
      desktop: buildDesktop(),
    );
  }

  Widget buildMobile() => Container(
    color: Colors.red,
    child: Center(child: Text("MOBILE")),
  );

  Widget buildTablet() => Container(
    color: Colors.green,
    child: Center(child: Text("TABLET")),
  );

  Widget buildDesktop() => Container(
    color: Colors.orange,
    child: Center(child: Text("DESKTOP")),
  );
}
