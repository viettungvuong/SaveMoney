import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_money/spending.dart';
import 'package:selection_menu/components_configurations.dart';
import 'package:selection_menu/selection_menu.dart';
import 'analytics.dart';
import 'income.dart';
import 'main.dart';

List<String> spendingCategories = [
  'Ăn uống',
  'Mua sắm',
  'Tiền thuê nhà',
  'Tiền học phí',
  'Trả tiền vay',
  'Đóng phạt',
  'Du lịch',
  'Khác'
]; //danh sach cac loai tieu tien

void reset(TextEditingController valueController,
    TextEditingController? valueController2, BuildContext context) {
  valueController.text = '';
  if (valueController2 != null) valueController2.text = '';
  /*Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddSpending()),
  );*/
}

class AddSpending extends StatefulWidget {
  const AddSpending({super.key});

  @override
  State<AddSpending> createState() => _AddPageState();
}

class _AddPageState extends State<AddSpending> {


  int spentMoney = 0, optionalFee = 0;
  String selectedCategory = spendingCategories[0];
  bool secondaryTextField = false;

  final TextEditingController _textEditingController =
      TextEditingController(); //textcontroller de dieu khien data tu textfield
  final TextEditingController _textEditingController2 =
      TextEditingController(); //cho textfield 2 neu co

  Spending addSpending(int spentMoney, String? selectedCategory, List<Spending> list, BuildContext context){
    Spending newSpending;
    if (selectedCategory!=null){
      newSpending = Spending(spentMoney,now,type: selectedCategory); //day la cach dung optional parameter
    }
    else{
      newSpending = Spending(spentMoney,now);
    }

    setState(() {
      spent+=spentMoney;

    });

    addSpendingToDatabase(newSpending, database!); //dau ! o cuoi la null check
    //bay gio ta phai ket noi voi firebase o day
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Thêm thành công"),
    ));

    //ta sẽ thêm vào danh sách spending của ngày hôm nay
    if (spendingByDate[now]==null){
      spendingByDate[now]=[]; //initialize nếu null
    }
    spendingByDate[now]!.add(newSpending);

    totalSpentByDate[now]=calcTotalSpentDay(spendingByDate, now);

    return newSpending;
  }


  Future<void> filterSpending(List<Spending> list, String date) async {
    setState(() {
      list.clear();
    });
    String collectionName = userId! + "spent";
    await database
        ?.collection(collectionName)
        .where('date', isEqualTo: date)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          int amount = docSnapshot.data()['amount'];
          String typeOfSpending = docSnapshot.data()['type'];
          DateTime date = convertStringToDate(docSnapshot.data()['date']!);
          setState(() {
            Spending newSpending=new Spending(amount, date, type: typeOfSpending);
            list.add(newSpending);
            //thêm luôn vào list
            if (spendingByDate[date]==null){
              spendingByDate[date]=[]; //initialize nếu null
            }
            spendingByDate[date]!.add(newSpending);
          });
          print(amount);
          spent += amount; //them vao so tien da chi
        }
        totalSpentByDate[convertStringToDate(date)]=calcTotalSpentDay(spendingByDate, convertStringToDate(date));
      },
      onError: (e) => print("Lỗi: $e"),
    );
    print(list.length);
    //them await de doi no doc het xong roi moi ket thuc
  }

  String dateTimeStr=convertDateToString(now);

  @override
  Widget build(BuildContext context) {
    List<Spending> temp = spendings;
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 100),

            DropdownButton2(
              value: selectedCategory, //vat duoc chon
              items: spendingCategories
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
                  selectedCategory = value as String; //no se dat selectedItem la vat vua duoc chon
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
                    hintText: 'Số tiền đã chi',
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
                          spentMoney = int.parse(value);
                          _textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: _textEditingController.text.length));
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
                Spending newSpending=addSpending(spentMoney, selectedCategory, spendings,
                    context); //lamda functikon
                reset(_textEditingController, _textEditingController2,
                    context); //reset lai cac o so sau khi bam add
                setState(() {
                  if (dateTimeStr==convertDateToString(now)){
                    spendings.add(newSpending);
                  }
                });
                if (spendingByDate[now]==null){
                  spendingByDate[now]=[];
                }
                spendingByDate[now]!.add(newSpending);
                //thêm vào danh sách theo ngày
                FocusManager.instance.primaryFocus?.unfocus();
              },
              icon: Icon(Icons.add),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red),),
              label: Text('Thêm'),
            ), //them button de add spending// only text box

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                "Chi tiêu tháng: ",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                '${reformatNumber(spent)} VNĐ',
                style: TextStyle(color: Colors.red, fontSize: 20),
              )
            ]),

            SizedBox(height: 50),

            Container(
              margin: const EdgeInsets.only(left: 40.0, right: 40.0),
              child: DateTimePicker(
                dateMask: 'd-M-yyyy',
                firstDate: DateTime(2023),
                lastDate: DateTime(2100),
                initialValue: convertDateToString(now),
                dateLabelText: 'Ngày',
                onChanged: (val) => setState(()  {
                  dateTimeStr=reformatDate(val);
                  filterSpending(spendings, reformatDate(val));
                }),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: temp.length,
                itemBuilder: (context, i) {
                  return SpendingItem(spending: temp[i]);
                },
              ),
            ),
          ],
        ),
      ),



    );
  }
}

String reformatDate(String val){
  List<String> strings=val.split('-');

  for (int i=1; i<=2; i++){
    if (strings[i][0]=='0'){
      strings[i]=strings[i][1];
    }
  }

  strings=List.from(strings.reversed);
  return strings.join('-');
}
//co the dung proxy design pattern de luu lai cac list spending truoc day (do truy cap), van dung cung hashmap
