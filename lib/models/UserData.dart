import 'package:apollo_bengkel/models/CheckoutItem.dart';
import 'package:apollo_bengkel/models/CheckoutJasa.dart';

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
          .toList()
      ..checkoutJasa = (map['current_checkout_jasa'] as List<dynamic>)
          .map((e) => CheckoutJasa.fromJSON(e))
          .toList();
  String? id;
  final String email;
  String name;
  String noHp;
  String alamat;
  String? photoURL;
  List<CheckoutItem> checkoutItems = [];
  List<CheckoutJasa> checkoutJasa = [];

  Map<String, dynamic> toJSON() {
    return {
      'email': this.email,
      'name': this.name,
      'no_hp': this.noHp,
      'alamat': this.alamat,
      'current_checkout_items': checkoutItems,
      'current_checkout_jasa': checkoutJasa,
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
      'current_checkout_jasa': [],
      'photo_url': null,
    };
  }
}
