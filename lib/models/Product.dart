enum KategoriProduct {
  //ubah
  Daging,
  Sayur,
  Buah,
  Rempah,
  Paket,
}

class Product {
  //ubah
  final KategoriProduct kategoriProduct;
  final String id, nama, photoName, deskripsi;
  final num harga;
  final num promo;
  String? recipeId = '';
  List<String> bahan = [], langkah = [];

  Product({
    //ubah
    required this.id,
    required this.nama,
    required this.kategoriProduct,
    required this.deskripsi,
    required this.photoName,
    required this.harga,
    required this.promo,
    this.recipeId,
  });

  factory Product.fromJSON(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      nama: map['nama'],
      deskripsi: map['deskripsi'],
      harga: map['harga'],
      photoName: map['photo_name'],
      kategoriProduct: stringToKategori(map['category']),
      promo: map['promo'],
      recipeId: map['resep_id'],
    );
  }

  static KategoriProduct stringToKategori(String kategori) {
    var kategoriMap = <String, KategoriProduct>{
      //ubah
      'daging': KategoriProduct.Daging,
      'buah': KategoriProduct.Buah,
      'sayur': KategoriProduct.Sayur,
      'rempah': KategoriProduct.Rempah,
      'paket': KategoriProduct.Paket,
    };

    if (!kategoriMap.keys.toList().any((e) => e == kategori)) {
      throw Error.safeToString(
        'invalid kategori, must be one if these: ${kategoriMap.keys}',
      );
    }

    return kategoriMap[kategori]!;
  }

  static String kategoriToString(KategoriProduct kategoriProduct) {
    var kategoriMap = <KategoriProduct, String>{
      //ubah
      KategoriProduct.Daging: 'daging',
      KategoriProduct.Buah: 'buah',
      KategoriProduct.Sayur: 'sayur',
      KategoriProduct.Rempah: 'rempah',
      KategoriProduct.Paket: 'paket',
    };

    if (!kategoriMap.keys.toList().any((e) => e == kategoriProduct)) {
      throw Error.safeToString(
        'invalid kategori, must be one if these: ${kategoriMap.keys.map((e) => e.toString())}',
      );
    }

    return kategoriMap[kategoriProduct]!;
  }
}
