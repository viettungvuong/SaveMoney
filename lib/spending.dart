import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:save_money/add.dart';

import 'main.dart';

abstract class Money{
  double? amount;
  String? type;
  double? getMoney();
}

class Spending implements Money{
  Spending(double amount, {String type='Normal'}){
    this.amount=amount;
    this.type=type;
  }

  @override
  double? getMoney(){
    return amount;
  }

  @override
  double? amount;

  @override
  String? type;
}

class Earning implements Money{
  @override
  double? getMoney(){
    return amount;
  }

  @override
  double? amount;

  @override
  String? type;

  Earning(double amount, {String type='Normal'}){
    this.amount=amount;
    this.type=type;
  }
}

void sortSpending(List<Spending> spendings){ //item nay de dai dien hien thi mot cái spending
  spendings.sort((Spending a, Spending b) => (a.amount=0 as double).compareTo(b.amount=0));
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
