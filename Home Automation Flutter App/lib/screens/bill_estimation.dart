import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homeautomation/screens/total_usage.dart';


final DatabaseReference _database =
    FirebaseDatabase().reference().child('data/2020');



class BillEstimation extends StatefulWidget {
  static const routeName = '/bill-estimation';

  @override
  _BillEstimationState createState() => _BillEstimationState();
}

class _BillEstimationState extends State<BillEstimation> {
//  ProgressDialog pr;

  var _months = ['1 month', '2 month', '3 month'];
  var _selectedMonth = '1 month';
  var _selectedMonthNumber = 1;
  var _totalPower = 0.0;
  var _totalDays = 0;
  var _isLoading = false;
  var _averagePower = 0.0;

  void _getTotal() async {
    _isLoading = true;
    _totalDays = 0;
    _totalPower = 0.0;

    DataSnapshot snapshot = await _database.once();
    var data = snapshot.value as Map<dynamic, dynamic>;

    data.forEach((month, dates) {
      var date = dates as Map<dynamic, dynamic>;
      date.forEach((date, values) {
        _totalDays = _totalDays + 1;
        _totalPower = _totalPower + values['power'];
      });
    });
    _averagePower = ((_totalPower / _totalDays) * 30 * 0.0008);
    print(_totalPower);
    print(_totalDays);
    print(_averagePower);

    setState(() {
      _isLoading = false;
    });
  }


  @override
  void initState() {
    _getTotal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Estimation'),
      ),
      body: _isLoading
          ? Center(
              child: SpinKitCircle(size: 60, color: Colors.lightBlue),
            )
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    'assets/images/Bill.png',
                    height: 130,
                    width: 130,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 5,
                    ),
                    child: Text(
                      '👉🏻  The estimated electricity bill 🧾 of $_selectedMonth based on average usage of power will be :-',
                      softWrap: true,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),

                  DropdownButton(


                      iconEnabledColor: Colors.lightBlue,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.lightBlue,
                      ),
                      value: _selectedMonth,
                      elevation: 8,
                      items: _months.map((String month) {
                        return DropdownMenuItem<String>(
                          child: Container(

                              padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 10,),
                              child: Text(month)),
                          value: month,
                        );
                      }).toList(),
                      onChanged: (String newMonth) {
                        setState(() {
                          _selectedMonth = newMonth;
                          _selectedMonthNumber = (_months.indexOf(newMonth) + 1);
                        });
                      }),
                  SizedBox(
                    height: 12,
                  ),
                  Card(
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: FlatButton(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        color: Colors.teal,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onPressed: () {},
                        child: Text(
                          '${(_averagePower * _selectedMonthNumber).toStringAsFixed(3)} ₹',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    elevation: 8,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Center(
                      child: RaisedButton(
                        color: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 60),
                          child: Text('Total Usage',style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                          ),
                        ),
                        onPressed:() {
                          Navigator.of(context)
                              .pushReplacementNamed(TotalUsage.routeName);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
    );
  }
}
