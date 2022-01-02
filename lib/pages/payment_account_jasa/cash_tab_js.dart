import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/CheckoutHistoryJasa.dart';
import 'package:apollo_bengkel/models/UserData.dart';

import 'package:apollo_bengkel/utils.dart';
import 'package:flutter/material.dart';

class CashTabJs extends StatefulWidget {
  const CashTabJs({Key? key}) : super(key: key);

  @override
  _CashTabJsState createState() => _CashTabJsState();
}

class _CashTabJsState extends State<CashTabJs> {
  void _navigateToSuccessBuyPage(String checkoutHistoryItemId, int antrian) {
    Navigator.pushNamedAndRemoveUntil(
        context, '/success_buy_page_js', (_) => false,
        arguments: <String, dynamic>{
          'checkoutHistoryItemId': checkoutHistoryItemId,
          'antrian': antrian,
        });
  }

  Future<void> _createCheckoutHistory() async {
    /// ambil email user
    var email = fireAuth.currentUser!.email;

    /// bikin query untuk user dan checkoutHistory
    var userQuery = firestore.collection('/users').where(
          'email',
          isEqualTo: email,
        );

    var checkoutHistoryQuery = firestore.collection('/checkoutHistories');

    /// ambil data user
    await userQuery.get().then((col) => col.docs.first).then((doc) {
      var user = UserData.fromJSON(doc.data());

      var checkoutJasas = user.checkoutJasa;
      var dtNow = DateTime.now();

      /// bikin CheckoutHistoryItem
      var checkoutItemHistory = CheckoutHistoryJasa(
        userId: doc.id,
        tglpesen: dtNow,
        checkoutJasas: checkoutJasas,
        status: StatusCheckoutHistoryItem.Ditunggu,
        paymentMethod: PaymentMethod.Cash,
      );

      return checkoutItemHistory;
    }).then((checkoutItemHistory) async {
      /// tambahkan checkoutItemHistory ke collection checkoutItemHistories
      await checkoutHistoryQuery
          .add(checkoutItemHistory.toJSON())
          .then((c) async {
        /// lalu pada collection user,
        await userQuery.get().then((col) => col.docs.first).then((doc) async {
          /// kosongkan current_checkout_items
          await doc.reference.update({
            'current_checkout_jasa': [],
          });
        }).then((_) {
          /// lalu navigate ke success_buy_page
          //_navigateToSuccessBuyPage(c.id);
        });
      });
      return checkoutItemHistory;
    }).then((checkoutItemHistory) async {
      int jmlantrian = 0;
      var filtertgl = checkoutItemHistory.tanggal;
      var filterkurangdari = checkoutItemHistory.tanggal?.add(Duration (milliseconds: 86400000));
      await firestore
      .collection('/checkoutHistories')
      .where('tanggaljs', isGreaterThanOrEqualTo: filtertgl?.millisecondsSinceEpoch)
      .where('tanggaljs', isLessThan: filterkurangdari?.millisecondsSinceEpoch)
      .where('tanggaljs', isNull: false)
      .get()
      .then(
        (col) async {
          var datas = col.docs;
          jmlantrian = datas.length;
          await Future.wait(
            datas.where((doc
            )=>doc.id==checkoutItemHistory.id)
            .map((element) {
            return element.reference.update({
              'antrian': jmlantrian,
            });
          })
          );
          return jmlantrian;
        }
      );
      
      _navigateToSuccessBuyPage(checkoutItemHistory.id!, jmlantrian);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        left: 10.0,
        right: 10.0,
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Pesanan dibayarkan saat produk sampai pada alamat pengiriman.',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 15,
            ),
          ),
          Spacer(),
          Container(
            margin: const EdgeInsets.only(
              bottom: 20.0,
            ),
            width: double.infinity,
            child: MaterialButton(
              color: Colors.blue,
              child: Text(
                'Lanjutkan',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: _createCheckoutHistory,
            ),
          ),
        ],
      ),
    );
  }
}
