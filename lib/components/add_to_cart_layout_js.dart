import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/CheckoutItem.dart';
import 'package:apollo_bengkel/models/Jasa.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_number_picker/flutter_number_picker.dart';

class AddToCartLayoutJs extends StatefulWidget {
  const AddToCartLayoutJs({
    Key? key,
    required this.jasa,
    required this.refreshCallBack,
  }) : super(key: key);

  final Jasa jasa;
  //final Jasa jasa;
  final void Function() refreshCallBack;

  @override
  _AddToCartLayoutJsState createState() => _AddToCartLayoutJsState(
        jasa: jasa,
        refreshCallBack: refreshCallBack,
      );
}

class _AddToCartLayoutJsState extends State<AddToCartLayoutJs> {
  _AddToCartLayoutJsState({
    required this.jasa,
    required this.refreshCallBack,
  });

  final Jasa jasa;
  void Function() refreshCallBack;

  // untuk beli product
  int banyak = 1;

  num hargaTotal() =>
      ((jasa.hargajs - jasa.hargajs * jasa.promojs) * banyak).toInt();

  dynamic _banyakProductBerubah(dynamic v) {
    setState(() {
      banyak = v as int;
    });
  }

  /// untuk update banyak item, variable [product] dan [banyak] didapat
  /// dari variabel kelas di paling atas.
  Future<void> _updateCheckoutAmount() async {
    print('amount updated');

    // get user email
    var email = fireAuth.currentUser!.email;
    var query = firestore.collection('/users').where(
          'email',
          isEqualTo: email,
        );

    List<CheckoutItem> tempCheckoutItems = [];

    /// ambil semua checkout item dulu
    await query.get().then((col) => col.docs.first).then((user) async {
      /// ambil semua item
      var allCurrentCheckoutItems =
          (user.data()['current_checkout_items'] as List)
              .map((e) => CheckoutItem.fromJSON(e))
              .toList();

      /// cek apakah item ini sebelumnya tidak ada di allCurrentCheckoutItems
      if (!allCurrentCheckoutItems.any((e) => e.itemId == jasa.id)) {
        /// jika nggak ada, tambahin itemnya
        allCurrentCheckoutItems.add(
          CheckoutItem(
            itemId: jasa.id,
            amount: banyak,
          ),
        );

        var newCurrentCheckoutItems =
            allCurrentCheckoutItems.map((e) => e.toJSON()).toList();

        /// lalu update data [current_checkout_items] di firestore dengan array yang baru
        await user.reference.update({
          'current_checkout_items': newCurrentCheckoutItems,
        });

        /// selesai
        return;
      }

      /// tapi jika item sudah ada di allCheckoutItems, tinggal tambahin amountnya ke firestore
      else {
        /// ambil nilai amount dari item ini sebelumnya untuk ditambah
        var amountItemSebelum = allCurrentCheckoutItems
            .singleWhere((element) => element.itemId == jasa.id)
            .amount;

        /// ambil semua item dari allCheckoutItems kecuali item dengan id dari variable [product]
        tempCheckoutItems = allCurrentCheckoutItems
            .where(
              (i) => i.itemId != jasa.id,
            )
            .toList();

        /// tambahkan item checkout yang baru (dengan id sama tapi amount yang baru) ke variabel [tempCheckoutItems]
        tempCheckoutItems.add(
          CheckoutItem(
            itemId: jasa.id,
            amount: banyak + amountItemSebelum,
          ),
        );

        /// buat tiap anggotanya ke bentuk map<string, dynamic> agar bisa di save ke firestore
        var newCurrentCheckoutItems =
            tempCheckoutItems.map((e) => e.toJSON()).toList();

        /// lalu update data [current_checkout_items] di firestore dengan array yang baru
        await user.reference.update({
          'current_checkout_items': newCurrentCheckoutItems,
        });
      }
    });

    if (mounted) {
      setState(() {
        banyak = 1;
      });
    }

    refreshCallBack();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        bottom: 10.0,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 120,
          // width: ,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(
                20,
              ),
            ),
            border: Border.all(
              color: Colors.blue,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total Harga Item',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${rupiahFormatter.format(hargaTotal())}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      child: CustomNumberPicker(
                        onValue: _banyakProductBerubah,
                        initialValue: banyak,
                        maxValue: 100,
                        minValue: 1,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.blue,
                      ),
                    ),
                    child: Text(
                      'Add to cart',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _updateCheckoutAmount,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
