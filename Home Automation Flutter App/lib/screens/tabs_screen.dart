import 'package:flutter/material.dart';
import 'package:homeautomation/screens/bill_estimation.dart';
import 'package:homeautomation/screens/total_usage.dart';


class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(

      length: 2,
      // initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Meals'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(

                text: 'Total Usage',
              ),
              Tab(

                text: 'Bill Estimation',
              ),
            ],
          ),
        ),
        body: TabBarView(

          children: <Widget>[
            TotalUsage(),
            BillEstimation(),
          ],
        ),
      ),
    );
  }
}
