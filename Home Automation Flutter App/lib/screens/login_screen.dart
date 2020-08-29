import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homeautomation/screens/forgot_key_screen.dart';
import 'package:homeautomation/screens/home_screen.dart';
import 'package:progress_dialog/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  ProgressDialog pr;
  var _hideText = true;
  final _keyController = TextEditingController();
  String _webKey;
  String _mobileNumber;
  final DatabaseReference _database = FirebaseDatabase().reference();
  final _formKey = GlobalKey<FormState>();

  void _submitData() {
    final isValidate = _formKey.currentState.validate();
    if (!isValidate) {
      return;
    }
    _formKey.currentState.save();
    if (_webKey == _keyController.text) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } else {
      return;
    }
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

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,
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
          _webKey = (data['security']['key']).toString();
          _mobileNumber = (data['contact']['mobile']).toString();
        }
        return WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
            body: _webKey==null
                ? Center(
                    child: SpinKitCircle(size: 60, color: Colors.lightBlue),
                  )
                : GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },
                    child: Center(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 130,
                                width: 130,
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                'Welcome to Smart Home Automation',
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 60,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 40),
                                child: TextFormField(
                                  controller: _keyController,
                                  style: TextStyle(fontSize: 20),
                                  decoration: InputDecoration(
                                    hintText: 'Enter Secret Key',
                                    icon: Icon(
                                      Icons.vpn_key,
                                      size: 25,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _hideText = !_hideText;
                                        });
                                      },
                                      icon: FaIcon(
                                        _hideText
                                            ? FontAwesomeIcons.eye
                                            : FontAwesomeIcons.eyeSlash,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  obscureText: _hideText,
                                  keyboardType: TextInputType.number,
                                  onFieldSubmitted: (_) => _submitData,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter a key !';
                                    }
                                    if (value.length > 6 || value.length < 6) {
                                      return 'Key must be 6 digit long only !';
                                    }
                                    if (value != _webKey) {
                                      return 'Key is wrong';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                child: Center(
                                  child: RaisedButton(
                                    color: Colors.lightBlue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.0)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 60),
                                      child: Text(
                                        'Connect',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    onPressed: _submitData,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      ForgotKeyScreen.routeName,
                                      arguments: _mobileNumber);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    'Forgot Secret Key ?',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
