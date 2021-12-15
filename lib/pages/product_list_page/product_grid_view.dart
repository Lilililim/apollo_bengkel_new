import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/Product.dart';
import 'package:apollo_bengkel/pages/product_list_page/paket_product_tile.dart';
import 'package:apollo_bengkel/pages/product_list_page/product_tile.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductGridView extends StatefulWidget {
  final KategoriProductListPage kategoriProductListPage;

  ProductGridView({
    required this.kategoriProductListPage,
  });

  @override
  _ProductGridViewState createState() => _ProductGridViewState(
        kategoriProductListPage: kategoriProductListPage,
      );
}

class _ProductGridViewState extends State<ProductGridView> {
  _ProductGridViewState({
    required this.kategoriProductListPage,
  });

  final KategoriProductListPage kategoriProductListPage;
  var _products = Future<List<Product>>.value([]);

  /// Converter kategori ke string
  String? _kategoriProductListPageToString(
    KategoriProductListPage kategoriProductListPage,
  ) {
    var map = <KategoriProductListPage, String>{
      KategoriProductListPage.All: 'all',
      KategoriProductListPage.Oli: 'oli',
      KategoriProductListPage.Ban: 'ban',
      KategoriProductListPage.Grease_cvt: 'grease_cvt',
      KategoriProductListPage.Oli_gardan: 'oli_gardan',
    };

    return map[kategoriProductListPage];
  }

  Future<List<Product>> _getProducts() async {
    List<Product> products = [];
    QuerySnapshot<Map<String, dynamic>> snapshot;
    var collection = firestore.collection('/product');

    /// jika user ingin melihat semua product:
    if (kategoriProductListPage == KategoriProductListPage.All) {
      snapshot = await collection.get();
    }

    /// jika user ingin melihat product kategori tertentu
    else {
      var stringifiedKategori =
          _kategoriProductListPageToString(kategoriProductListPage)!;

      print('sedang di kategori: $stringifiedKategori');

      snapshot = await collection
          .where('category_pr', isEqualTo: stringifiedKategori)
          .get();
    }

    print('snapshot length => ${snapshot.docs.length}');
    products = snapshot.docs.map((doc) {
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

  /*SliverGridDelegate _getSliverGridDelegate() {
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
  }*/

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
