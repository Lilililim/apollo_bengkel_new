enum KategoriProduct {
  //ubah
  Oli,
  Oli_gardan,
  Grease_cvt,
  Ban,
  Jasa_ban,
  Jasa_oli,
  Jasa_injeksi,
  Jasa_cvt,
}

class Product {
  //tambah stock?
  final KategoriProduct kategoriProduct, kategoriJasa;
  final String id, namapr, photoNamepr, deskripsipr, namajs, photoNamejs, deskripsijs;
  final num hargapr, stockpr, hargajs;
  final num promo, promojs;
  String? jasaId = '';

  Product({
    required this.id,
    required this.namapr,
    required this.kategoriProduct,
    required this.deskripsipr,
    required this.photoNamepr,
    required this.hargapr,
    required this.promo,
    required this.stockpr,
    required this.namajs,
    required this.kategoriJasa,
    required this.deskripsijs,
    required this.photoNamejs,
    required this.hargajs,
    required this.promojs,
    this.jasaId,
  });

  factory Product.fromJSON(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      namapr: map['nama_pr'],
      deskripsipr: map['deskripsi_pr'],
      hargapr: map['harga_pr'],
      photoNamepr: map['photo_name'],
      kategoriProduct: stringToKategori(map['category_pr']),
      promo: map['promo'],
      stockpr: map['stock_pr'],
      jasaId: map['jasa_id'],
      namajs: map['nama_js'],
      deskripsijs: map['deskripsi_js'],
      hargajs: map['harga_js'],
      photoNamejs: map['photo_js'],
      kategoriJasa: stringToKategori(map['category_js']),
      promojs: map['promo_js'],
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
