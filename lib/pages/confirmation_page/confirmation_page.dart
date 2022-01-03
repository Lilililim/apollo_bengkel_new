import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/CheckoutItemData.dart';
import 'package:apollo_bengkel/models/Product.dart';
import 'package:apollo_bengkel/models/UserData.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({
    Key? key,
    required this.checkoutItemDatas,
  }) : super(key: key);

  final List<CheckoutItemData> checkoutItemDatas;

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState(
        checkoutItemDatas: checkoutItemDatas,
      );
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  _ConfirmationPageState({
    required this.checkoutItemDatas,
  });

  final List<CheckoutItemData> checkoutItemDatas;
  final DateTime dtNow = DateTime.now();

  void _goBack() {
    Navigator.pop(context);
  }

  void _navigateToPaymentMethodPage() {
    Navigator.pushNamed(
      context,
      '/payment_method_page',
    ).then((_) => setState(() {}));
  }

  Future<UserData> _getUserData() async {
    var email = fireAuth.currentUser!.email;
    var query = firestore.collection('/users').where('email', isEqualTo: email);

    return await query
        .get()
        .then((col) => col.docs.first)
        .then((doc) => UserData.fromJSON(doc.data()));
  }

  num _hargaSetelahDiskon(Product p) => p.hargapr - p.hargapr * p.promo;

  num _hargaTotalCheckoutItem(CheckoutItemData c) =>
      _hargaSetelahDiskon(c.product) * c.amount;

  num _hargaTotalCheckoutItems() =>
      checkoutItemDatas.fold(0, (p, e) => p + _hargaTotalCheckoutItem(e));

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: _goBack,
        icon: Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Colors.blue,
        ),
      ),
      title: Text(
        'Konfirmasi Order',
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20.0,
        left: 10.0,
        right: 10.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Item Pesanan',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                // fontWeight: FontWeight.bold,
              ),
            ),
            ...checkoutItemDatas
                .map((e) => ListTile(
                      leading: Container(
                        height: 40,
                        width: 40,
                        child: Image.network(e.photoDownloadURL),
                      ),
                      title: Text(
                        '${e.product.namapr} (x${e.amount})',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      subtitle: Text(
                        '${rupiahFormatter.format(_hargaSetelahDiskon(e.product))}',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      trailing: Text(
                        rupiahFormatter.format(_hargaTotalCheckoutItem(e)),
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                .toList(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total Harga :',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  rupiahFormatter.format(_hargaTotalCheckoutItems()),
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 10.0,
                bottom: 10.0,
              ),
              height: 1,
              color: Colors.black,
            ),
            FutureBuilder<UserData>(
              future: _getUserData(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Atas Nama :',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            snapshot.hasData
                                ? snapshot.data!.name
                                : 'ambil data...',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 20.0,
                            ),
                            child: Text(
                              'Alamat penerima :',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 20.0,
                            ),
                            child: Text(
                              snapshot.hasData
                                  ? snapshot.data!.alamat
                                  : 'ambil data...',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return CircularProgressIndicator();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                  ),
                  child: Text(
                    'Tanggal pemesanan :',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                  ),
                  child: Text(
                    DateFormat('dd MMMM yyyy').format(dtNow),
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
            Container(
              height: 40,
              margin: const EdgeInsets.only(
                top: 30.0,
              ),
              width: double.infinity,
              child: MaterialButton(
                color: Theme.of(context).buttonColor,
                child: Text(
                  'Pilih Metode Bayar',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: _navigateToPaymentMethodPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
