import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:save_money/main.dart';

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
            TabPage(tabName: 'Ngày',),
            TabPage(tabName: 'Tháng',),
            TabPage(tabName: 'Năm',),
          ],
        ),
      ),
    );
  }
}

class TabPage extends StatefulWidget{
  final String tabName;
  //truyen ham tu widget hien tai qua dialog

  TabPage({required this.tabName});

  @override
  State<TabPage> createState() => TabState();
}

class TabState extends State<TabPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

        ],
      ),
    );
  }

}