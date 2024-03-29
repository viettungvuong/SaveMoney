import 'dart:collection';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  void swap(int i, int j) {
    T temp = list[i];
    list[i] = list[j];
    list[j] = temp;
  }

  void addBack(T t) {
    list.add(t);
  }

  void addFront(T t) {
    list.add(t);

    //swap
    for (int i = list.length - 1; i > 0; i--) {
      swap(i, i - 1);
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

  DateTime selectedDate = DateTime.now();

  void moveToNextDate(Deque<DateTime> deque) {
    if (convertDateToString(selectedDate) ==
        convertDateToString(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Không thể tăng ngày!"),
      ));
      return; //nếu là hôm nay thì không cho di chuyển
    } else {
      selectedDate = add(selectedDate, 1);

      //thêm vào trước deque
      deque.addFront(add(deque.iterate(0)!!, 1));
      deque.popLast();
    }
  }

  void moveToPrevDate(Deque<DateTime> deque) {
    selectedDate = minus(selectedDate, 1);

    //thêm vào sau deque
    deque.addBack(minus(deque.iterate(3)!!, 1));
    deque.popFirst();
  }

  final Future<String> findCategorySpentMost = categorySpentMost();

  Map<DateTime,int> maxSpending = maxSpendingIn7Days();

  @override
  initState() {
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
                    future: calc4Dates(dateDeque),
                    //ham tinh so tien chi tieu cua 4 ngay
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else {
                        return Column(
                          children: [
                            Container(
                              width: 400,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            moveToPrevDate(dateDeque); //nút trước
                                          });
                                        },
                                        icon: Icon(Icons.arrow_left),
                                        label: Text(""),
                                      ),
                                    ),

                                    Container(
                                      margin:
                                      EdgeInsets.only(left: 80, right: 80),
                                      child:
                                      Text(convertDateToString(selectedDate)),
                                    ),

                                    Flexible(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            moveToNextDate(dateDeque); //nút trước
                                          });
                                        },
                                        icon: Icon(Icons.arrow_right),
                                        label: Text(""),
                                      ),
                                    ),
                                  ]),
                            ),

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
                                        'measure': totalSpentByDate[
                                            dateDeque.iterate(3)!],
                                      },
                                      {
                                        'domain':
                                            '${convertDateToString(dateDeque.iterate(2)!)}',
                                        'measure': totalSpentByDate[
                                            dateDeque.iterate(2)!],
                                      },
                                      {
                                        'domain':
                                            '${convertDateToString(dateDeque.iterate(1)!)}',
                                        'measure': totalSpentByDate[
                                            dateDeque.iterate(1)!],
                                      },
                                      {
                                        'domain':
                                            '${convertDateToString(dateDeque.iterate(0)!)}',
                                        'measure': totalSpentByDate[
                                            dateDeque.iterate(0)!],
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
                            Container(
                              margin: EdgeInsets.all(50),
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(20),
                                    child: maxSpending.values.first>0?
                                    Column(
                                      children: [
                                          Text(
                                            "Ngày chi tiêu nhiều nhất (trong 7 ngày qua):",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Text(
                                            "${convertDateToString(maxSpending.keys.first)}",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                      ],
                                    ):
                                        Column()
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    child: maxSpending.values.first>0?
                                    Column(
                                      children: [
                                        Text(
                                          "với số tiền:",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          "${reformatNumber(maxSpending.values.first)} VNĐ",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ):Column()
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Chi tiêu nhiều nhất vào:",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        FutureBuilder<String>(
                                            future: findCategorySpentMost,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return CircularProgressIndicator();
                                              }else if (snapshot.hasError){
                                                return Text(
                                                  "Error!",
                                                  style:
                                                  TextStyle(fontSize: 15),
                                                );
                                              }
                                              else {
                                                return Text(
                                                  "${snapshot.data!}",
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                );
                                              }
                                            }),
                                      ],
                                    ),
                                  ),
                                ],
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
Future<int> calcTotalSpentDay(DateTime? date, {int amount = 0}) async {
  if (date == null) {
    return 0;
  }

  /*if (totalSpentByDate[date] != null) { //đã có dữ liệu rồi
    if (amount!=0) //nếu đang trong chế độ từ addSpending và addEarning
          totalSpentByDate[date]!=totalSpentByDate[date]!+amount;
    return totalSpentByDate[date]!;
  }*/
  //bỏ vì có thể dữ liệu đã được cập nhật trên server
  //nhưng mà sẽ implement cái để tính số tiền ở hàm kia (hàm addSpending)
  //có thể cái cost để rebuild lại widget sau khi cập nhật sẽ tốn kém hơn

  int total = 0;
  String collectionName = "spendings";
  print((convertDateToString(date)));
  await database
      ?.collection(collectionName)
      .where('user', isEqualTo: userId)
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

Future<int> calcTotalEarnedDay(DateTime? date, {int amount = 0}) async {
  if (date == null) {
    return 0;
  }

  /*if (totalEarnedByDate[date] != null) {
    if (amount!=0)
        totalEarnedByDate[date]!=totalEarnedByDate[date]!+amount;
    return totalEarnedByDate[date]!;
  }*/

  int total = 0;
  String collectionName = "earnings";
  await database
      ?.collection(collectionName)
      .where('user', isEqualTo: userId)
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
    DateTime current = deque.iterate(i)!;
    print(current);
    await calcTotalSpentDay(current);
    print(totalSpentByDate[current]);
  }
}
//DateTime.now khác format với now

//tính ngày chi tiêu nhiều nhất
Map<DateTime, int> maxSpendingIn7Days() {
  int currentMax = 0;
  DateTime res = now;

  for (int i = 0; i <= 7; i++) {
    DateTime currentIterate = minus(now, i);
    if (totalSpentByDate[currentIterate] != null &&
        totalSpentByDate[currentIterate]! > currentMax) {
      currentMax = totalSpentByDate[currentIterate]!;
      res = currentIterate;
    }
  }

  Map<DateTime, int> map = new Map();
  map[res] = currentMax;
  return map;
}

//tìm xem chi tiêu cho hạng mục nào nhiều nhất
Future<String> categorySpentMost() async {
  int max = 0;
  String res = "";

  DateTime days7ago = minus(now, 7);

  int sum = 0;
  for (String category in spendingCategories) {
    print("Current category: "+category);
    sum = 0;
    //tìm tất cả spending thuộc category này
    await database!
        .collection("spendings")
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .orderBy("day", descending: true)
        .where("user", isEqualTo: userId)
        .where("type", isEqualTo: category)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          print("Lọc" + docSnapshot.data()['type']);
          DateTime date = convertStringToDate(docSnapshot.data()['date']);
          if (!isDateBetween(date, a: days7ago, b: now)) {
            break; //nếu ngày này không còn trong khoảng 1 tuần thì ngưng
          }

          int amount = docSnapshot.data()['amount'];
          sum += amount; //them vao so tien da chi
        }
      },
      onError: (e) => print("Lỗi: $e"),
    );

    print("Total sum: "+sum.toString());

    if (sum > max) {
      max = sum;
      res = category;
    }
  }
  print(res);
  return res;

}

//ktra xem một ngày có nằm giữa 2 ngày a và b không
bool isDateBetween(DateTime date, {required DateTime a, required DateTime b}) {
  return date==a||date==b||(date.isAfter(a) && date.isBefore(b));

  //tư duy của thuật toán này là kiểm tra xem comp có sau a VÀ comp có trước b
}

//tìm ngày nào có chi tiêu tăng cao bất thường
void abnormalSpending(){

}
