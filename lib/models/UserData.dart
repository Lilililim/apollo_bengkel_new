import 'package:apollo_bengkel/models/CheckoutItem.dart';

/// model data untuk collection [users] di firestore
class UserData {
  UserData({
    this.id,
    required this.email,
    required this.name,
    required this.noHp,
    required this.alamat,
    this.photoURL,
  });

  factory UserData.fromJSON(Map<String, dynamic> map) => UserData(
        id: map['id'],
        email: map['email'],
        name: map['name'],
        noHp: map['no_hp'],
        alamat: map['alamat'],
        photoURL: map['photo_url'],
      )..checkoutItems = (map['current_checkout_items'] as List<dynamic>)
          .map((e) => CheckoutItem.fromJSON(e))
          .toList();

  String? id;
  final String email;
  String name;
  String noHp;
  String alamat;
  String? photoURL;
  List<CheckoutItem> checkoutItems = [];

  Map<String, dynamic> toJSON() {
    return {
      'email': this.email,
      'name': this.name,
      'no_hp': this.noHp,
      'alamat': this.alamat,
      'current_checkout_items': checkoutItems,
      'photo_url': photoURL,
    };
  }

  /// untuk bikin data awal user di firestore
  Map<String, dynamic> forCreateToFirestore() {
    return {
      'email': this.email,
      'name': this.name,
      'no_hp': this.noHp,
      'alamat': this.alamat,
      'current_checkout_items': [],
      'photo_url': null,
    };
  }
}
