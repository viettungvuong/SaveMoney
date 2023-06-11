import 'dart:collection';
import 'dart:math';

import 'package:d_chart/d_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:save_money/income.dart';
import 'package:save_money/main.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'add.dart';

class Stack<T>{
  List<T> list=[]; //để implement nhanh hơn dùng list

  void add(T t){
    list.add(t);
  }

  T? pop(){
    if (list.isEmpty)
      return null;
    T poppedT=list!.last;
    list.removeLast(); //bỏ phần từ ở cuối list
    return poppedT;
  }

  T? iterate(int i){ //lấy phần tử ở vị trí i
    if (list.length<=i)
      return null;
    return list[i];
  }
}

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
  Stack<DateTime> dateStack=new Stack<DateTime>();
  //late nghĩa là ta sẽ initialize sau

  @override
  Widget build(BuildContext context) {
    for (int i=0; i<=3; i++){
      dateStack.add(minus(now, i)); //thêm ngày hôm nay và 3 ngày gần nhất
    }
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: DChartBar(
                data: [
                  {
                    'id': 'Bar',
                    'data': [
                      {'domain': '${convertDateToString(dateStack.iterate(0)!)}', 'measure': 2},
                      {'domain': '${convertDateToString(dateStack.iterate(1)!)}', 'measure': 4},
                      {'domain': '${convertDateToString(dateStack.iterate(2)!)}', 'measure': 6},
                      {'domain': '${convertDateToString(dateStack.iterate(3)!)}', 'measure': 0.3},
                    ],
                  },
                ],
                domainLabelPaddingToAxisLine: 16,
                axisLineTick: 2,
                axisLinePointTick: 2,
                axisLinePointWidth: 10,
                axisLineColor: Colors.green,
                measureLabelPaddingToAxisLine: 16,
                barColor: (barData, index, id) => Colors.green,
                showBarValue: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

DateTime minus(DateTime date, int days){
  return date.subtract(Duration(days: days));
}

DateTime add(DateTime date, int days){
  return date.add(Duration(days: days));
}