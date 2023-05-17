import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String userName = "";
String password = "";

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

Future<UserCredential?> login(String email, String password) async { //nullable function
  try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
  } catch (e) {
    print(e);
  }
}

Future<UserCredential?> signup(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
  } catch (e) {
    print(e);
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: 'Email',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  if (value.contains('@')) userName = value as String;
                });
              },
            ),

            TextField(
              decoration: InputDecoration(
                hintText: 'Mật khẩu',
              ),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  password = value as String;
                });
              },
            ),

            FutureBuilder<bool>(
              future: accountExists(userName, password),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  bool accountExists = snapshot.data!;
                  if (snapshot.hasData) {
                    return ElevatedButton(
                      onPressed: () async {
                        UserCredential? credential;
                        if (accountExists) {
                          credential=login(userName,password) as UserCredential?; //cai nay se tra ve userCredential
                        } else {
                          credential=signup(userName,password) as UserCredential?;
                        }
                        if (credential!=null){ //neu co credential thi co the vao
                          User user = credential.user as User;
                        }
                      },
                      child: Text(accountExists ? 'Đăng nhập' : 'Đăng ký'),
                    );
                  }
                  else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  else {
                    return Container(); // Handle other cases as desired
                  }
                }
              },
            ),

          ],
        ),
      ),
    );
  }
}
