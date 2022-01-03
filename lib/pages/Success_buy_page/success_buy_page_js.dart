import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/CheckoutHistoryJasa.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SuccessBuyJsPage extends StatefulWidget {
  const SuccessBuyJsPage({
    Key? key,
    required this.checkoutHistoryItemId,
    required this.antrian,
  }) : super(key: key);

  final String checkoutHistoryItemId;
  final int antrian;
  
  @override
  _SuccessBuyPageJsState createState() => _SuccessBuyPageJsState(
        
      );
} //tes push

class _SuccessBuyPageJsState extends State<SuccessBuyJsPage> {
  
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

  Future<CheckoutHistoryJasa?> _getCheckoutHistoryItem() async {
    widget.checkoutHistoryItemId;
    var docRef =
        firestore.collection('/checkoutHistories').doc(widget.checkoutHistoryItemId);

    return await docRef.get().then((d) {
      if (d.exists) {
        return CheckoutHistoryJasa.fromJSON({
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
    var noAntri = widget.antrian;
    return Padding(
      padding: const EdgeInsets.only(
        top: 40.0,
      ),
      child: FutureBuilder<CheckoutHistoryJasa?>(
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
                    'Order Complete !!',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'No Antrian: ' + noAntri.toString(),
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                    ),
                  child: Center(
                      child: Text(
                        'Silahkan datang pada tanggal yang sudah dipesan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      maxLines: 4,
                      overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                SizedBox(
                  height: 80,
                ),
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
