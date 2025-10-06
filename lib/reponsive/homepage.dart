import 'package:flutter/material.dart';
import 'package:games/reponsive/reponsive_widget.dart';
import 'package:games/reponsive/widgets/drawer_widget.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWidget.isMobile(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Tour Responsive UI"),
        backgroundColor: Colors.greenAccent,
      ),
      body: ResponsiveWidget(
        mobile: buildMobile(),
        tablet: buildTablet(),
        desktop: buildDesktop(),
      ),
      drawer: isMobile ? Drawer(child: DrawerWidget()) : null,
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
