import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/CheckoutHistoryItem.dart';
import 'package:apollo_bengkel/models/CheckoutItemData.dart';
import 'package:apollo_bengkel/models/Product.dart';
import 'package:apollo_bengkel/models/UserData.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderHistoryDetailPage extends StatefulWidget {
  const OrderHistoryDetailPage({
    Key? key,
    required this.checkoutHistoryItem,
  }) : super(key: key);

  final CheckoutHistoryItem checkoutHistoryItem;

  @override
  _OrderHistoryDetailPageState createState() => _OrderHistoryDetailPageState(
        checkoutHistoryItem: checkoutHistoryItem,
      );
}

class _OrderHistoryDetailPageState extends State<OrderHistoryDetailPage> {
  _OrderHistoryDetailPageState({required this.checkoutHistoryItem});

  final CheckoutHistoryItem checkoutHistoryItem;

  List<CheckoutItemData> _checkoutItemDatas = [];

  void _goBack() {
    Navigator.pop(context);
  }

  /// untuk ambil data user
  Future<UserData> _getUserData() async {
    var query = firestore.collection('/users').doc(checkoutHistoryItem.userId);

    return await query.get().then((doc) => UserData.fromJSON(doc.data()!));
  }

  Future<void> _getCheckoutItemDatas() async {
    var checkoutItems = checkoutHistoryItem.checkoutItems;
    var query = firestore.collection('products').where(FieldPath.documentId,
        whereIn: checkoutItems.map((e) => e.itemId).toList());

    /// ambil semua product di checkout, dan ubah ke CheckoutItemData
    await query.get().then((col) => col.docs.asMap().entries.forEach(
          (e) async {
            /// bikin item checkout disini
            var checkoutItemData = CheckoutItemData(
              product: Product.fromJSON(
                <String, dynamic>{
                  'id': e.value.reference.id,
                  ...e.value.data(),
                },
              ),
              amount: checkoutItems[e.key].amount,
            );

            /// ambil url foto dari firebase storage
            checkoutItemData.photoDownloadURL = await firestorage
                .refFromURL(
                    'gs://puja-sari.appspot.com/app/foto_produk/${Product.kategoriToString(checkoutItemData.product.kategoriProduct)}/${checkoutItemData.product.photoName}')
                .getDownloadURL();

            setState(() {
              _checkoutItemDatas.add(checkoutItemData);
            });
          },
        ));
  }

  /// untuk menghitung harga product setelah diskon
  num _hargaSetelahDiskon(Product p) => p.harga - p.harga * p.promo;

  /// untuk menghitung harga product setelah diskon dikali banyak item
  num _hargaTotalCheckoutItem(CheckoutItemData c) =>
      _hargaSetelahDiskon(c.product) * c.amount;

  /// untuk menghitung harga total semua item yang di checkout
  num _hargaTotalCheckoutItems(List<CheckoutItemData> checkoutItemDatas) =>
      checkoutItemDatas.fold(0, (p, e) => p + _hargaTotalCheckoutItem(e));

  @override
  void initState() {
    super.initState();
    _getCheckoutItemDatas();
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
        'Detail Transaksi',
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _body() {
    var metodePembayaran = CheckoutHistoryItem.paymentMethodToString(
      checkoutHistoryItem.paymentMethod,
    );

    var status = CheckoutHistoryItem.statusToString(checkoutHistoryItem.status);
    var bank = CheckoutHistoryItem.bankToString(checkoutHistoryItem.bank);
    var noVA = checkoutHistoryItem.noVirtualAccount;

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
            Padding(
              padding: const EdgeInsets.only(
                bottom: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'ID Order:',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    checkoutHistoryItem.id!,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<UserData>(
              future: _getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Nama Pembeli:',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                snapshot.data!.name,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Alamat Pengiriman: ',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                snapshot.data!.alamat,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return Center(
                    child: Text(
                      'Something Is Wrong',
                    ),
                  );
                }

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            Text(
              'Item Pesanan',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                // fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ..._checkoutItemDatas.map((e) {
                  print('e => ${e.amount}');
                  return ListTile(
                    leading: Container(
                      height: 40,
                      width: 40,
                      child: Image.network(e.photoDownloadURL),
                    ),
                    title: Text(
                      '${e.product.nama} (x${e.amount})',
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
                  );
                }).toList(),
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
                      rupiahFormatter
                          .format(_hargaTotalCheckoutItems(_checkoutItemDatas)),
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.only(
                top: 5.0,
                bottom: 5.0,
              ),
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Metode Pembayaran: ',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    metodePembayaran,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (checkoutHistoryItem.paymentMethod ==
                PaymentMethod.VirtualAccount) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'No. Virtual Account: ',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$bank $noVA',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        // fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                    ),
                  ],
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                bottom: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Status: ',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    status.replaceFirst('_', ' '),
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
