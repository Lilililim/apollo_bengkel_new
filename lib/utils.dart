import 'package:apollo_bengkel/pages/product_list_page/product_list_page.dart';
import 'package:intl/intl.dart';

/// untuk kategori di page [ProductListPage]
enum KategoriProductListPage {
  All,
  Ban,
  Oli,
  Grease_cvt,
  Oli_gardan,
  Jasa_oli,
  Jasa_injeksi,
  Jasa_ban,
  Jasa_CVT,
}

/// untuk index tabview di page [ProductListPage]
int? kategoriToInt(KategoriProductListPage kategoriProduk) {
  return <KategoriProductListPage, int>{
    KategoriProductListPage.All: 0,
    KategoriProductListPage.Oli: 1,
    KategoriProductListPage.Ban: 2,
    KategoriProductListPage.Grease_cvt: 3,
    KategoriProductListPage.Oli_gardan: 4,
    KategoriProductListPage.Jasa_oli: 5,
    KategoriProductListPage.Jasa_ban: 6,
    KategoriProductListPage.Jasa_injeksi: 7,
    KategoriProductListPage.Jasa_CVT: 8,
  }[kategoriProduk];
}

var rupiahFormatter = NumberFormat.simpleCurrency(
  locale: 'id_ID',
);

enum Bank {
  BNI,
  BCA,
}

enum PaymentMethod {
  VirtualAccount,
  Cash,
}
