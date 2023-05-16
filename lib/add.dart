import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_money/spending.dart';
import 'package:selection_menu/components_configurations.dart';
import 'package:selection_menu/selection_menu.dart';
import 'main.dart';

List<String> spendingCategories=['Ăn uống','Mua sắm','Tiền thuê nhà','Tiền học phí','Trả tiền vay','Đóng phạt','Du lịch','Khác']; //danh sach cac loai tieu tien

void addSpending(double spentMoney, String? selectedCategory, List<Spending> spendings){ //them chi tieu
  Spending newSpending;
  if (selectedCategory!=null)
       newSpending = Spending(spentMoney,typeOfSpending: selectedCategory); //day la cach dung optional parameter
  else
       newSpending = Spending(spentMoney);
  spendings.add(newSpending);
}

class AddSpending extends StatefulWidget{
  const AddSpending({super.key});

  @override
  State<AddSpending> createState() => _AddPageState();
}

class _AddPageState extends State<AddSpending>{
  double spentMoney=0, optionalFee=0;
  String? selectedCategory;
  bool secondaryTextField = false;

  final TextEditingController _textEditingController = TextEditingController(); //textcontroller de dieu khien data tu textfield

  @override
  Widget build(BuildContext context) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
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
        child: Column(
          children: <Widget>[
            SizedBox(height: 100),

            DropdownButton2(
              value: selectedCategory, //vat duoc chon
              items: spendingCategories.map((category) => DropdownMenuItem<String>( //doi list<string> thanh list dropdownmenuitem
                value: category, //tham so dropdownmenuitem
                child:  Text(
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

                  if (selectedCategory=='Trả tiền vay'){
                    secondaryTextField=true; //xuat hien textfield thu 2 de nhap tien lai
                  }
                  else{
                    secondaryTextField=false;
                  }
                }
                );
              },
            ),

            Container( //wrap trong container
              width: 200,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Số tiền đã chi',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                onChanged: (value){
                  setState(() {
                    spentMoney=value as double;
                  });
                },
            )),

            if (secondaryTextField) //neu bool secondary text field la dung thi moi hien textfield
              Container( //wrap trong container
                  width: 200,
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: 'Lãi (%)',
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    onChanged: (value){
                      setState(() {
                          if (int.tryParse(value) == null) {
                            // xoa text field neu nhu khong phai la so
                            _textEditingController.clear();
                          } else {
                            int intValue = int.parse(value);
                            if (intValue < 0 || intValue > 100) {
                              // Limit the value to the range of 0-100
                              _textEditingController.text = intValue.clamp(0, 100).toString();
                              optionalFee=value as double;
                            }
                          }
                      });
                    },
                  )),

            SizedBox(height: 300), // thêm khoảng trăng giữa 2 widget//number-

            IconButton(onPressed: () {
              addSpending(spentMoney, selectedCategory, spendings); //lamda functikon
            }, icon: Icon(Icons.add)), //them button de add spending// only text box

          ],
        ),
      ),
    );
  }
}