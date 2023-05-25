import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:save_money/add.dart';
import 'package:save_money/userPage.dart';
import 'firebase_options.dart';
import 'spending.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:searchable_listview/searchable_listview.dart';

FirebaseFirestore? database; //dung firebase database
User? currentUser; //user dang dang nhap
String? userId; //id nay quan trong de luu database

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  database = FirebaseFirestore.instance;


  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;


  if (user != null) { //session chua expire
    try {
      //kiem tra co id token khong
      IdTokenResult tokenResult = await user.getIdTokenResult();

      //session nay chua expire
      if (tokenResult.token != null) {
       //neu co id token thi tien hanh auto login vao man hinh chinh luon
        currentUser=user;
        userId=user.uid;
        initializeSpendings(spendings);
        runApp(const MyApp());
      }
      else{
        runApp(const LoginPage());
      }
    } catch (e) {
      print('Error');
       //exception
    }
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
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(),
    );
  }
}

int selectedIndex=0; //index tren bottom menu bar currency

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Something'),
      content: TextField(
        controller: _textController,
        decoration: InputDecoration(hintText: 'Enter text here'),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Add'),
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
List<Spending> spendings=[]; //danh sach cac khoan chi tieu

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

void initializeSpendings(List<Spending> spendings){
  database?.collection(userId!).get().then(
        (querySnapshot) {
      print("Successfully completed");
      for (var docSnapshot in querySnapshot.docs) {
        double amount = double.parse(docSnapshot.data()['amount']);
        String typeOfSpending = docSnapshot.data()['type'];
        spendings.add(new Spending(amount,typeOfSpending: typeOfSpending));
      }
    },
    onError: (e) => print("Lỗi: $e"),
  );
}

class _MyHomePageState extends State<MyHomePage> {
  double balance=0;
  double target=0;

  void addToBalance(double money){
    setState(() {
      balance+=money;

      spendings.add(Spending(money)); //them vao list danh sach cac spending
    });
  }

  void setBalance(double money){
    setState(() {
      target=money;
    });
  }

  void SortSpending(){
    //quick sort

  }

  int getCurrentMonth(){
    return DateTime.now().month;
  }

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.pink,

        onTap: (value){
          setState(() {
            selectedIndex=value;

            switch (selectedIndex){
              case 0:
                {
                  //neu bam home
                  break;
                }
              case 1:{
                //neu bam add
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddSpending()),
                );
                break;
              }
            }
          });
        },
        //value la gia tri ma onTap se tra ve, ta dung value nay de chinh selectedIndex
        //{} la de dung ham truc tiep tai dong ma khong can khai bao ham rieng
        //nho phai co setState

        items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
          backgroundColor: Colors.pink,
        ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
            backgroundColor: Colors.pink,
          ),
        ],

      ),

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Số dư hiện tại là',
            ),
            Text(
              '$balance VND', //xuat ra bien balance (so tien hien co)
              style: Theme.of(context).textTheme.headlineMedium,
            ),


            SizedBox(height: 100), // thêm khoảng trăng giữa 2 widget

            Text(
              'Mục tiêu tháng ${getCurrentMonth()} là',

            ),
            Text(
              '$target VND',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 100,),

            SearchableList<Spending>(
              initialList: spendings,
              builder: (Spending spending)=>SpendingItem(spending: spending),),
          ],
        ),
      ),
    );
  }
}
