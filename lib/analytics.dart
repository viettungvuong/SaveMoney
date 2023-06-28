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


class Deque<T> {
  List<T> list = []; //để implement nhanh hơn dùng list

  void swap(int i, int j){
    T temp = list[i];
    list[i]=list[j];
    list[j]=temp;
  }

  void addBack(T t) {
    list.add(t);
  }

  void addFront(T t){
    list.add(t);

    //swap
    for (int i=list.length-1; i>0; i--){
      swap(i,i-1);
    }
  }

  T? popLast() {
    if (list.isEmpty) return null;

    T poppedT = list!.last;
    list.removeLast(); //bỏ phần từ ở cuối list
    return poppedT;
  }

  T? popFirst() {
    if (list.isEmpty) return null;

    T poppedT = list!.first;
    list.removeAt(0); //bỏ phần từ ở đầu list
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
  Deque<DateTime> dateDeque = new Deque<DateTime>();
  //ở index đầu là ngày hiện tại

  DateTime selectedDate=DateTime.now();

  void moveToNextDate(Deque<DateTime> deque){
    if (convertDateToString(selectedDate)==convertDateToString(DateTime.now())){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Không thể tăng ngày!"),
      ));
      return; //nếu là hôm nay thì không cho di chuyển
    }
    else{
        selectedDate=add(selectedDate, 1);

        //thêm vào trước deque
        deque.addFront(add(deque.iterate(0)!!,1));
        deque.popLast();
    }
  }

  void moveToPrevDate(Deque<DateTime> deque){
      selectedDate=minus(selectedDate, 1);

      //thêm vào sau deque
      deque.addBack(minus(deque.iterate(3)!!,1));
      deque.popFirst();
  }

  //late nghĩa là ta sẽ initialize sau

  @override
  initState(){
    super.initState();

    for (int i = 0; i <= 3; i++) {
      DateTime current = minus(now, i);
      dateDeque.addBack(current); //thêm ngày hôm nay và 3 ngày gần nhất
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                FutureBuilder<void>(
                    future: calc4Dates(dateDeque), //ham tinh so tien chi tieu cua 4 ngay
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
                                      setState(() {
                                        moveToPrevDate(dateDeque);
                                      });

                                    },
                                    icon: Icon(Icons.arrow_left),
                                    label: Text(""),
                                  ),

                                  Container(
                                    margin:
                                        EdgeInsets.only(left: 80, right: 80),
                                    child: Text(convertDateToString(selectedDate)),
                                  ),

                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        moveToNextDate(dateDeque);
                                      });
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
                                            '${convertDateToString(dateDeque.iterate(3)!)}',
                                        'measure': totalSpentByDate[dateDeque.iterate(3)!],
                                      },
                                      {
                                        'domain':
                                            '${convertDateToString(dateDeque.iterate(2)!)}',
                                        'measure': totalSpentByDate[dateDeque.iterate(2)!],
                                      },
                                      {
                                        'domain':
                                            '${convertDateToString(dateDeque.iterate(1)!)}',
                                        'measure': totalSpentByDate[dateDeque.iterate(1)!],
                                      },
                                      {
                                        'domain':
                                            '${convertDateToString(dateDeque.iterate(0)!)}',
                                        'measure': totalSpentByDate[dateDeque.iterate(0)!],
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

  /*if (totalSpentByDate[date] != null && totalSpentByDate[date] != 0) { //đã có dữ liệu rồi
    return totalSpentByDate[date]!;
  }*/
  //bỏ vì có thể dữ liệu đã được cập nhật trên server

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
  totalSpentByDate[date] = total;
  return total;
}

Future<int> calcTotalEarnedDay(DateTime? date) async {
  if (date == null) {
    return 0;
  }

  /*if (totalEarnedByDate[date] != null && totalEarnedByDate[date] != 0) {
    return totalEarnedByDate[date]!;
  }*/

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
  totalEarnedByDate[date] = total; //proxy pattern
  return total;
}

//tinh so tien 4 ngay lien tiep
Future<void> calc4Dates(Deque<DateTime> deque) async {
  for (int i = 0; i <= 3; i++) {
    DateTime current=deque.iterate(i)!;
    print(current);
    await calcTotalSpentDay(current);
    print(totalSpentByDate[current]);
  }
}
//DateTime.now khác format với now

