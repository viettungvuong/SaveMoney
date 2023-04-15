import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:selection_menu/components_configurations.dart';
import 'package:selection_menu/selection_menu.dart';
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

            SelectionMenu<String>(
              menuSizeConfiguration: const MenuSizeConfiguration(
                // min, max Width and min, max Height, all must be provided in
                // either fractions, pixels or mixed.

                maxHeightFraction: 0.1,
                // Maximum Fraction of screen height that the menu should take.
                //
                // Fractions mean the percentage of the screen width or height.
                //
                // Defaults to null.
                //
                // maxWidthFraction, minWidthFraction, minHeightFraction are similar.
                maxWidthFraction: 0.1,

                minWidth: 10,
                // Defaults to null. These are flutter's logical pixel values.
                //
                // maxWidth, minHeight, maxHeight are similar.
                // These values take preference over the fraction based counterparts,
                // when size is calculated.
                minHeight: 5,

                width: 10,
                height: 5,

                enforceMinWidthToMatchTrigger: true,
                // Defaults to false,
                // enforceMaxWidthToMatchButton is similar.

                requestConstantHeight: true,

                // There are many other important properties, see the main.dart
                // file or the API docs.
              ),

              itemsList: categories,

              onItemSelected: (String selectedItem) // truyền argument
              { // khi select một item
                print(selectedItem);
              },

              itemBuilder: (BuildContext context, String item, OnItemTapped onItemTapped)
              { // trả về thứ gì
                if (item=='Eating'){
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fastfood),
                      Text('$item'),
                    ],
                  );
                }
                else if (item=='Drinking'){
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_food_beverage),
                      Text('$item'),
                    ],
                  );
                }
                else if (item=='Shopping'){
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart),
                      Text('$item'),
                    ],
                  );
                }
                else if (item=='Fines'){
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_police),
                      Text('$item'),
                    ],
                  );
                }
                else if (item=='Mandatory Fees'){
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.electrical_services),
                      Text('$item'),
                    ],
                  );
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    Text('$item'),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}