import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/CheckoutHistoryItem.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SuccessBuyPage extends StatefulWidget {
  const SuccessBuyPage({
    Key? key,
    required this.checkoutHistoryItemId,
  }) : super(key: key);

  final String checkoutHistoryItemId;

  @override
  _SuccessBuyPageState createState() => _SuccessBuyPageState(
        checkoutHistoryItemId: checkoutHistoryItemId,
      );
} //tes push

class _SuccessBuyPageState extends State<SuccessBuyPage> {
  _SuccessBuyPageState({
    required this.checkoutHistoryItemId,
  });

  final String checkoutHistoryItemId;

  void _goToHomePage() {
    Navigator.pushReplacementNamed(context, '/home_page');
  }

  void _copyToClipBoard(String content) {
    Clipboard.setData(
      ClipboardData(
        text: content,
      ),
    );

    Fluttertoast.showToast(
      msg: 'Copied !',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  Future<CheckoutHistoryItem?> _getCheckoutHistoryItem() async {
    var docRef =
        firestore.collection('/checkoutHistories').doc(checkoutHistoryItemId);

    return await docRef.get().then((d) {
      if (d.exists) {
        return CheckoutHistoryItem.fromJSON({
          'id': d.id,
          ...d.data()!,
        });
      }
      return null;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 40.0,
      ),
      child: FutureBuilder<CheckoutHistoryItem?>(
        future: _getCheckoutHistoryItem(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData) return Text('Something Wrong');
            var item = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  FontAwesome.ok_circled,
                  color: Colors.blue,
                  size: 100,
                ),
                Center(
                  child: Text(
                    'Pesanan Telah Dibuat',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                    ),
                  ),
                ),
                SizedBox(
                  height: 80,
                ),
                if (item.paymentMethod ==
                    PaymentMethod.VirtualAccount) ...<Widget>[
                  Center(
                    child: Text(
                      'No. Virtual Account (${item.bank})',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        item.noVirtualAccount!,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _copyToClipBoard(item.noVirtualAccount!),
                        icon: Icon(
                          Icons.copy,
                          color: Colors.blue,
                        ),
                        splashColor: Colors.blue,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                    ),
                    child: Center(
                      child: Text(
                        'Status: ${CheckoutHistoryItem.statusToString(item.status)}',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Center(
                      child: Text(
                        'Jika Sudah Membayar Silahkan Kirim ',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Bukti Pembayaran Ke nomor dibawah ini ',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  Center(
                    child: Text(
                      '085161692108',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18, 
                      ),
                    ),
                  ),
                Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                    ),
                    child: Center(
                      child: Text(
                        'Harap dibayar sebelum 2 jam',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'untuk mempermudah pengiriman',
                      style: TextStyle(
                         color: Colors.blue,
                          fontSize: 18,
                      ),
                    ),
                  )
                ],
                if (item.paymentMethod !=
                    PaymentMethod.VirtualAccount) ...<Widget>[
                  Center(
                    child: Text(
                      'Barang akan dikirim ke alamat anda !',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Status: ${CheckoutHistoryItem.statusToString(item.status)}',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  
                ],
                Spacer(),
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 20.0,
                    left: 10.0,
                    right: 10.0,
                  ),
                  width: double.infinity,
                  child: MaterialButton(
                    color: Colors.blue,
                    child: Text(
                      'Kembali ke Beranda',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _goToHomePage,
                  ),
                ),
              ],
            );
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }
}
