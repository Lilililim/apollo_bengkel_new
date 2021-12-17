/// class model untuk field [current_checkout_items] di firestore
class CheckoutJasa {
  CheckoutJasa({
    required this.itemId,
    required this.amount,
  });

  factory CheckoutJasa.fromJSON(Map<String, dynamic> map) => CheckoutJasa(
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