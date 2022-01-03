/// class model untuk field [current_checkout_items] di firestore
class CheckoutJasa {
  CheckoutJasa({
    required this.itemId,
    required this.amount,
    required this.tanggal,
    //required this.antrian,
    //required this.total,
  });

  factory CheckoutJasa.fromJSON(Map<String, dynamic> map) => CheckoutJasa(
        itemId: map['item_id'],
        amount: map['amount'],
        tanggal: map['tanggaljs'],
        //antrian: map['no_antrian'],
        //total: map['totalharga'],
      );

  Map<String, dynamic> toJSON() => {
        'item_id': itemId,
        'amount': amount,
        'tanggaljs': tanggal,
        //'no_antrian': antrian,
        //'totalharga': total,
      };

  String itemId;
  int amount;
  int tanggal;
  //int antrian;
  //int: total;
}