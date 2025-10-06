import 'package:flutter/material.dart';
import 'package:games/reponsive/data/states.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: allStates.length + 1,
      itemBuilder: (context, index) {
        return index == 0 ? buildHeader() : drawerItem(index);
      },
    );
  }

  Widget buildHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: ExactAssetImage("images/swat.jpg"),
        ),
      ),
      child: Container(
        alignment: AlignmentDirectional.bottomStart,
        child: Text(
          "Pakistan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget drawerItem(int index) {
    return ListTile(
      leading: Icon(Icons.location_city),
      title: Text(allStates[index - 1]),
    );
  }
}
