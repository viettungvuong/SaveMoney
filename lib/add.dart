import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

List<String> categories=['Eating','Drinking','Shopping','Fines','Mandatory Fees','Others']; //danh sach cac loai tieu tien

class AddSpending extends StatelessWidget{
  const AddSpending({super.key}); //nho luon them cai nay

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add new transaction',
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
    );
  }
}