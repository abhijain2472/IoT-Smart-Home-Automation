import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:firebase_database/firebase_database.dart';


class ForgotKeyScreen extends StatefulWidget {
  static const routeName = '/forgotkey-screen';

  @override
  _ForgotKeyScreenState createState() => _ForgotKeyScreenState();
}

class _ForgotKeyScreenState extends State<ForgotKeyScreen> {
  TextEditingController _pinEditingController = TextEditingController();
  String _phoneNo;
  String _smsOTP;
  String _verificationId;
  String _errorMessage;

  FirebaseAuth _auth = FirebaseAuth.instance;
  var _showOTPBox = false;
  var _isLoading = false;
  var _showSendOTP = true;
  var _showChangeKey = false;
  var _isButtonLoading = false;

  var _newHideText = true;
  var _confirmHideText = true;
  final _newKeyController = TextEditingController();
  final _confirmKeyFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _database =
      FirebaseDatabase().reference().child('security/key');

  void _submitData() async {
    final isValidate = _formKey.currentState.validate();
    if (!isValidate) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _formKey.currentState.save();
    await _database.set(_newKeyController.text.toString());
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  void dispose() {
    _newKeyController.dispose();
    _confirmKeyFocusNode.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
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


  Future<void> _verifyPhone(BuildContext context) async {
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this._verificationId = verId;

      setState(() {
        _isButtonLoading = false;
        _showOTPBox = true;
      });

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.lightGreen,
          content: Text(
            'OTP sent successfully ✔',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      _pinEditingController.clear();
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this._phoneNo,
          codeAutoRetrievalTimeout: (String verId) {
            this._verificationId = verId;
          },
          codeSent: smsOTPSent,
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
            _signIn(phoneAuthCredential);

          },
          verificationFailed: (AuthException exception) {
            setState(() {
              _isButtonLoading = false;
              _showOTPBox = false;
            });
            _showErrorDialog(
                'You can not receive new OTP now because of too many attempts 😬. Please try again letter.');
            _pinEditingController.clear();
            print('${exception.message}');
          });
    } catch (e) {
      handleError(e);
    }
  }

  _signIn([AuthCredential phoneAuthCredential]) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final AuthCredential credential = phoneAuthCredential ?? PhoneAuthProvider.getCredential(
        verificationId: _verificationId,
        smsCode: _smsOTP,
      );

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      if (user != null) {
        print('Successfully Verified');
        setState(() {
          _isLoading = false;
          _showSendOTP = false;
          _showChangeKey = true;
          _showOTPBox = false;
        });
      }
    } catch (e) {
      handleError(e);
    }
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        _showErrorDialog('You entered a wrong OTP');
        print('Wrong OTP');
        break;

      case 'ERROR_SESSION_EXPIRED':
        _showErrorDialog(
            'The sms code has expired. Please re-send the verification code to try again.');
        print(
            'The sms code has expired. Please re-send the verification code to try again.');
        break;
      default:
        _showErrorDialog('Something went wrong 😬. Please try again letter.');
        print('default');
        break;
    }
    setState(() {
      _isLoading = false;
      _pinEditingController.clear();
    });
  }

  void _verifyOTP() {
    this._smsOTP = _pinEditingController.text;
    _signIn();
  }


  @override
  Widget build(BuildContext context) {

    _phoneNo = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: _isLoading
          ? Center(
              child: SpinKitCircle(size: 60, color: Colors.lightBlue),
            )
          : Builder(builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 130,
                          width: 130,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0, top: 16),
                          child: Text(
                            _showChangeKey
                                ? 'Change Secret Key'
                                : 'Forgot Secret Key',
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_showSendOTP)
                          Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'Tap on below button to send OTP on $_phoneNo',
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
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
                                          _showOTPBox
                                              ? 'Re-send OTP'
                                              : "Send OTP",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          _isButtonLoading = true;
                                        });
                                        _verifyPhone(context);
                                      }),
                                ),
                              ),
                            ],
                          ),
                        if (_isButtonLoading)
                          Container(
                              padding: EdgeInsets.all(16),
                              child: SpinKitWave(
                                color: Colors.lightBlue,
                                size: 30,
                              )),
                        if (_showOTPBox)
                          Container(
                            margin: EdgeInsets.only(top: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0),
                                  child: Text(
                                    'Enter OTP here ,',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 40, left: 40, top: 0, bottom: 15),
                                  child: PinInputTextField(
                                    pinLength: 6,
                                    decoration: UnderlineDecoration(
                                      enteredColor: Colors.black,
                                      hintText: '000000',
                                      hintTextStyle:
                                          TextStyle(color: Colors.grey),
                                      errorText: _errorMessage,
                                    ),
                                    controller: _pinEditingController,
                                    autoFocus: true,
                                    textInputAction: TextInputAction.done,
                                    onSubmit: (pin) {
                                      if (pin.length == 6) {
                                        print('pin submitted');
                                        setState(() {
                                          _errorMessage = '';
                                        });
                                        _verifyOTP();
                                      } else {
                                        print('error in otp length');
                                        setState(() {
                                          _errorMessage =
                                              'Please enter valid OTP';
                                        });
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(16),
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
                                          "Verify OTP",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (_pinEditingController.text.length ==
                                            6) {
                                          print('pin submitted');
                                          setState(() {
                                            _errorMessage = '';
                                          });
                                          _verifyOTP();
                                        } else {
                                          print('error in otp length');
                                          setState(() {
                                            _errorMessage =
                                                'Please Enter valid OTP';
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_showChangeKey)
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 40),
                                  child: TextFormField(
                                    controller: _newKeyController,
                                    style: TextStyle(fontSize: 20),
                                    decoration: InputDecoration(
                                      hintText: 'New Secret Key',
                                      icon: Icon(
                                        Icons.vpn_key,
                                        size: 25,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _newHideText = !_newHideText;
                                          });
                                        },
                                        icon: FaIcon(
                                          _newHideText
                                              ? FontAwesomeIcons.eye
                                              : FontAwesomeIcons.eyeSlash,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    obscureText: _newHideText,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(_confirmKeyFocusNode);
                                    },
                                    validator: (newKey) {
                                      if (newKey == null || newKey.isEmpty) {
                                        return 'Please enter a new key';
                                      }
                                      if (newKey.length > 6 ||
                                          newKey.length < 6) {
                                        return 'Key must be 6 digit long only !';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 40),
                                  child: TextFormField(
                                    style: TextStyle(fontSize: 20),
                                    decoration: InputDecoration(
                                      hintText: 'Confirm Secret Key',
                                      icon: Icon(
                                        Icons.vpn_key,
                                        size: 25,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _confirmHideText = !_confirmHideText;
                                          });
                                        },
                                        icon: FaIcon(
                                          _confirmHideText
                                              ? FontAwesomeIcons.eye
                                              : FontAwesomeIcons.eyeSlash,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    obscureText: _confirmHideText,
                                    keyboardType: TextInputType.number,
                                    focusNode: _confirmKeyFocusNode,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submitData,
                                    validator: (confirmKey) {
                                      if (confirmKey == null ||
                                          confirmKey.isEmpty) {
                                        return 'Please confirm a new key';
                                      }
                                      if (confirmKey.length > 6 ||
                                          confirmKey.length < 6) {
                                        return 'Key must be 6 digit long only !';
                                      }
                                      if (confirmKey !=
                                          _newKeyController.text) {
                                        return 'Key not matched !';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  padding: EdgeInsets.all(16),
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
                                          'Change Key',
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
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              );
            }),
    );
  }
}
