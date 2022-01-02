import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/CheckoutHistoryItem.dart';
import 'package:apollo_bengkel/models/CheckoutHistoryJasa.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoriesPage extends StatefulWidget {
  const OrderHistoriesPage({Key? key}) : super(key: key);

  @override
  _OrderHistoriesPageState createState() => _OrderHistoriesPageState();
}

class _OrderHistoriesPageState extends State<OrderHistoriesPage> {
  Future<List<CheckoutHistoryItem>> _getCheckoutHistoryItems() async {
    var email = fireAuth.currentUser!.email;
    var query = firestore.collection('/users').where(
          'email',
          isEqualTo: email,
        );

    /// ambil id user
    var userId = await query
        .get()
        .then((col) => col.docs.first)
        .then((doc) => doc.reference.id);

    /// bikin query transaction history
    var transactionHistoryQuery =
        firestore.collection('/checkoutHistories').where(
              'user_id',
              isEqualTo: userId,
            );

    var transactionHistory =
        await transactionHistoryQuery.get().then((col) => col.docs
            .where((item) => item.data()['checkout_items'] != null)
            .map((e) => CheckoutHistoryItem.fromJSON(<String, dynamic>{
                  ...e.data(),
                  'id': e.reference.id,
                }))
            .toList());

    return transactionHistory;
  }

  Future<List<CheckoutHistoryJasa>> _getCheckoutHistoryJasa() async {
    var email = fireAuth.currentUser!.email;
    var query = firestore.collection('/users').where(
          'email',
          isEqualTo: email,
        );

    /// ambil id user
    var userId = await query
        .get()
        .then((col) => col.docs.first)
        .then((doc) => doc.reference.id);

    /// bikin query transaction history
    var transactionHistoryQuery =
        firestore.collection('/checkoutHistories').where(
              'user_id',
              isEqualTo: userId,
            );

    var transactionHistory =
        await transactionHistoryQuery.get().then((col) => col.docs
            .where((item) => item.data()['checkout_jasa'] != null)
            .map((e) => CheckoutHistoryJasa.fromJSON(<String, dynamic>{
                  ...e.data(),
                  'id': e.reference.id,
                }))
            .toList());

    return transactionHistory;
  }

  void _goBack() {
    Navigator.pop(context);
  }

  void _navigateToHistoryDetailPage(CheckoutHistoryItem checkoutHistoryItem) {
    Navigator.pushNamed(
      context,
      '/order_history_detail_page',
      arguments: <String, dynamic>{
        'checkoutHistoryItem': checkoutHistoryItem,
      },
    );
  }

  void _navigateToHistoryDetailJsPage(CheckoutHistoryJasa checkoutHistoryItem) {
    Navigator.pushNamed(
      context,
      '/order_history_detail_js_page',
      arguments: <String, dynamic>{
        'checkoutHistoryItem': checkoutHistoryItem,
      },
    );
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
        'Riwayat Transaksi',
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _body() {
    return ListView(children: [
      FutureBuilder<List<CheckoutHistoryItem>>(
        future: _getCheckoutHistoryItems(),
        builder: (_, s1) {
          if (s1.connectionState == ConnectionState.done) {
            if (s1.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: s1.data!
                    .map(
                      (e) => Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            'Order ${e.id}',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          subtitle: Text(
                            'Status: ${CheckoutHistoryItem.statusToString(e.status)}',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          trailing: Text(
                            DateFormat('dd/MM/yy').format(e.time),
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          onTap: () => _navigateToHistoryDetailPage(e),
                        ),
                      ),
                    )
                    .toList(),
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Something is wrong !',
                ),
              ],
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        },
      ),
      FutureBuilder<List<CheckoutHistoryJasa>>(
        future: _getCheckoutHistoryJasa(),
        builder: (_, s1) {
          if (s1.connectionState == ConnectionState.done) {
            if (s1.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: s1.data!
                    .map(
                      (e) => Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            'Order ${e.id}',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          subtitle: Text(
                            'Status: ${CheckoutHistoryJasa.statusToString(e.status)}',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          trailing: Text(
                            DateFormat('dd/MM/yy').format(e.tglpesen),
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          onTap: () => _navigateToHistoryDetailJsPage(e),
                        ),
                      ),
                    )
                    .toList(),
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Something is wrong !',
                ),
              ],
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        },
      ),
    ]);
  }
}
