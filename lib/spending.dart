import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:save_money/add.dart';

import 'main.dart';

abstract class Money{
  double? amount;
  String? type;
  double? getMoney(){
    return amount;
  }
  Money(double amount, {String type='Normal'}){
    this.amount=amount;
    this.type=type;
  }
}

class Spending extends Money{
  Spending(super.amount, {String type='Normal'});

  @override
  double? amount;

  @override
  String? type;

}

class Earning extends Money{
  @override
  double? amount;

  @override
  String? type;

  Earning(super.amount, {String type='Normal'});
}

abstract class AC<T> {
  void add(double spentMoney, String? selectedCategory, List<T> list, BuildContext context) {
    assert(T is Money); //dam bao T deu inherit tu abstract class Money
    T newT;
    if (selectedCategory!=null){
      if (T is Spending){
        newT = Spending(spentMoney,type: selectedCategory) as T; //day la cach dung optional parameter
      }
      else{
        newT = Earning(spentMoney,type: selectedCategory) as T; //day la cach dung optional parameter
      }
    }
    else{
      if (T is Spending){
        newT = Spending(spentMoney) as T; //day la cach dung optional parameter
      }
      else{
        newT = Earning(spentMoney) as T; //day la cach dung optional parameter
      }
    }
    list.add(newT);
    if (T is Spending){
      spent += (newT as Spending).getMoney()!;
    }
    else{
      earned += (newT as Spending).getMoney()!;
    }
    addToDatabase(newT, database!); //dau ! o cuoi la null check
    //bay gio ta phai ket noi voi firebase o day
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Thêm thành công"),
    ));
  }

  void sort(List<T> list){ //item nay de dai dien hien thi mot cái spending
    assert(T is Money);
    if (T is Spending){
      list.sort((T a , T b) => ((a as Spending).amount=0 as double).compareTo((b as Spending).amount=0));
    }
    else{
      list.sort((T a , T b) => ((a as Earning).amount=0 as double).compareTo((b as Earning).amount=0));
    }
  }

  void addToDatabase(T t, FirebaseFirestore db){
    String collectionName;
    assert(T is Money);
    if (t is Spending){
      collectionName=userId!+'spent';
      final spendingString = {
        "amount": (t as Spending).amount,
        "type": (t as Spending).type.toString(),
      };

      db
          .collection(collectionName??"")
          .add(spendingString).then((documentSnapshot) =>
          print("Added Data with ID: ${documentSnapshot.id}"));; //them vao firestore database
      //dung add de no dat ten doc la mot random id
    }
    else{ //neu la earning
      collectionName=userId!+'earned';
      final earningString = {
        "amount": (t as Earning).amount,
        "type": (t as Earning).type.toString(),
      };

      db
          .collection(collectionName??"")
          .add(earningString).then((documentSnapshot) =>
          print("Added Data with ID: ${documentSnapshot.id}"));; //them vao firestore database
      //dung add de no dat ten doc la mot random id
    }
  }

}



//toi uu chi tieu sao de dat duoc chenh lech giua chi va thu la = diff
void optimizeSpendingToDiff(List<Spending> spendings, double diff){
  //ta se khong the cat giam Tien thue nha, Tien hoc phi, Tien phat
  //nen ta chi cat giam nhung cai nhu Du lich, An uong, Mua sam
  List<Spending> temp=spendings;
  temp.sort((Spending a, Spending b) => (a.type!).compareTo(b.type!));
  //tao list tam de xu ly bang cach sort theo type of spending
  //de cac spending giong nhau se lien ke nhau
}

//neu chi nhieu hon thu vao, tim ra can cat giam bao nhieu chi tieu de thu vao nhieu hon chi tieu
void optimizeSpendingToPositive(List<Spending> spendings){

}

IconData getIcon(Spending spending){
  if (spending.type==spendingCategories[0]){
    return Icons.fastfood;
  }
  else if (spending.type==spendingCategories[1]){
    return Icons.shopping_cart;
  }
  else if (spending.type==spendingCategories[2]){
    return Icons.house;
  }
  else if (spending.type==spendingCategories[3]){
    return Icons.school;
  }
  else if (spending.type==spendingCategories[4]){
    return Icons.attach_money;
  }
  else if (spending.type==spendingCategories[5]){
    return Icons.policy;
  }
  else if (spending.type==spendingCategories[6]){
    return Icons.travel_explore;
  }
  else{
    return Icons.money;
  }

}

class SpendingItem extends StatelessWidget {
  final Spending spending;

  const SpendingItem({
    Key? key,
    required this.spending, //bat buoc phai co
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            Icon(
              getIcon(spending), //lay icon phu thuoc vao spending
              color: Colors.yellow[700],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Số tiền ${spending.getMoney()}',
                ),
                Text(
                  '${spending.type}'
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
