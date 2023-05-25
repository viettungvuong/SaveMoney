import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Spending{
  double? spentMoney;

  String? typeOfSpending;

  Spending(double spentMoney, {String typeOfSpending='Normal'}){
    this.spentMoney=spentMoney;
    this.typeOfSpending=typeOfSpending;
  }

  double? getMoney(){
    return spentMoney;
  }
}

void sortSpending(List<Spending> spendings){ //item nay de dai dien hien thi mot cái spending
  spendings.sort((Spending a, Spending b) => (a.spentMoney=0 as double).compareTo(b.spentMoney=0));
  //nma de coi lai quick sort
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
              Icons.star,
              color: Colors.yellow[700],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}
