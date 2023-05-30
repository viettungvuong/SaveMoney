import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_money/spending.dart';
import 'package:selection_menu/components_configurations.dart';
import 'package:selection_menu/selection_menu.dart';
import 'add.dart';
import 'main.dart';

List<String> earningCategories=['Tiền lương','Nhận lãi','Tiền thuê nhà','Học bổng','Tặng','Hoàn tiền','Khác']; //danh sach cac loai tieu tien


void reset(TextEditingController valueController, TextEditingController? valueController2, BuildContext context){
  valueController.text='';
  if (valueController2!=null)
    valueController2.text='';
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddEarning()),
  );
}


class AddEarning extends StatefulWidget{
  const AddEarning({super.key});

  @override
  State<AddEarning> createState() => _AddPageState();
}

class _AddPageState extends State<AddEarning> {
  double earnedMoney = 0,
      optionalFee = 0;
  String selectedCategory=earningCategories[0];
  bool secondaryTextField = false;

  final TextEditingController _textEditingController = TextEditingController(); //textcontroller de dieu khien data tu textfield
  final TextEditingController _textEditingController2 = TextEditingController(); //cho textfield 2 neu co

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: colorBar,

        onTap: (value){
          setState(() {
            selectedIndex=value;

            switch (selectedIndex){
              case 0:
                {
                  //neu bam home
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
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
              case 2:{
                //neu bam add
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
            label: '$firstPage',
            backgroundColor: colorBar,
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: '$secondPage',
            backgroundColor: colorBar,
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: '$thirdPage',
            backgroundColor: colorBar,
          ),
        ],
      ),

      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 100),

            DropdownButton2(
              value: selectedCategory, //vat duoc chon
              items: earningCategories.map((category) =>
                  DropdownMenuItem<
                      String>( //doi list<string> thanh list dropdownmenuitem
                    value: category, //tham so dropdownmenuitem
                    child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 15,
                        )
                    ),
                  )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value as String; //no se dat selectedItem la vat vua duoc chon
                  //roi chinh value cua dropdownbutton2

                  if (selectedCategory == 'Trả tiền vay') {
                    secondaryTextField =
                    true; //xuat hien textfield thu 2 de nhap tien lai
                  }
                  else {
                    secondaryTextField = false;
                  }
                }
                );
              },
            ),

            Container( //wrap trong container
                width: 200,
                child: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: 'Số tiền đã chi',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (double.tryParse(value) == null) {
                        // xoa text field neu nhu khong phai la so
                        _textEditingController.clear();
                      }
                      else {
                        double intValue = double.parse(value);
                        if (intValue < 0) {
                          // Limit the value to the range of 0-100
                          _textEditingController.text = 0.toString();
                        }
                        else {
                          earnedMoney = double.parse(value);
                        }
                      }
                    });
                  },
                )),

            if (secondaryTextField) //neu bool secondary text field la dung thi moi hien textfield
              Container( //wrap trong container
                  width: 200,
                  child: TextField(
                    controller: _textEditingController2,
                    decoration: InputDecoration(
                      hintText: 'Lãi (%)',
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        if (double.tryParse(value) == null) {
                          // xoa text field neu nhu khong phai la so
                          _textEditingController2.clear();
                        }
                        else {
                          double intValue = double.parse(value);
                          if (intValue < 0 || intValue > 100) {
                            // Limit the value to the range of 0-100
                            _textEditingController2.text = intValue.clamp(0, 100)
                                .toString();
                          }
                          else {
                            optionalFee = value as double;
                          }
                        }
                      });
                    },
                  )),

            SizedBox(height: 50), // thêm khoảng trăng giữa 2 widget//number-

            IconButton(onPressed: () {
              addEarning(earnedMoney, selectedCategory, earnings, context); //lamda functikon
              reset(_textEditingController,_textEditingController2,context); //reset lai cac o so sau khi bam add
            }, icon: Icon(Icons.add),
              color: Colors.green,
            ), //them button de add spending// only text box

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text("Thu vào: ", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),),
                Text("$earned VNĐ", style: TextStyle(color: Colors.green, fontSize: 20),)
            ]),

            
            SizedBox(height: 50),

            Expanded(
              child: ListView.builder(
                itemCount: earnings.length,
                itemBuilder: (context, i) {
                  return EarningItem(earning: earnings[i]);
                },
              ),
            ),


          ],
        ),
      ),
    );
  }
}