import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/CheckoutHistoryJasa.dart';
import 'package:apollo_bengkel/models/CheckoutItemData.dart';
import 'package:apollo_bengkel/models/CheckoutJasa.dart';
import 'package:apollo_bengkel/models/UserData.dart';
import 'package:apollo_bengkel/pages/payment_account_jasa/util_js.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:flutter/material.dart';

class VirtualAccountTabJs extends StatefulWidget {
  const VirtualAccountTabJs({Key? key}) : super(key: key);

  @override
  _VirtualAccountTabJsState createState() => _VirtualAccountTabJsState();
}

class _VirtualAccountTabJsState extends State<VirtualAccountTabJs> {
  Bank? _currentBank = Bank.BNI;
  void _setBank(Bank? bank) {
    setState(() {
      _currentBank = bank;
      
    });
  }

  void _navigateToSuccessBuyPage(String checkoutHistoryItemId, int antrian) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/success_buy_page_js',
      (_) => false,
      arguments: <String, dynamic>{
        'checkoutHistoryItemId': checkoutHistoryItemId,
        'antrian': antrian,
      },
    );
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
    await userQuery.get().then((col) => col.docs.first).then((doc) async {
      var user = UserData.fromJSON(doc.data());

      var checkoutJasa = user.checkoutJasa;
      var dtNow = DateTime.now();
      var convert = checkoutJasa.first.tanggal!=null?DateTime.fromMillisecondsSinceEpoch(checkoutJasa.first.tanggal):null;
      /// bikin CheckoutHistoryItem
      var checkoutItemHistory = CheckoutHistoryJasa(
        userId: doc.id,
        tglpesen: dtNow,
        checkoutJasas: checkoutJasa,
        status: StatusCheckoutHistoryItem.Belum_Datang,
        paymentMethod: PaymentMethod.VirtualAccount,
        bank: _currentBank,
        noVirtualAccount: getRandom16Digit(),
        tanggal: convert,
      );
      /// tambahkan checkoutItemHistory ke collection checkoutItemHistories
      await checkoutHistoryQuery
          .add(checkoutItemHistory.toJSON())
          .then((c) async {
        /// lalu pada collection user,
        await userQuery.get().then((col) => col.docs.first).then((doc) async {
          /// kosongkan current_checkout_items
          // await doc.reference.update({
          //   'current_checkout_items': [],
          // });
          await doc.reference.update({
            'current_checkout_jasa': [],
          });
          checkoutItemHistory.id = c.id;
        }).then((_) {
          /// lalu navigate ke success_buy_page
          
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
  void initState() {
    super.initState();
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Pilih Bank',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 10.0,
            ),
            padding: const EdgeInsets.only(
              left: 10.0,
            ),
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(
                  10,
                ),
              ),
            ),
            child: DropdownButton<Bank>(
              value: _currentBank,
              onChanged: _setBank,
              items: Bank.values
                  .map(
                    (e) => DropdownMenuItem<Bank>(
                      value: e,
                      child: Text(
                        e.toString().replaceFirst(r'Bank.', ''),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
            ),
            child: Text(
              'Langkah',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...constructSteps(_currentBank!)
              .asMap()
              .entries
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(
                    top: 5.0,
                  ),
                  child: Text(
                    '${e.key + 1}. ${e.value}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
              .toList(),
          Padding(
            padding: const EdgeInsets.only(
              top: 5.0,
            ),
            child: Text(
              '* Catatan: Pembayaran harus dilakukan 1X24 jam setelah nomor virtual account diterbitkan.',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 15,
              ),
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
                'Konfirmasi Pembelian',
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
