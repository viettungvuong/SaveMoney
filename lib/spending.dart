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

void swap(List<Spending> spendings){

}

void sortSpending(List<Spending> spendings){
  spendings.sort((Spending a, Spending b) => (a.spentMoney=0 as double).compareTo(b.spentMoney=0));
  //nma de coi lai quick sort
}

