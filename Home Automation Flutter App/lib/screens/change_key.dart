import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homeautomation/screens/home_screen.dart';
import 'package:homeautomation/screens/login_screen.dart';
import 'package:homeautomation/widgets/main_drawer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';

final DatabaseReference _database =
    FirebaseDatabase().reference().child('security/key');


class ChangeKey extends StatefulWidget {
  static const routeName = '/change-key';

  @override
  _ChangeKeyState createState() => _ChangeKeyState();
}

class _ChangeKeyState extends State<ChangeKey> {

  ProgressDialog pr;
  var _currentHideText = true;
  var _newHideText = true;
  var _confirmHideText = true;
  var _isKeyMatched = false;
  var _showErrorMsg = false;
  var _isLoading = false;

  final _newKeyController = TextEditingController();
  final _newKeyFocusNode = FocusNode();
  final _confirmKeyFocusNode = FocusNode();

  var _currentKey;
  final _formKey = GlobalKey<FormState>();

  Future<void> _getCurrentKey() async {
    _isLoading = true;
    DataSnapshot snapshot = await _database.once();
    _currentKey = snapshot.value.toString();
    setState(() {
      _isLoading = false;
    });
  }

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
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  void initState() {
    _getCurrentKey();
    super.initState();
  }

  @override
  void dispose() {
    _newKeyController.dispose();
    _confirmKeyFocusNode.dispose();
    _newKeyFocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(message: 'No internet ‼️\nPlease try again later',textAlign: TextAlign.center,);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: (){
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Change Key'),
        ),
        drawer: MainDrawer(),
        body: _isLoading
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
                            'Change Secret Key',
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            child: TextFormField(
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                hintText: 'Current Secret Key',
                                icon:  Icon(
                                  Icons.vpn_key,
                                  size: 25,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _currentHideText = !_currentHideText;
                                    });
                                  },
                                  icon: FaIcon(
                                    _currentHideText
                                        ? FontAwesomeIcons.eye
                                        : FontAwesomeIcons.eyeSlash,
                                    size: 18,
                                  ),
                                ),
                              ),
                              obscureText: _currentHideText,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              validator: (currentKey) {
                                if (currentKey == null || currentKey.isEmpty) {
                                  return 'Please enter a current key';
                                }
                                if (currentKey.length > 6 ||
                                    currentKey.length < 6) {
                                  return 'Key must be 6 digit long only !';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) {
                                if (value == _currentKey) {
                                  FocusScope.of(context)
                                      .requestFocus(_newKeyFocusNode);
                                }
                              },

                              onChanged: (value) {
                                if (value.isEmpty) {
                                  _showErrorMsg = false;

                                } else {
                                  _showErrorMsg = true;

                                }
                                if (value == _currentKey) {
                                  _isKeyMatched = true;

                                } else {
                                  _isKeyMatched = false;

                                }
                                setState(() {});
                              },
                            ),
                          ),
                          if (_showErrorMsg)
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Text(
                                _isKeyMatched
                                    ? 'Current key is matched successfully'
                                    : 'Current key is not matched',
                                style: TextStyle(
                                    color: _isKeyMatched
                                        ? Colors.lightGreen
                                        : Colors.red,
                                    fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            child: TextFormField(
                              controller: _newKeyController,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                hintText: 'New Secret Key',
                                icon:  Icon(
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
                              enabled: _isKeyMatched,
                              obscureText: _newHideText,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              focusNode: _newKeyFocusNode,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_confirmKeyFocusNode);
                              },
                              validator: _isKeyMatched? (newKey) {
                                if (newKey == null || newKey.isEmpty) {
                                  return 'Please enter a new key';
                                }
                                if(int.tryParse(newKey)==null){
                                  return 'Key must be only numbers !';
                                }
                                if (newKey.length > 6 ||
                                    newKey.length < 6) {
                                  return 'Key must be 6 digit long only !';
                                }

                                return null;
                              }:null,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            child: TextFormField(
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                hintText: 'Confirm Secret Key',
                                icon:  Icon(
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
                              enabled: _isKeyMatched,
                              keyboardType: TextInputType.number,
                              focusNode: _confirmKeyFocusNode,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submitData,
                              validator: _isKeyMatched?(confirmKey) {
                                if (confirmKey == null ||
                                    confirmKey.isEmpty) {
                                  return 'Please confirm a new key';
                                }
                                if (confirmKey.length > 6 ||
                                    confirmKey.length < 6) {
                                  return 'Key must be 6 digit long only !';
                                }
                                if (confirmKey != _newKeyController.text) {
                                  return 'Key not matched !';
                                }
                                return null;
                              }:null,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: RaisedButton(
                                color: Colors.lightBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius:  BorderRadius.circular(6.0)),
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
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
