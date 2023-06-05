import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => AnalyticsState();
}

class AnalyticsState extends State<AnalyticsPage> {
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
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    child: ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          "Ngày",
                        ),
                        style: ElevatedButton.styleFrom(primary: Colors.teal)),
                  ),

                  Container(
                    margin: EdgeInsets.all(10),
                    child: ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          "Tháng",
                        ),
                        style: ElevatedButton.styleFrom(primary: Colors.teal)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
