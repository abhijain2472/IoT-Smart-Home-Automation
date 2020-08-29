import 'package:flutter/material.dart';
import 'package:homeautomation/screens/change_key.dart';
import 'package:homeautomation/screens/home_screen.dart';
import 'package:homeautomation/screens/login_screen.dart';
import 'package:homeautomation/screens/power_usage.dart';
class MainDrawer extends StatelessWidget {
  final TextStyle itemStyle =
      TextStyle(fontWeight: FontWeight.bold, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            child: Image.asset(
              'assets/images/side_header.jpg',
              fit: BoxFit.fitHeight,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: Colors.black87,
            ),
            title: Text('Home', style: itemStyle),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(HomeScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.vpn_key,
              color: Colors.black87,
            ),
            title: Text(
              'Change Key',
              style: itemStyle,
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(ChangeKey.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.av_timer,
              color: Colors.black87,
            ),
            title: Text(
              'Power Usage',
              style: itemStyle,
            ),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(PowerUsage.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.black87,
            ),
            title: Text(
              'Logout',
              style: itemStyle,
            ),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(LoginScreen.routeName);
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
