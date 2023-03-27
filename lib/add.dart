import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'main.dart';

List<String> categories=['Eating','Drinking','Shopping','Fines','Mandatory Fees','Others']; //danh sach cac loai tieu tien

class AddSpending extends StatefulWidget{
  const AddSpending({super.key});

  @override
  State<AddSpending> createState() => _AddPageState();
}

class _AddPageState extends State<AddSpending>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}