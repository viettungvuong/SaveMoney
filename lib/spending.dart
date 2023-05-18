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

