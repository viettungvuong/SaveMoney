class Spending{
  int? spentMoney;

  String? typeOfSpending;

  Spending(int spentMoney, String typeOfSpending){
    this.spentMoney=spentMoney;
    this.typeOfSpending=typeOfSpending;
  }

  int? getMoney(){
    return spentMoney;
  }
}