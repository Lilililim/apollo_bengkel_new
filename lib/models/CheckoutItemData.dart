import 'package:apollo_bengkel/models/Product.dart';
import 'package:apollo_bengkel/models/Jasa.dart';

/// model data untuk checkout item yang data lengkapnya sudah diambil
class CheckoutItemData {
  CheckoutItemData({
    required this.product,
    required this.amount,
    this.photoDownloadURL = '',
  });

  final Product product;
  String photoDownloadURL = '';
  int amount;
}

class CheckoutItemJasa {
  CheckoutItemJasa({
    required this.jasa,
    required this.amount,
    required this.tanggal,
    //required this.antrian,
    this.photoDownloadURL = '',
  });

  final Jasa jasa;
  String photoDownloadURL = '';
  int amount;
  int tanggal;
  //int antrian;
}
