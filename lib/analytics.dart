import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:save_money/income.dart';
import 'package:save_money/main.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'add.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => AnalyticsState();
}

class AnalyticsState extends State<AnalyticsPage> {
  int currentSelection = 0; //cho biet dang chon o phan Ngay, Tuan, hay Thang
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            tabs: <Widget>[
              Tab(
                text: 'Ngày',
              ),
              Tab(
                text: 'Tháng',
              ),
              Tab(
                text: 'Năm',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TabPage("Ngày"),
            TabPage("Tháng"),
            TabPage('Năm'),
          ],
        ),
      ),
    );
  }
}

class TabPage extends StatefulWidget{

  //truyen ham tu widget hien tai qua dialog

  TabPage(this.tabName, {super.key});

  final String tabName;

  @override
  State<TabPage> createState() => TabState();
}

class TabState extends State<TabPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Chart(
            layers: [
              ChartAxisLayer(
                settings: ChartAxisSettings(
                  x: ChartAxisSettingsAxis(
                    frequency: 1.0,
                    max: 13.0,
                    min: 7.0,
                    textStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10.0,
                    ),
                  ),
                  y: ChartAxisSettingsAxis(
                    frequency: 100.0,
                    max: 300.0,
                    min: 0.0,
                    textStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10.0,
                    ),
                  ),
                ),
                labelX: (value) => value.toInt().toString(),
                labelY: (value) => value.toInt().toString(),
              ),
              ChartBarLayer(
                items: List.generate(
                  13 - 7 + 1,
                      (index) => ChartBarDataItem(
                    color: const Color(0xFF8043F9),
                    value: Random().nextInt(280) + 20,
                    x: index.toDouble() + 7,
                  ),
                ),
                settings: const ChartBarSettings(
                  thickness: 8.0,
                  radius: BorderRadius.all(Radius.circular(4.0)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}