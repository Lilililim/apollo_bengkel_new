import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/Jasa.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:flutter/material.dart';

class JasaTile extends StatefulWidget {
  final Jasa jasa;

  JasaTile({
    required this.jasa,
  });

  @override
  _JasaTileState createState() => _JasaTileState(
        jasa: jasa,
      );
}

class _JasaTileState extends State<JasaTile> {
  final Jasa jasa;

  _JasaTileState({
    required this.jasa,
  });

  @override
  void initState() {
    super.initState();
  }

  Future<String> _fetchImageUrl() {
    // *(ini di comment untuk hemat kuota firebase)
    //var kategori = Product.kategoriToString(product.kategoriProduct);
    //var photoName = product.photoNamepr;
    //var ref = firestorage.refFromURL(
    //    'gs://apolo-bengkel.appspot.com/app/foto_produk/$kategori/$photoName');
    //return ref.getDownloadURL();

    return Future.value('');
  }

  int hargaSetelahDiskon() {
    return (jasa.hargajs - jasa.hargajs * jasa.promojs).toInt();
  }

  int persenDiskon() {
    return (jasa.promojs * 100).toInt();
  }

  void _navigateToProductDetailPage(Jasa jasa) {
    Navigator.pushNamed(
      context,
      '/jasa_detail_page',
      arguments: <String, dynamic>{
        'jasa': jasa,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            20,
          ),
          color: Colors.white,
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color: Colors.blue,
                  width: 1,
                ),
                color: Colors.white,
              ),
              margin: EdgeInsetsDirectional.only(
                bottom: 8,
              ),
              // height: MediaQuery.of(context).size.width * 0.4,
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    20,
                  ),
                ),
                child: FutureBuilder<String>(
                  future: _fetchImageUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          return FittedBox(
                            fit: BoxFit.fill,
                            child: Image.network(
                              snapshot.data!,
                              fit: BoxFit.fill,
                            ),
                          );
                        }

                        return FittedBox(
                          fit: BoxFit.fill,
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.fill,
                          ),
                        );
                      }

                      return FittedBox(
                        fit: BoxFit.fill,
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.fill,
                        ),
                      );
                    }

                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),

            /// item yang di align agak ke kanan
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                bottom: 10.0,
              ),
              child: Text(
                jasa.namajs,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),

            /// Jika product mempunyai promo diskon, maka tampilkan diskon dan harga akhir
            if (jasa.promojs > 0)
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  bottom: 10.0,
                ),
                child: Row(
                  children: [
                    Container(
                      height: 30.0,
                      width: 30.0,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(
                        right: 10.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            8,
                          ),
                        ),
                        color: Colors.red.withOpacity(0.7),
                      ),
                      child: Text(
                        '${persenDiskon()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${rupiahFormatter.format(jasa.hargajs)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                bottom: 20.0,
              ),
              child: Text(
                '${rupiahFormatter.format(hargaSetelahDiskon())}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        _navigateToProductDetailPage(jasa);
      },
    );
  }
}
