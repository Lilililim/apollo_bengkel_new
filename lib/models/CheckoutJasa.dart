/// class model untuk field [current_checkout_items] di firestore
class CheckoutJasa {
  CheckoutJasa({
    required this.itemId,
    required this.amount,
    required this.tanggal,
  });

  factory CheckoutJasa.fromJSON(Map<String, dynamic> map) => CheckoutJasa(
        itemId: map['item_id'],
        amount: map['amount'],
        tanggal: map['tanggaljs'],
      );

  Map<String, dynamic> toJSON() => {
        'item_id': itemId,
        'amount': amount,
        'tanggaljs': tanggal,
      };

  String itemId;
  int amount;
  int tanggal;
}