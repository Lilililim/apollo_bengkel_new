import 'package:apollo_bengkel/pages/product_list_page/product_list_page.dart';
import 'package:apollo_bengkel/pages/jasa_list_page/jasa_list_page.dart';
import 'package:intl/intl.dart';

/// untuk kategori di page [ProductListPage]
enum KategoriProductListPage {
  All,
  Ban,
  Oli,
  Grease_cvt,
  Oli_gardan,
}
enum KategoriJasaListPage {
  //Alljs,
  Jasa_oli,
  Jasa_injeksi,
  Jasa_ban,
  Jasa_CVT,
}
/*enum KategoriJasaListPage { 
  Jasa_oli,
  Jasa_injeksi,
  Jasa_ban,
  Jasa_CVT,
}*/
/// untuk index tabview di page [ProductListPage]
int? kategoriToInt(KategoriProductListPage kategoriProduk) {
  return <KategoriProductListPage, int>{
    KategoriProductListPage.All: 0,
    KategoriProductListPage.Oli: 1,
    KategoriProductListPage.Ban: 2,
    KategoriProductListPage.Grease_cvt: 3,
    KategoriProductListPage.Oli_gardan: 4,
    /*KategoriProductListPage.Jasa_oli: 5,
    KategoriProductListPage.Jasa_ban: 6,
    KategoriProductListPage.Jasa_injeksi: 7,
    KategoriProductListPage.Jasa_CVT: 8,*/
  }[kategoriProduk];
}
int? getJasaIndex(KategoriJasaListPage kategoriJasa) {
  return <KategoriJasaListPage, int>{
    //KategoriJasaListPage.Alljs: 0,
    KategoriJasaListPage.Jasa_oli: 0,
    KategoriJasaListPage.Jasa_ban: 1,
    KategoriJasaListPage.Jasa_injeksi: 2,
    KategoriJasaListPage.Jasa_CVT: 3,
  }[kategoriJasa];
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
