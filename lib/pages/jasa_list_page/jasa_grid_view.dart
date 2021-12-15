import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/Jasa.dart';
import 'package:apollo_bengkel/pages/jasa_list_page/jasa_tile.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:apollo_bengkel/pages/jasa_list_page/paket_jasa_tile.dart' ;

class JasaGridView extends StatefulWidget {
  final KategoriJasaListPage kategoriJasaListPage;

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

  final KategoriJasaListPage kategoriJasaListPage;
  var _jasa = Future<List<Jasa>>.value([]);

  /// Converter kategori ke string
  String? _kategoriJasaListPageToString(
    KategoriJasaListPage kategoriJasaListPage,
  ) {
    var map = <KategoriJasaListPage, String>{
      //KategoriProductListPage.All: 'all',
      KategoriJasaListPage.Jasa_oli: 'jasa_oli',
      KategoriJasaListPage.Jasa_ban: 'jasa_ban',
      KategoriJasaListPage.Jasa_injeksi: 'jasa_injeksi',
      KategoriJasaListPage.Jasa_CVT: 'jasa_cvt',
    };

    return map[kategoriJasaListPage];
  }

  Future<List<Jasa>> _getJasa() async {
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
          _kategoriJasaListPageToString(kategoriJasaListPage)!;

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

      var jasa = Jasa.fromJSON(docData);

      return jasa;
    }).toList();

    return jasa;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _jasa = _getJasa();
    });
  }

  SliverGridDelegate _getSliverGridDelegate() {
    //jasa_oli harus diubah
    if (kategoriJasaListPage == KategoriJasaListPage.Jasa_oli) {
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

  /*bool _isPaket() {
    //jasa_oli harus diubah
    return kategoriJasaListPage == KategoriProductListPage.Jasa_oli;
  }*/

  Future<void> _refreshItem() async {
    setState(() {
      _jasa = _getJasa();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Jasa>>(
      future: _jasa,
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
            var jasa = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () {
                return _refreshItem();
              },
              child: GridView.builder(
                gridDelegate: _getSliverGridDelegate(),
                itemCount: jasa.length,
                itemBuilder: (context, index) {
                  if (jasa.length == 0) {
                    return Container(
                      child: Text(
                        'nothing here',
                      ),
                    );
                  }

                  return JasaTile(
                    jasa: jasa[index],
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
