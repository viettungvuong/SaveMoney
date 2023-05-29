import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:save_money/add.dart';

import 'income.dart';
import 'main.dart';

abstract class Money{
  double? amount;
  String? type;
  double? getMoney();
  Money(double amount, {String type='Normal'});
}

class Spending implements Money{
  @override
  Money(double amount, {String type='Normal'}){
    this.amount=amount;
    this.type=type;
  }

  @override
  double? amount;

  @override
  String? type;

  @override
  double? getMoney(){
    return amount;
  }

  Spending(double amount, {String type='Normal'}){
    this.amount=amount;
    this.type=type;
  }
}

class Earning implements Money{
  @override
  Money(double amount, {String type='Normal'}){
    this.amount=amount;
    this.type=type;
  }

  @override
  double? amount;

  @override
  String? type;

  @override
  double? getMoney(){
    return amount;
  }

  Earning(double amount, {String type='Normal'}){
    this.amount=amount;
    this.type=type;
  }
}

void addSpending(double spentMoney, String? selectedCategory, List<Spending> list, BuildContext context){
  Spending newSpending;
  if (selectedCategory!=null){
    newSpending = Spending(spentMoney,type: selectedCategory); //day la cach dung optional parameter
  }
  else{
    newSpending = Spending(spentMoney);
  }
  list.add(newSpending);
  spent+=spentMoney;
  addSpendingToDatabase(newSpending, database!); //dau ! o cuoi la null check
  //bay gio ta phai ket noi voi firebase o day
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("Thêm thành công"),
  ));
}

void addEarning(double earnedMoney, String? selectedCategory, List<Earning> list, BuildContext context){
  Earning newEarning;
  if (selectedCategory!=null){
    newEarning = Earning(earnedMoney,type: selectedCategory); //day la cach dung optional parameter
  }
  else{
    newEarning = Earning(earnedMoney);
  }
  list.add(newEarning);
  earned+=earnedMoney;
  addEarningToDatabase(newEarning, database!); //dau ! o cuoi la null check

  //bay gio ta phai ket noi voi firebase o day
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("Thêm thành công"),
  ));
}


void sortSpending(List<Spending> list){
  list.sort((Spending a , Spending b) => ((a).amount=0 as double).compareTo((b).amount=0));
}

void sortEarning(List<Earning> list){
  list.sort((Earning a , Earning b) => ((a).amount=0 as double).compareTo((b).amount=0));
}

void addSpendingToDatabase(Spending spending, FirebaseFirestore db){
  String collectionName;
  collectionName=userId!+'spent';
  final spendingString = {
      "amount": spending.amount,
      "type": spending.type.toString(),
  };

  db
        .collection(collectionName??"")
        .add(spendingString).then((documentSnapshot) =>
        print("Added Data with ID: ${documentSnapshot.id}"));; //them vao firestore database
    //dung add de no dat ten doc la mot random id
}

void addEarningToDatabase(Earning earning, FirebaseFirestore db){
  String collectionName;
  collectionName=userId!+'earned';
  final earningString = {
    "amount": earning.amount,
    "type": earning.type.toString(),
  };

  db
      .collection(collectionName??"")
      .add(earningString).then((documentSnapshot) =>
      print("Added Data with ID: ${documentSnapshot.id}"));; //them vao firestore database
  //dung add de no dat ten doc la mot random id
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

IconData getIcon2(Earning earning){
  if (earning.type==earningCategories[0]){
    return Icons.fastfood;
  }
  else if (earning.type==earningCategories[1]){
    return Icons.shopping_cart;
  }
  else if (earning.type==earningCategories[2]){
    return Icons.house;
  }
  else if (earning.type==earningCategories[3]){
    return Icons.school;
  }
  else if (earning.type==earningCategories[4]){
    return Icons.attach_money;
  }
  else if (earning.type==earningCategories[5]){
    return Icons.policy;
  }
  else if (earning.type==earningCategories[6]){
    return Icons.travel_explore;
  }
  else{
    return Icons.money;
  }

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

class EarningItem extends StatelessWidget {
  final Earning earning;

  const EarningItem({
    Key? key,
    required this.earning, //bat buoc phai co
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
              getIcon2(earning), //lay icon phu thuoc vao spending
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
                  'Số tiền ${earning.getMoney()}',
                ),
                Text(
                    '${earning.type}'
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}