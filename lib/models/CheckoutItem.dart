/// class model untuk field [current_checkout_items] di firestore
class CheckoutItem {
  CheckoutItem({
    required this.itemId,
    required this.amount,
    //required this.total,
  });

  factory CheckoutItem.fromJSON(Map<String, dynamic> map) => CheckoutItem(
        itemId: map['item_id'],
        amount: map['amount'],
        //total: map['totalharga']
      );

  Map<String, dynamic> toJSON() => {
        'item_id': itemId,
        'amount': amount,
        //'totalharga': total,
      };

  String itemId;
  int amount;
  //int: total;
}