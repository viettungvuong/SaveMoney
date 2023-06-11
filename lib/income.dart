import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_money/analytics.dart';
import 'package:save_money/spending.dart';
import 'package:selection_menu/components_configurations.dart';
import 'package:selection_menu/selection_menu.dart';
import 'add.dart';
import 'main.dart';

List<String> earningCategories = [
  'Tiền lương',
  'Nhận lãi',
  'Tiền thuê nhà',
  'Học bổng',
  'Tặng',
  'Hoàn tiền',
  'Khác'
]; //danh sach cac loai tieu tien

void reset(TextEditingController valueController,
    TextEditingController? valueController2, BuildContext context) {
  valueController.text = '';
  if (valueController2 != null) valueController2.text = '';
  /*Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddEarning()),
  );*/
}

class AddEarning extends StatefulWidget {
  const AddEarning({super.key});

  @override
  State<AddEarning> createState() => _AddPageState();
}

class _AddPageState extends State<AddEarning> {
  List<Earning> temp = earnings;

  int earnedMoney = 0, optionalFee = 0;
  String selectedCategory = earningCategories[0];
  bool secondaryTextField = false;

  final TextEditingController _textEditingController =
      TextEditingController(); //textcontroller de dieu khien data tu textfield
  final TextEditingController _textEditingController2 =
      TextEditingController(); //cho textfield 2 neu co

  Earning addEarning(int earnedMoney, String? selectedCategory, List<Earning> list, BuildContext context){
    Earning newEarning;
    if (selectedCategory!=null){
      newEarning = Earning(earnedMoney,now,type: selectedCategory); //day la cach dung optional parameter
    }
    else{
      newEarning = Earning(earnedMoney,now);
    }

    setState(() {
      earned+=earnedMoney;

    });

    addEarningToDatabase(newEarning, database!); //dau ! o cuoi la null check

    //bay gio ta phai ket noi voi firebase o day
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Thêm thành công"),
    ));

    if (earningByDate[now]==null){
      earningByDate[now]=[]; //initialize nếu null
    }
    earningByDate[now]!.add(newEarning);

    return newEarning;
  }


  Future<void> filterEarning(List<Earning> list, String date) async {
    setState(() {
      list.clear();
    });
    String collectionName = userId! + "earned";
    await database
        ?.collection(collectionName)
        .where('date', isEqualTo: date)
        .get()
        .then(
          (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          int amount = docSnapshot.data()['amount'];
          String typeOfEarning = docSnapshot.data()['type'];
          int day=docSnapshot.data()['day']!;
          int month=docSnapshot.data()['month']!;
          int year=docSnapshot.data()['year']!;
          DateTime date = convertStringToDate(docSnapshot.data()['date']!);
          setState(() {
            Earning newEarning=new Earning(amount, date, type: typeOfEarning);
            list.add(newEarning);
            //thêm luôn vào list
            if (earningByDate[date]==null){
              earningByDate[date]=[]; //initialize nếu null
            }
            earningByDate[date]!.add(newEarning);
          });
          print(amount);
          earned += amount; //them vao so tien da chi
        }

        //tính toán số tiền đã chi vào ngày hôm đó
      },
      onError: (e) => print("Lỗi: $e"),
    );
    print(list.length);
    //them await de doi no doc het xong roi moi ket thuc
  }

  String dateTimeStr=convertDateToString(now);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[

            SizedBox(height: 100),

            DropdownButton2(
              value: selectedCategory, //vat duoc chon
              items: earningCategories
                  .map((category) => DropdownMenuItem<String>(
                        //doi list<string> thanh list dropdownmenuitem
                        value: category, //tham so dropdownmenuitem
                        child: Text(category,
                            style: TextStyle(
                              fontSize: 15,
                            )),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value
                      as String; //no se dat selectedItem la vat vua duoc chon
                  //roi chinh value cua dropdownbutton2

                  if (selectedCategory == 'Trả tiền vay') {
                    secondaryTextField =
                        true; //xuat hien textfield thu 2 de nhap tien lai
                  } else {
                    secondaryTextField = false;
                  }
                });
              },
            ),

            Container(
                //wrap trong container
                width: 200,
                child: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: 'Số tiền đã nhận',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (int.tryParse(value) == null) {
                        // xoa text field neu nhu khong phai la so
                        _textEditingController.clear();
                      } else {
                        int intValue = int.parse(value);
                        if (intValue < 0) {
                          // Limit the value to the range of 0-100
                          _textEditingController.text = 0.toString();
                        } else {
                          _textEditingController.text=reformatNumber(intValue);
                          _textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: _textEditingController.text.length));
                          earnedMoney = int.parse(value);
                        }
                      }
                    });
                  },
                )),

            if (secondaryTextField) //neu bool secondary text field la dung thi moi hien textfield
              Container(
                  //wrap trong container
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
                        } else {
                          double intValue = double.parse(value);
                          if (intValue < 0 || intValue > 100) {
                            // Limit the value to the range of 0-100
                            _textEditingController2.text =
                                intValue.clamp(0, 100).toString();
                          } else {
                            optionalFee = value as int;
                          }
                        }
                      });
                    },
                  )),

            SizedBox(height: 50), // thêm khoảng trăng giữa 2 widget//number-

            ElevatedButton.icon(
              onPressed: () {
                Earning newEarning=addEarning(earnedMoney, selectedCategory, earnings,
                    context); //lamda functikon
                reset(_textEditingController, _textEditingController2,
                    context); //reset lai cac o so sau khi bam add
                setState(() {
                  if (dateTimeStr==convertDateToString(now)){
                    earnings.add(newEarning);
                  }
                });
                if (earningByDate[now]==null){
                  earningByDate[now]=[];
                }
                earningByDate[now]!.add(newEarning);
                //thêm vào danh sách theo ngày
                FocusManager.instance.primaryFocus?.unfocus();
              },
              icon: Icon(Icons.add),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green),),
              label: Text('Thêm'),
            ), //them button de add spending// only text box

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                "Thu nhập tháng: ",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "${reformatNumber(earned)} VNĐ",
                style: TextStyle(color: Colors.green, fontSize: 20),
              )
            ]),

            SizedBox(height: 50),

            Container(
              margin: const EdgeInsets.only(left: 40.0, right: 40.0),
              child: DateTimePicker(
                dateMask: 'd-M-yyyy',
                firstDate: DateTime(2023),
                lastDate: DateTime(2100),
                dateLabelText: 'Ngày',
                initialValue: convertDateToString(now),
                onChanged: (val) => setState(()  { //setState o day luon
                  dateTimeStr=reformatDate(val);
                  filterEarning(earnings, reformatDate(val));
                }),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: temp.length,
                itemBuilder: (context, i) {
                  return EarningItem(earning: temp[i]);
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
