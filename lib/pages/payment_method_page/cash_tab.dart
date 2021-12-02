import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/CheckoutHistoryItem.dart';
import 'package:apollo_bengkel/models/UserData.dart';

import 'package:apollo_bengkel/utils.dart';
import 'package:flutter/material.dart';

class CashTab extends StatefulWidget {
  const CashTab({Key? key}) : super(key: key);

  @override
  _CashTabState createState() => _CashTabState();
}

class _CashTabState extends State<CashTab> {
  void _navigateToSuccessBuyPage(String checkoutHistoryItemId) {
    Navigator.pushNamedAndRemoveUntil(
        context, '/success_buy_page', (_) => false,
        arguments: <String, dynamic>{
          'checkoutHistoryItemId': checkoutHistoryItemId
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

      var checkoutItems = user.checkoutItems;
      var dtNow = DateTime.now();

      /// bikin CheckoutHistoryItem
      var checkoutItemHistory = CheckoutHistoryItem(
        userId: doc.id,
        time: dtNow,
        checkoutItems: checkoutItems,
        status: StatusCheckoutHistoryItem.Dikirim,
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
            'current_checkout_items': [],
          });
        }).then((_) {
          /// lalu navigate ke success_buy_page
          _navigateToSuccessBuyPage(c.id);
        });
      });
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
