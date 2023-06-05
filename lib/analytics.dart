import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:save_money/main.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => AnalyticsState();
}

class AnalyticsState extends State<AnalyticsPage> {
  int currentSelection=0; //cho biet dang chon o phan Ngay, Tuan, hay Thang
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          ),
      body: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(50),
              child: Wrap(
                direction: Axis.horizontal,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedIndex=0;
                        });
                      },
                      child: Text(
                        "Ngày",
                      ),
                      style: ElevatedButton.styleFrom(primary: (selectedIndex==0)?Colors.blue:Colors.cyan)),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedIndex=1;
                        });
                      },
                      child: Text(
                        "Tuần",
                      ),
                      style: ElevatedButton.styleFrom(primary: (selectedIndex==1)?Colors.blue:Colors.cyan)),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedIndex=2;
                        });
                      },
                      child: Text(
                        "Tháng",
                      ),
                      style: ElevatedButton.styleFrom(primary: (selectedIndex==2)?Colors.blue:Colors.cyan)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
