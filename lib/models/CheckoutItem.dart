/// class model untuk field [current_checkout_items] di firestore
class CheckoutItem {
  CheckoutItem({
    required this.itemId,
    required this.amount,
  });

  factory CheckoutItem.fromJSON(Map<String, dynamic> map) => CheckoutItem(
        itemId: map['item_id'],
        amount: map['amount'],
      );

  Map<String, dynamic> toJSON() => {
        'item_id': itemId,
        'amount': amount,
      };

  String itemId;
  int amount;
}
