import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/CheckoutHistoryJasa.dart';
import 'package:apollo_bengkel/models/CheckoutItemData.dart';
import 'package:apollo_bengkel/models/Product.dart';
import 'package:apollo_bengkel/models/Jasa.dart';
import 'package:apollo_bengkel/models/UserData.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryDetailPageJs extends StatefulWidget {
  const OrderHistoryDetailPageJs({
    Key? key,
    required this.checkoutHistoryJasa,
  }) : super(key: key);

  final CheckoutHistoryJasa checkoutHistoryJasa;

  @override
  _OrderHistoryDetailPageJsState createState() =>
      _OrderHistoryDetailPageJsState(
        checkoutHistoryJasa: checkoutHistoryJasa,
      );
}

class _OrderHistoryDetailPageJsState extends State<OrderHistoryDetailPageJs> {
  _OrderHistoryDetailPageJsState({required this.checkoutHistoryJasa});

  final CheckoutHistoryJasa checkoutHistoryJasa;

  List<CheckoutItemJasa> _checkoutItemJasas = [];

  void _goBack() {
    Navigator.pop(context);
  }

  /// untuk ambil data user
  Future<UserData> _getUserData() async {
    var query = firestore.collection('/users').doc(checkoutHistoryJasa.userId);

    return await query.get().then((doc) => UserData.fromJSON(doc.data()!));
  }

  Future<void> _getCheckoutItemDatas() async {
    var checkoutItems = checkoutHistoryJasa.checkoutJasas;
    var query = firestore.collection('jasa').where(FieldPath.documentId,
        whereIn: checkoutItems.map((e) => e.itemId).toList());

    /// ambil semua product di checkout, dan ubah ke CheckoutItemData
    await query.get().then((col) => col.docs.asMap().entries.forEach(
          (e) async {
            /// bikin item checkout disini
            var checkoutItemData = CheckoutItemJasa(
              jasa: Jasa.fromJSON(
                <String, dynamic>{
                  'id': e.value.reference.id,
                  ...e.value.data(),
                },
              ),
              amount: checkoutItems[e.key].amount,
              tanggal: checkoutItems[e.key].tanggal,
              //antrian: checkoutItems[e.key].antrian,
            );

            /// ambil url foto dari firebase storage
            checkoutItemData.photoDownloadURL = await firestorage
                .refFromURL(
                    'gs://apolo-bengkel.appspot.com/app/foto_jasa/${Jasa.kategoriToString(checkoutItemData.jasa.kategoriJasa)}/${checkoutItemData.jasa.photoNamejs}')
                .getDownloadURL();

            setState(() {
              _checkoutItemJasas.add(checkoutItemData);
            });
          },
        ));
  }

  /// untuk menghitung harga product setelah diskon
  num _hargaSetelahDiskon(Jasa p) => p.hargajs - p.hargajs * p.promojs;

  /// untuk menghitung harga product setelah diskon dikali banyak item
  num _hargaTotalCheckoutItem(CheckoutItemJasa c) =>
      _hargaSetelahDiskon(c.jasa) * c.amount;

  /// untuk menghitung harga total semua item yang di checkout
  num _hargaTotalCheckoutItems(List<CheckoutItemJasa> checkoutItemDatas) =>
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
    var metodePembayaran = CheckoutHistoryJasa.paymentMethodToString(
      checkoutHistoryJasa.paymentMethod,
    );

    var status = CheckoutHistoryJasa.statusToString(checkoutHistoryJasa.status);
    var bank = CheckoutHistoryJasa.bankToString(checkoutHistoryJasa.bank);
    var noVA = checkoutHistoryJasa.noVirtualAccount;
    var noAntri = checkoutHistoryJasa.antrian;

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
                    checkoutHistoryJasa.id!,
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
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Antrian: ',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                noAntri.toString(),
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
                                'Tanggal Booking: ',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              if(_checkoutItemJasas.isNotEmpty)
                                Text(
                                  DateFormat('dd/MMMM/yyyy').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          _checkoutItemJasas.first.tanggal)),
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
                ..._checkoutItemJasas.map((e) {
                  print('e => ${e.amount}');
                  return ListTile(
                    leading: Container(
                      height: 40,
                      width: 40,
                      child: Image.network(e.photoDownloadURL),
                    ),
                    title: Text(
                      '${e.jasa.namajs} (x${e.amount})',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                    subtitle: Text(
                      '${rupiahFormatter.format(_hargaSetelahDiskon(e.jasa))}',
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
                          .format(_hargaTotalCheckoutItems(_checkoutItemJasas)),
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
            if (checkoutHistoryJasa.paymentMethod ==
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
