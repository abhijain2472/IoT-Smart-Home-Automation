import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homeautomation/screens/bill_estimation.dart';
import 'package:homeautomation/screens/home_screen.dart';
import 'package:homeautomation/screens/tabs_screen.dart';
import 'package:homeautomation/screens/total_usage.dart';
import 'package:homeautomation/widgets/main_drawer.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';


class PowerUsage extends StatefulWidget {
  static const routeName = '/power-usage';

  @override
  _PowerUsageState createState() => _PowerUsageState();
}

class _PowerUsageState extends State<PowerUsage> {
  ProgressDialog pr;
  final DatabaseReference _database =
      FirebaseDatabase().reference().child('data');

  var isDataAvailable = false;
  String _displayDate =
      DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
  String _urlDate = DateFormat('yyyy/MM/dd').format(DateTime.now()).toString();
  var _power;
  var _time;
  var _amount;
  var _timeString;
  final TextStyle _titleStyle = TextStyle(
      fontSize: 16, color: Colors.lightBlue, fontWeight: FontWeight.bold);
  final TextStyle _valueStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 24);
  final TextStyle _noValueStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      color: Color.fromRGBO(255, 0, 0, 0.3));

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then(
      (pickedDate) {
        if (pickedDate == null) {
          return;
        }
        setState(
          () {
            _displayDate =
                DateFormat('dd-MM-yyyy').format(pickedDate).toString();
            _urlDate = DateFormat('yyyy/MM/dd').format(pickedDate).toString();
          },
        );
        print('display date : $_displayDate');
        print('url date : $_urlDate');
      },
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration >= Duration(seconds: 3600)) {
      return "${twoDigits(duration.inHours)} h : $twoDigitMinutes m";
    } else if (duration >= Duration(seconds: 60)) {
      return "$twoDigitMinutes m : $twoDigitSeconds s";
    } else {
      return "$twoDigitSeconds seconds";
    }
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
          title: Text('Power Usage'),
        ),
        drawer: MainDrawer(),
        body: StreamBuilder(
          stream: _database.child(_urlDate).onValue,
          builder: (context, snap) {
            if (snap.hasData && snap.data.snapshot.value != null) {
              isDataAvailable = true;
              Map data = snap.data.snapshot.value;

              _amount = data['amount'].toStringAsFixed(3);
              _power = data['power'].toStringAsFixed(2);
              _time = data['time'];
              _timeString = _printDuration(Duration(seconds: _time));
            } else {
              isDataAvailable = false;
              _amount = 0000;
              _power = 0000;
              _time = 000;
              _timeString = '0 seconds';
            }
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Power Usage Statistics',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.josefinSans(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Text(
                          '- - - - - - - - - - - - - - - - - - - - - - ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 10,
                      ),
                      child: Text(
                        '👉🏻  select a date for viewing data according to particular date.',
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    FlatButton(
                      color: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      textColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      onPressed: _presentDatePicker,
                      child: Text(
                        '$_displayDate',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 8,
                            margin: const EdgeInsets.only(
                                top: 10, left: 10, bottom: 10, right: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    'Power',
                                    style: _titleStyle,
                                  ),
                                  Divider(),
                                  Text(
                                    '$_power Kwh',
                                    style:
                                        isDataAvailable ? _valueStyle : _noValueStyle,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            elevation: 8,
                            margin: const EdgeInsets.only(
                                top: 10, left: 5, bottom: 10, right: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    'Time',
                                    style: _titleStyle,
                                  ),
                                  Divider(),
                                  Text(
                                    _timeString,
                                    style:
                                        isDataAvailable ? _valueStyle : _noValueStyle,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Card(
                      elevation: 8,
                      margin:
                      const EdgeInsets.only(top: 10, left: 80, bottom: 10, right: 80),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Amount',
                              style: _titleStyle,
                            ),
                            Divider(),
                            Text(
                              '$_amount ₹',
                              style: isDataAvailable ? _valueStyle : _noValueStyle,
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: isDataAvailable
                            ? Text(
                                '',
                                style: TextStyle(fontSize: 20),
                              )
                            : Text(
                                '⚠️ No data available for this date ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              )),
                    SizedBox(
                      height: 25,
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child:  Container(
                              child: Center(
                                child: RaisedButton(
                                  color: Colors.lightBlue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                                    child: Text('Bill Estimation',style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  onPressed:() {
                                    Navigator.of(context).pushNamed(BillEstimation.routeName);
                                  },
                                ),
                              ),
                            ),
                          ),
//                      SizedBox(
//                        width: 10,
//                      ),
                          Expanded(
                            child: Container(
                              child: Center(
                                child: RaisedButton(
                                  color: Colors.lightBlue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                                    child: Text('Total Usage',style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  onPressed:() {
                                    Navigator.of(context).pushNamed(TotalUsage.routeName);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
