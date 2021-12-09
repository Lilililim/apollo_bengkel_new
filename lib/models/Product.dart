enum KategoriProduct {
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
  final KategoriProduct kategoriProduct; //kategoriJasa;
  final String id, namapr, photoNamepr, deskripsipr; //namajs, photoNamejs, deskripsijs;
  final num hargapr, stockpr; //hargajs;
  final num promo; //promojs;
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
   // required this.namajs,
   // required this.kategoriJasa,
   // required this.deskripsijs,
   // required this.photoNamejs,
   // required this.hargajs,
   // required this.promojs,
    this.jasaId,
  });

  factory Product.fromJSON(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      namapr: map['nama_pr'],
      deskripsipr: map['deskripsi_pr'],
      hargapr: map['harga_pr'],
      photoNamepr: map['photo_pr'],
      kategoriProduct: stringToKategori(map['category_pr']),
      promo: map['promo'],
      stockpr: map['stock_pr'],
      jasaId: map['jasa_id'],
      //namajs: map['nama_js'],
      //deskripsijs: map['deskripsi_js'],
      //hargajs: map['harga_js'],
      //photoNamejs: map['photo_js'],
      //kategoriJasa: stringToKategori(map['category_js']),
      //promojs: map['promo_js'],
    );
  }

  static KategoriProduct stringToKategori(String kategori) {
    var kategoriMap = <String, KategoriProduct>{
      'ban': KategoriProduct.Ban,
      'oli': KategoriProduct.Oli,
      'oli_gardan': KategoriProduct.Oli_gardan,
      'grease_cvt': KategoriProduct.Grease_cvt,
      'jasa_ban': KategoriProduct.Jasa_ban,
      'jasa_oli': KategoriProduct.Jasa_oli,
      'jasa_injeksi': KategoriProduct.Jasa_injeksi,
      'jasa_cvt': KategoriProduct.Jasa_cvt,
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
      KategoriProduct.Ban: 'ban',
      KategoriProduct.Oli: 'oli',
      KategoriProduct.Oli_gardan: 'oli_gardan',
      KategoriProduct.Grease_cvt: 'grease_cvt',
      KategoriProduct.Jasa_ban: 'jasa_ban',
      KategoriProduct.Jasa_oli: 'jasa_oli',
      KategoriProduct.Jasa_cvt: 'jasa_cvt',
      KategoriProduct.Jasa_injeksi: 'jasa_injeksi',
    };

    if (!kategoriMap.keys.toList().any((e) => e == kategoriProduct)) {
      throw Error.safeToString(
        'invalid kategori, must be one if these: ${kategoriMap.keys.map((e) => e.toString())}',
      );
    }

    return kategoriMap[kategoriProduct]!;
  }
}
