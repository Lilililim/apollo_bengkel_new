enum KategoriJasa {
  Jasa_ban,
  Jasa_oli,
  Jasa_injeksi,
  Jasa_cvt,
}

class Jasa {
  final KategoriJasa kategoriJasa;
  final String id, namajs, photoNamejs, deskripsijs;
  final num hargajs;
  final num promojs;

  Jasa({
    required this.id,
    required this.namajs,
    required this.kategoriJasa,
    required this.deskripsijs,
    required this.photoNamejs,
    required this.hargajs,
    required this.promojs,
  });

  factory Jasa.fromJSON(Map<String, dynamic> map) {
    return Jasa(
      id: map['id'],
      namajs: map['nama_js'],
      deskripsijs: map['deskripsi_js'],
      hargajs: map['harga_js'],
      photoNamejs: map['photo_js'],
      kategoriJasa: stringToKategori(map['category_js']),
      promojs: map['promo_js'],
    );
  }

  static KategoriJasa stringToKategori(String kategori) {
    var kategoriMap = <String, KategoriJasa>{
      'jasa_ban': KategoriJasa.Jasa_ban,
      'jasa_oli': KategoriJasa.Jasa_oli,
      'jasa_injeksi': KategoriJasa.Jasa_injeksi,
      'jasa_cvt': KategoriJasa.Jasa_cvt,
    };

    if (!kategoriMap.keys.toList().any((e) => e == kategori)) {
      throw Error.safeToString(
        'invalid kategori, must be one if these: ${kategoriMap.keys}',
      );
    }

    return kategoriMap[kategori]!;
  }

  static String kategoriToString(KategoriJasa kategoriJasa) {
    var kategoriMap = <KategoriJasa, String>{
      KategoriJasa.Jasa_ban: 'jasa_ban',
      KategoriJasa.Jasa_oli: 'jasa_oli',
      KategoriJasa.Jasa_cvt: 'jasa_cvt',
      KategoriJasa.Jasa_injeksi: 'jasa_injeksi',
    };

    if (!kategoriMap.keys.toList().any((e) => e == kategoriJasa)) {
      throw Error.safeToString(
        'invalid kategori, must be one if these: ${kategoriMap.keys.map((e) => e.toString())}',
      );
    }

    return kategoriMap[kategoriJasa]!;
  }
}
