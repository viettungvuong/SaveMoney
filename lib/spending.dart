import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:save_money/add.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'income.dart';
import 'main.dart';

abstract class Money{
  int? amount;
  String? type;
  int? getMoney();
  DateTime? date;
  Money(int amount, DateTime date, {String type='Normal'});
}

class Spending implements Money{

  @override
  int? amount;

  @override
  String? type;

  @override
  DateTime? date;

  @override
  int? getMoney(){
    return amount;
  }

  Spending(int amount, DateTime date, {String type='Normal'}){
    this.amount=amount;
    this.type=type;
    this.date=date;
  }
}

class Earning implements Money{

  @override
  int? amount;

  @override
  String? type;

  @override
  DateTime? date;

  @override
  int? getMoney(){
    return amount;
  }

  Earning(int amount, DateTime date, {String type='Normal'}){
    this.amount=amount;
    this.type=type;
    this.date=date;
  }
}




void sortSpending(List<Spending> list){
  list.sort((Spending a , Spending b) => ((a).amount=0 as int).compareTo((b).amount=0));
}

void sortEarning(List<Earning> list){
  list.sort((Earning a , Earning b) => ((a).amount=0 as int).compareTo((b).amount=0));
}

void addSpendingToDatabase(Spending spending, FirebaseFirestore db){
  String collectionName;
  collectionName='spendings';
  final spendingString = {
      "amount": spending.amount,
      "type": spending.type.toString(),
      "day": spending.date!.day, //ngay
      "month": spending.date!.month,
      "year": spending.date!.year,
      "date": convertDateToString(now),
      "user": userId,
  };

  db
        .collection(collectionName??"")
        .add(spendingString).then((documentSnapshot) =>
        print("Added Data with ID: ${documentSnapshot.id}")); //them vao firestore database
    //dung add de no dat ten doc la mot random id
}

void addEarningToDatabase(Earning earning, FirebaseFirestore db){
  String collectionName;
  collectionName="earnings";
  final earningString = {
    "amount": earning.amount,
    "type": earning.type.toString(),
    "day": earning.date!.day, //ngay
    "month": earning.date!.month,
    "year": earning.date!.year,
    "date": convertDateToString(now),
    "user": userId,
  };

  db
      .collection(collectionName??"")
      .add(earningString).then((documentSnapshot) =>
      print("Added Data with ID: ${documentSnapshot.id}")); //them vao firestore database
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
    return Icons.work;
  }
  else if (earning.type==earningCategories[1]){
    return Icons.monetization_on;
  }
  else if (earning.type==earningCategories[2]){
    return Icons.house;
  }
  else if (earning.type==earningCategories[3]){
    return Icons.celebration;
  }
  else if (earning.type==earningCategories[4]){
    return Icons.card_giftcard;
  }
  else if (earning.type==earningCategories[5]){
    return Icons.keyboard_return;
  }
  else{
    return Icons.money;
  }
 //phai chinh lai no lay ra icon nao
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
              color: Colors.red,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Số tiền ${reformatNumber(spending.getMoney()!)} VNĐ',
                ),
                Text(
                  '${spending.type}'
                ),
                Text(
                  '${convertDateToString(spending.date!)}'
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
              getIcon2(earning), //lay icon phu thuoc vao earning
              color: Colors.green,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Số tiền ${reformatNumber(earning.getMoney()!)} VNĐ',
                ),
                Text(
                    '${earning.type}'
                ),
                Text(
                    '${convertDateToString(earning.date!)}'
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String reformatNumber(int money){
  if (money>=0&&money<=100)
    return money.toString();

  if (money>=-100&&money<100){
    return "-"+money.toString();
  }


  String moneyString=(money.abs()).toString();

  List<String> strings=[];

  int n=moneyString.length-1;
  for (int i=n; i>=0; i-=3){
    int start=max(i-2,0);
    int end=min(n+1,i+1);
    String s = moneyString.substring(start,end);
    strings.add(s);

    strings.add(',');
  }

  if (strings.elementAt(strings.length-1)==','){
    strings.removeAt(strings.length-1);
  }

  strings = List.from(strings.reversed);

  moneyString = strings.join();
  if (money<0){
    moneyString="-"+moneyString;
  }
  return moneyString;
  //no dang xuat nguoc
  //gio ta phai cho no xuat dung chieu
}

