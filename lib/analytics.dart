import 'dart:collection';
import 'dart:math';

import 'package:d_chart/d_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:save_money/income.dart';
import 'package:save_money/main.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:save_money/spending.dart';
import 'add.dart';

class Stack<T> {
  List<T> list = []; //để implement nhanh hơn dùng list

  void add(T t) {
    list.add(t);
  }

  T? pop() {
    if (list.isEmpty) return null;
    T poppedT = list!.last;
    list.removeLast(); //bỏ phần từ ở cuối list
    return poppedT;
  }

  T? iterate(int i) {
    //lấy phần tử ở vị trí i
    if (list.length <= i) return null;
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

class TabPage extends StatefulWidget {
  //truyen ham tu widget hien tai qua dialog

  TabPage(this.tabName, {super.key});

  final String tabName;

  @override
  State<TabPage> createState() => TabState();
}

class TabState extends State<TabPage> {
  Stack<DateTime> dateStack = new Stack<DateTime>();

  DateTime selectedDate=DateTime.now();

  void moveToNextDate(){
    if (selectedDate==DateTime.now()){
      return; //nếu là hôm nay thì không cho di chuyển
    }
    else{
      setState(() {
        add(selectedDate!!, 1);
      });
    }
  }

  void moveToPrevDate(){
    setState(() {
      minus(selectedDate!!, 1);
    });
  }

  //late nghĩa là ta sẽ initialize sau

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i <= 3; i++) {
      DateTime current = minus(now, i);
      dateStack.add(current); //thêm ngày hôm nay và 3 ngày gần nhất
    }
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                FutureBuilder<void>(
                    future: calc4Dates(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else {
                        return Column(
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                //Center Column contents vertically,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      moveToNextDate();
                                    },
                                    icon: Icon(Icons.arrow_left),
                                    label: Text(""),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(left: 80, right: 80),
                                    child: Text("${convertDateToString(selectedDate)}"),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      moveToPrevDate();
                                    },
                                    icon: Icon(Icons.arrow_right),
                                    label: Text(""),
                                  )
                                ]),
                            Container(
                              width: 500,
                              height: 250,
                              child: DChartBar(
                                data: [
                                  {
                                    'id': 'Bar',
                                    'data': [
                                      {
                                        'domain':
                                            '${convertDateToString(dateStack.iterate(0)!)}',
                                        'measure': totalSpentByDate[
                                            dateStack.iterate(0)!],
                                      },
                                      {
                                        'domain':
                                            '${convertDateToString(dateStack.iterate(1)!)}',
                                        'measure': totalSpentByDate[
                                            dateStack.iterate(1)!],
                                      },
                                      {
                                        'domain':
                                            '${convertDateToString(dateStack.iterate(2)!)}',
                                        'measure': totalSpentByDate[
                                            dateStack.iterate(2)!],
                                      },
                                      {
                                        'domain':
                                            '${convertDateToString(dateStack.iterate(3)!)}',
                                        'measure': totalSpentByDate[
                                            dateStack.iterate(3)!],
                                      },
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
                          ],
                        );
                      }
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }
}

DateTime minus(DateTime date, int days) {
  return date.subtract(Duration(days: days));
}

DateTime add(DateTime date, int days) {
  return date.add(Duration(days: days));
}

//danh sách spending của các các ngày
Map<DateTime, int> totalSpentByDate = {};
Map<DateTime, int> totalEarnedByDate = {};

//hai hàm lấy tổng chi tiêu của từng ngày
Future<int> calcTotalSpentDay(DateTime? date) async {
  if (date == null) {
    return 0;
  }
  if (totalSpentByDate[date] != null && totalSpentByDate[date] != 0) {
    return totalSpentByDate[date]!;
  }
  int total = 0;
  String collectionName = userId! + "spent";
  print((convertDateToString(date)));
  await database
      ?.collection(collectionName)
      .where('date', isEqualTo: convertDateToString(date))
      .get()
      .then(
    (querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        int amount = docSnapshot.data()['amount'];
        print(amount);
        total += amount;
      }
    },
    onError: (e) => print("Lỗi: $e"),
  );
  totalSpentByDate[date!] = total;
  return total;
}

Future<int> calcTotalEarnedDay(DateTime? date) async {
  if (date == null) {
    return 0;
  }
  if (totalEarnedByDate[date] != null && totalEarnedByDate[date] != 0) {
    return totalEarnedByDate[date]!;
  }
  int total = 0;
  String collectionName = userId! + "earned";
  await database
      ?.collection(collectionName)
      .where('date', isEqualTo: convertDateToString(date))
      .get()
      .then(
    (querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        int amount = docSnapshot.data()['amount'];
        print(amount);
        total += amount;
      }
    },
    onError: (e) => print("Lỗi: $e"),
  );
  totalEarnedByDate[date!] = total; //proxy pattern
  return total;
}

//tinh 4 ngay lien tiep
Future<void> calc4Dates() async {
  for (int i = 0; i <= 3; i++) await calcTotalSpentDay(minus(now, 0));
}

