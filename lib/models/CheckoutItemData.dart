import 'package:apollo_bengkel/models/Product.dart';

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
