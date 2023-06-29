import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:save_money/add.dart';
import 'package:save_money/userPage.dart';
import 'package:searchable_listview/widgets/list_item.dart';
import 'analytics.dart';
import 'firebase_options.dart';
import 'income.dart';
import 'spending.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:searchable_listview/searchable_listview.dart';

const String firstPage = 'Trang chủ';
const String secondPage = 'Chi tiêu';
const String thirdPage = 'Nguồn thu';
const MaterialColor colorBar = Colors.cyan;

int selectedIndex = 0; //index tren bottom menu bar
FirebaseFirestore? database; //dung firebase database
User? currentUser; //user dang dang nhap
String? userId; //id nay quan trong de luu database

List<Spending> spendings = []; //danh sach cac khoan chi tieu
List<Earning> earnings = []; //danh sach cac nguon thu

DateTime now = DateTime.now();

int spent = 0;
int earned = 0;

int getDiff() {
  return earned - spent;
}

String convertDateToString(DateTime date) {
  return date.day.toString() +
      "-" +
      date.month.toString() +
      "-" +
      date.year.toString();
} //doi ngay thang qua string

DateTime convertStringToDate(String date) {
  List<String> splitRes = date.split('-');
  int month = int.parse(splitRes[1]);
  int year = int.parse(splitRes[2]);
  int day = int.parse(splitRes[0]);
  return DateTime(year, month, day);
}

//cai nay phai dua vao mot thread rieng, doi cai nay xong roi moi mo app
Future<void> initializeSpendings(List<Spending> spendings) async {
  String collectionName = userId! + "spent";
  await database
      ?.collection(collectionName)
      .get()
      .then(
        (querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        int amount = docSnapshot.data()['amount'];
        String typeOfSpending = docSnapshot.data()['type'];
        DateTime date = convertStringToDate(docSnapshot.data()['date']!);
        spendings.add(new Spending(amount, date, type: typeOfSpending));

        print(amount);
        spent += amount; //them vao so tien da chi
      }
    },
    onError: (e) => print("Lỗi: $e"),
  );
  //them await de doi no doc het xong roi moi ket thuc
}

Future<void> initializeEarnings(List<Earning> earnings) async {
  print(convertDateToString(now));
  String collectionName = userId! + "earned";
  await database
      ?.collection(collectionName)
      .get()
      .then(
    (querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        int amount = docSnapshot.data()['amount'];
        String typeOfSpending = docSnapshot.data()['type'];
        DateTime date = convertStringToDate(docSnapshot.data()['date']!);
        earnings.add(new Earning(amount, date, type: typeOfSpending));

        print(amount);
        earned += amount; //them vao so tien da chi
      }
    },
    onError: (e) => print("Lỗi: $e"),
  );
  //them await de doi no doc het xong roi moi ket thuc
  print(spendings.length);
}

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  database = FirebaseFirestore.instance;
  database!.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  ); //chỉnh cache cho firebase offline

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  if (user != null) {
    //session chua expire
    try {
      //kiem tra co id token khong
      IdTokenResult tokenResult = await user.getIdTokenResult();

      //session nay chua expire
      if (tokenResult.token != null&&user!=null) {
        //neu co id token thi tien hanh auto login vao man hinh chinh luon
        currentUser = user;
        userId = user.uid;

        runApp(const MyApp());
      } else {
        runApp(const LoginPage());
      }
    } catch (e) {
      print(e);
      //exception
    }
  } else {
    runApp(const LoginPage());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save Money',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Something'),
      content: TextField(
        controller: _textController,
        decoration: InputDecoration(hintText: 'Nhập gì đó'),
      ),
      actions: [
        TextButton(
          child: Text('Huỷ'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Thêm'),
          onPressed: () {
            // Save the text input and close the dialog
            final text = _textController.text;
            Navigator.of(context).pop(text);
          },
        ),
      ],
    );
  }
}

// Show the dialog
void _showAddDialog(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (context) => MyDialog(),
  );

  // Handle the result returned by the dialog
  if (result != null) {
    // Do something with the text input
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              dividerColor: Colors.transparent,
              tabs: <Widget>[
                Tab(
                  text: 'Trang chủ',
                  icon: Icon(Icons.home),
                ),
                Tab(
                  text: 'Chi tiêu',
                  icon: Icon(Icons.money_off),
                ),
                Tab(
                  text: 'Nguồn thu',
                  icon: Icon(Icons.monetization_on),
                ),
              ],
            ),
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
          ),

          body: TabBarView(
            children: [
              HomePage(),
              AddSpending(),
              AddEarning(),
            ],
          ),

          drawer: Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Container(
                      margin: EdgeInsets.all(50),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.logout),
                        label: Text("Đăng xuất"),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: const Text('Tổng quan'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.analytics),
                    title: const Text('Phân tích'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AnalyticsPage()),
                      );
                    },
                  ),
                ],
              )),
        ));
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
  }
}

class HomePage extends StatefulWidget{
  HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>{
  int target = 0;

  void sortSpending() {
    //quick sort
  }

  int getCurrentMonth() {
    return DateTime.now().month;
  }

  void setTarget(int amount) {
    setState(() {
      target = amount;
    });
  }

  Future<void> initialize() async{
    if (spendings.isEmpty) //nếu list trống mới load
      await initializeSpendings(spendings); //đợi xong (await)

    if (earnings.isEmpty)
      await initializeEarnings(earnings);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 50,
            ),

            SizedBox(height: 100), // thêm khoảng trăng giữa 2 widget

            Text('Chênh lệch tháng ${getCurrentMonth()}'),

            FutureBuilder<void>(
              future: initialize(),
              builder: (context, snapshot){
                 if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                 } else {
                   return Text(
                     '${reformatNumber(getDiff())} VND', //xuat ra chenh lech
                     style: TextStyle(
                       fontSize: 35,
                       fontWeight: FontWeight.bold,
                       color: (getDiff()>0)?Colors.green:Colors.red,
                     ),
                   );
                 }
              },
            ),


            SizedBox(
              height: 100,
            ),

            Text(
              'Mục tiêu tháng ${getCurrentMonth()} là',
            ),
            Text(
              '${reformatNumber(target)} VND',
              style: TextStyle(
                fontSize: 18,
              ),
            ),

            ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SetTarget(
                          onAdd: setTarget,
                        );
                      });
                });
              },
              icon: Icon(Icons.add),
              label: Text('Đặt mục tiêu'),
            ),

            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

}

class SetTarget extends StatefulWidget {
  final void Function(int) onAdd;
  //truyen ham tu widget hien tai qua dialog

  SetTarget({required this.onAdd});

  @override
  _SetTargetState createState() => _SetTargetState();
}

class _SetTargetState extends State<SetTarget> {
  int? addAmount;
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: 'Mục tiêu',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              onChanged: (value) {
                setState(() {
                  addAmount = int.tryParse(value);
                  _textEditingController.text = reformatNumber(addAmount!);
                  _textEditingController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _textEditingController.text.length));
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  widget.onAdd(addAmount!);
                  //widget la de cap toi bien o cai phan State
                  Navigator.pop(context);
                });
              },
              icon: Icon(Icons.add),
              label: Text('Đặt mục tiêu'),
            ),
          ],
        ),
      ),
    );
  }
}
