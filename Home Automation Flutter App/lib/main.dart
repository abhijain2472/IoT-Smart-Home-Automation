import 'package:flutter/material.dart';
import 'package:homeautomation/screens/bill_estimation.dart';
import 'package:homeautomation/screens/change_key.dart';
import 'package:homeautomation/screens/forgot_key_screen.dart';
import 'package:homeautomation/screens/home_screen.dart';
import 'package:homeautomation/screens/login_screen.dart';
import 'package:homeautomation/screens/power_usage.dart';
import 'package:homeautomation/screens/total_usage.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:connectivity/connectivity.dart';

ProgressDialog pr;

void main() {

  runApp(MyApp());
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      if(pr.isShowing()){
        print('internet Connected !');
        pr.hide();
      }
    } else {
      print('no internet');
      pr.show();
    }
  });
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(message: 'No internet ‼️\nPlease try again later',textAlign: TextAlign.center,);
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light
      ),
      debugShowCheckedModeBanner: false,
      home:
      LoginScreen(),

      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        HomeScreen.routeName: (context) => HomeScreen(),
        ChangeKey.routeName: (context) => ChangeKey(),
        PowerUsage.routeName: (context) => PowerUsage(),
        ForgotKeyScreen.routeName: (context) => ForgotKeyScreen(),
        BillEstimation.routeName: (context) => BillEstimation(),
        TotalUsage.routeName: (context) => TotalUsage(),
      },
    );

  }
}
