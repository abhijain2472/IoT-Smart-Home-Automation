import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homeautomation/widgets/main_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_apps/device_apps.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:audioplayers/audio_cache.dart';

enum _OptionsMenu {
  TermsCondition,
  AboutApp,
}

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AudioCache _player;
  ProgressDialog pr;
  final DatabaseReference _database = FirebaseDatabase().reference();
  var _smartMode;
  var _light;

  void _playSound(String name) {
    _player = AudioCache();
    _player.play('sounds/$name.mp3');
    _player.clearCache();
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(

            content: Text(
              'Do you want to exit an App ?',
            ),
            contentPadding: EdgeInsets.all(20),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("NO"),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("YES"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _switchSmartMode(int value) async {
    _playSound('smartlight');

    await _database.child('pir').update({'status': '$value'});
  }

  void _switchLed() async {
    _playSound('b');

    if (_light == 0) {
      await _database.child('ledstatus').update({'led': '1'});
    } else if (_light == 1) {
      await _database.child('ledstatus').update({'led': '0'});
    }
  }

  void _showDialogBox({String title, String message}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _player = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
      message: 'No internet ‼️\nPlease try again later',
      textAlign: TextAlign.center,
    );
    return StreamBuilder(
        stream: _database.onValue,
        builder: (context, snap) {
          if (snap.hasData &&
              !snap.hasError &&
              snap.data.snapshot.value != null) {
            Map data = snap.data.snapshot.value;
            _light = int.parse(data['ledstatus']['led']);
            _smartMode = int.parse(data['pir']['status']) == 1 ? true : false;
          }

          return WillPopScope(
            onWillPop: _onBackPressed,
            child: Scaffold(
              backgroundColor: Colors.grey,
              appBar: AppBar(
                title: Text('Home Automation'),
                actions: [
                  IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {
                        Share.share(
                          'Hey friend, I developed a small project in which you can control your appliances. You may also try it by clicking on below download link:\n\nhttps://iottest-7498a.firebaseapp.com/download/Home%20Automation.apk',
                        );
                      }),
                  PopupMenuButton(
                    onSelected: (_OptionsMenu selectedValue) {
                      if (selectedValue == _OptionsMenu.TermsCondition) {
                        _showDialogBox(
                          title: 'Terms & Conditions',
                          message:
                              '• Need internet connection.\n\n• Need power to the circuitry.\n\n• You need to install Google Assistant to use voice control.\n\n• Must having Wi-Fi connection nearby circuit with following credentials:\n\nSSID - internet\nPassword - 0123456789',
                        );
                        //terms & condition logic
                      } else {
                        _showDialogBox(
                          title: 'About This Application',
                          message:
                              'This Application provides various useful features of home appliance such as, how much units are currently using by system, which device is consuming highest unit, Estimation of electricity bill and user can also turn On and Off respective devices from anywhere in the world.',
                        );
                        //about app
                      }
                    },
                    icon: Icon(
                      Icons.more_vert,
                    ),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        child: Text('Terms & Conditions'),
                        value: _OptionsMenu.TermsCondition,
                      ),
                      PopupMenuItem(
                        child: Text('About This Application'),
                        value: _OptionsMenu.AboutApp,
                      ),
                    ],
                  ),
                ],
              ),
              drawer: MainDrawer(),
              body: (_light == null || _smartMode == null)
                  ? Center(
                      child: SpinKitCircle(size: 60, color: Colors.white),
                    )
                  : Column(
                      children: [
                        Container(
                          color: Color.fromRGBO(19, 144, 179, 0.6),
                          padding: const EdgeInsets.only(left: 10),
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Smart Light Mode',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Spacer(),
                              Switch(
                                value: _smartMode,
                                onChanged: (value) {
                                  if (value) {
                                    _switchSmartMode(1);
                                  } else {
                                    _switchSmartMode(0);
                                  }
                                },
                                inactiveThumbColor: Colors.red,
                                activeColor: Colors.lightGreen,
                                inactiveTrackColor:
                                    Color.fromRGBO(255, 0, 0, 0.3),
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.info,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    _showDialogBox(
                                      title: 'Smart Light Mode',
                                      message:
                                          'This is Smart Light Mode which is based on PIR Motion Sensor. When this mode is ON , PIR Sensor will be activated.\nWhenever any living moving object detects, lights gets turned ON. When you go out of the range of PIR Sensor, lights will turned OFF.\n\nNote : If there is no movement for 10-11 seconds lights get turned OFF automatically. The detection range of sensor is approx 5-7 meter and angle of detection is 180 degree.',
                                    );
                                  })
                            ],
                          ),
                        ),
                        Container(
                          child: _smartMode
                              ? Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    color: Colors.white,
                                    child:
                                        Image.asset('assets/images/bulb.gif'),
                                  ),
                                )
                              : Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _switchLed();
                                        },
                                        child: Image.asset(
                                          _light == 0
                                              ? 'assets/images/ON.png'
                                              : 'assets/images/OFF.png',
                                          height: 220,
                                          width: 220,
                                        ),
                                      ),
                                      Text(
                                        _light == 0
                                            ? 'Light is OFF'
                                            : 'Light is ON',
                                        style: GoogleFonts.alata(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amberAccent),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      GestureDetector(
                                          onTap: _openGoggleAssistant,
                                          child: Image.asset(
                                            'assets/images/mic.png',
                                            height: 55,
                                            width: 55,
                                          )),

                                    ],
                                  ),
                                ),
                        )
                      ],
                    ),
            ),
          );
        });
  }

  Future<void> _openGoggleAssistant() async {
    try {
      bool isInstalled = await DeviceApps.isAppInstalled(
          'com.google.android.apps.googleassistant');
      if (isInstalled) {
        _playSound('g');
        DeviceApps.openApp('com.google.android.apps.googleassistant');
      } else {
        String url =
            'https://play.google.com/store/apps/details?id=com.google.android.apps.googleassistant&hl=en';
        if (await canLaunch(url))
          await launch(url);
        else
          throw 'Could not launch $url';
      }
    } on Exception catch (e) {
      print(e);
    }
  }
}
