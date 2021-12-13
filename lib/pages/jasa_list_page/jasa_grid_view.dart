import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/Jasa.dart';
import 'package:apollo_bengkel/pages/jasa_list_page/paket_jasa_tile.dart';
import 'package:apollo_bengkel/pages/jasa_list_page/jasa_tile.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JasaGridView extends StatefulWidget {
  final KategoriProductListPage kategoriJasaListPage;

  JasaGridView({
    required this.kategoriJasaListPage,
  });

  @override
  _JasaGridViewState createState() => _JasaGridViewState(
        kategoriJasaListPage: kategoriJasaListPage,
      );
}

class _JasaGridViewState extends State<JasaGridView> {
  _JasaGridViewState({
    required this.kategoriJasaListPage,
  });

  final KategoriProductListPage kategoriJasaListPage;
  var _products = Future<List<Jasa>>.value([]);

  /// Converter kategori ke string
  String? _kategoriProductListPageToString(
    KategoriProductListPage kategoriProductListPage,
  ) {
    var map = <KategoriProductListPage, String>{
      KategoriProductListPage.All: 'all',
      KategoriProductListPage.Jasa_oli: 'jasa_oli',
      KategoriProductListPage.Jasa_ban: 'jasa_ban',
      KategoriProductListPage.Jasa_injeksi: 'jasa_injeksi',
      KategoriProductListPage.Jasa_CVT: 'jasa_cvt',
    };

    return map[kategoriProductListPage];
  }

  Future<List<Jasa>> _getProducts() async {
    List<Jasa> jasa = [];
    QuerySnapshot<Map<String, dynamic>> snapshot;
    var collection = firestore.collection('/jasa');

    /// jika user ingin melihat semua product:
    if (kategoriJasaListPage == KategoriProductListPage.All) {
      snapshot = await collection.get();
    }

    /// jika user ingin melihat product kategori tertentu
    else {
      var stringifiedKategori =
          _kategoriProductListPageToString(kategoriJasaListPage)!;

      print('sedang di kategori: $stringifiedKategori');

      snapshot = await collection
          .where('category_js', isEqualTo: stringifiedKategori)
          .get();
    }

    print('snapshot length => ${snapshot.docs.length}');
    jasa = snapshot.docs.map((doc) {
      var rawDoc = doc.data();
      var docData = <String, dynamic>{
        'id': doc.reference.id,
        ...rawDoc,
      };

      var product = Product.fromJSON(docData);

      return product;
    }).toList();

    return products;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _products = _getProducts();
    });
  }

  SliverGridDelegate _getSliverGridDelegate() {
    //jasa_oli harus diubah
    if (kategoriProductListPage == KategoriProductListPage.Jasa_oli) {
      return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.2 / 1,
      );
    }

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 5 / 9,
    );
  }

  bool _isPaket() {
    //jasa_oli harus diubah
    return kategoriProductListPage == KategoriProductListPage.Jasa_oli;
  }

  Future<void> _refreshItem() async {
    setState(() {
      _products = _getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _products,
      builder: (context, snapshot) {
        /// Jika selesai loading data
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Container(
              child: Text(
                'nothing here',
              ),
            );
          }

          /// jika datanya tidak null/kosong
          if (snapshot.hasData) {
            var products = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () {
                return _refreshItem();
              },
              child: GridView.builder(
                gridDelegate: _getSliverGridDelegate(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  if (products.length == 0) {
                    return Container(
                      child: Text(
                        'nothing here',
                      ),
                    );
                  }

                  if (_isPaket()) {
                    return PaketProductTile(
                      product: products[index],
                    );
                  }

                  return ProductTile(
                    product: products[index],
                  );
                },
              ),
            );
          }

          /// jika kosong
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Something Wrong !',
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                ),
                child: Center(
                  child: Text(
                    'Mengambil Data...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
