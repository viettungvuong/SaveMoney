
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_money/main.dart';

String userName = "";
String password = "";

void dialog(BuildContext context, {required String noti}){
  showDialog( //day la cach show dialog
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$noti'),
      content: Text('$noti'),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'))
      ],
    ),
  );
}

Future<bool> accountExists(String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);

    if (signInMethods.isNotEmpty) {
      return true; // Account exists
    } else {
      return false; // Account does not exist
    }
  } catch (e) {
    return false; // Handle error scenario
  }
}

Future<UserCredential?> login(String email, String password, BuildContext context) async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'wrong-password') {
      dialog(context, noti: 'Mật khẩu không đúng');
    } else if (e.code == 'user-not-found') {
      dialog(context, noti: 'Không tìm thấy người dùng');
    }
  } catch (e) {
    print(e);
  }
}

Future<UserCredential?> signup(String email, String password, BuildContext context) async {
  try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final information = <String, String>{
      "dateStarted": convertDateToString(now),
    };
    await database!.collection("users").doc(userId).set(information);
    return credential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      dialog(context, noti: 'Mật khẩu quá yếu');
    }
  } catch (e) {
    print(e);
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

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
      home: const LoginPage(),
    );
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var txt=new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                 margin: EdgeInsets.only(left: 20, right: 20),
                 child: TextField(
                   controller: txt,
                   decoration: InputDecoration(
                     hintText: 'Email',
                   ),
                   keyboardType: TextInputType.number,
                   onChanged: (value) {
                     setState(() {
                       if (value.contains('@')) userName = value as String;
                       //o nut login ta check email co dau @
                     });
                   },
                   textInputAction: TextInputAction.next, // Moves focus to next.
                 ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Mật khẩu',
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      password = value as String;
                    });
                  },
                  textInputAction: TextInputAction.done,
                ),
              ),
              FutureBuilder<bool>( //oool này sẽ dựa hàm accountExists để tạo widget
                future: accountExists(userName, password),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    bool accountExists = snapshot.data ?? false;
                    if (snapshot.hasData) {
                      return ElevatedButton(
                        onPressed: () async {
                         UserCredential? credential;
                          if (accountExists) {
                            credential = await login(userName, password, context);
                            //do login la future
                            //nen ta dung await de gan vao bien bth
                          } else {
                            credential = await signup(userName, password, context);
                          }
                          if (credential != null) {
                            currentUser=credential.user as User;
                            userId=currentUser?.uid; //them dau ? de null safety
                            initializeSpendings(spendings); //load cac spending
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MyApp()),
                            );
                          }
                          else{
                            print("Error!");
                            dialog(context, noti: 'Email không hợp lệ');
                          }
                        },
                        child: Text(accountExists ? 'Đăng nhập' : 'Đăng ký'),
                        //do cái accountExists là async nên phải dùng future<bool> để có button này
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Container();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
