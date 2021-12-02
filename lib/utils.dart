import 'package:apollo_bengkel/pages/product_list_page/product_list_page.dart';
import 'package:intl/intl.dart';

/// untuk kategori di page [ProductListPage]
enum KategoriProductListPage {
  All,
  Ban,
  Oli,
  Part,
  Lampu,
  Oli_gardan,
  Jasa_oli,
  Jasa_injeksi,
  Jasa_part,
  Jasa_ban,
  Jasa_CVT,
}

/// untuk index tabview di page [ProductListPage]
int? kategoriToInt(KategoriProductListPage kategoriProduk) {
  return <KategoriProductListPage, int>{
    KategoriProductListPage.All: 0,
    KategoriProductListPage.Ban: 1,
    KategoriProductListPage.Oli: 2,
    KategoriProductListPage.Part: 3,
    KategoriProductListPage.Lampu: 4,
    KategoriProductListPage.Oli_gardan: 5,
    KategoriProductListPage.Jasa_oli: 6,
    KategoriProductListPage.Jasa_injeksi: 7,
    KategoriProductListPage.Jasa_part: 8,
    KategoriProductListPage.Jasa_ban: 9,
    KategoriProductListPage.Jasa_CVT: 10,
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
