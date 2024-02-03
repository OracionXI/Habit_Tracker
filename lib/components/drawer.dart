import 'package:flutter/material.dart';
import 'package:pinboard/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOut;
  final void Function()? onWall;

  const MyDrawer(
      {super.key,
      required this.onProfileTap,
      required this.onSignOut,
      required this.onWall});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(
          children: [
            const DrawerHeader(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 64,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            //Home
            MyListTile(
              icon: Icons.home,
              text: "H O M E",
              onTap: () {
                Navigator.pop(context);
              },
            ),

            //Profile
            MyListTile(
              icon: Icons.person,
              text: "P R O F I L E",
              onTap: onProfileTap,
            ),

            MyListTile(
              icon: Icons.post_add_outlined,
              text: "W A L L",
              onTap: onWall,
            ),
          ],
        ),

        //Logout
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: MyListTile(
            icon: Icons.logout,
            text: "L O G O U T",
            onTap: onSignOut,
          ),
        )
      ]),
    );
  }
}
