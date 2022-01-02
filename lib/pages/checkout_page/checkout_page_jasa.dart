import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/CheckoutHistoryJasa.dart';
import 'package:apollo_bengkel/models/CheckoutJasa.dart';
import 'package:apollo_bengkel/models/CheckoutItemData.dart';
import 'package:apollo_bengkel/models/Jasa.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_number_picker/flutter_number_picker.dart';
import 'package:intl/intl.dart';

class CheckoutPageJasa extends StatefulWidget {
  @override
  _CheckoutPageJasaState createState() => _CheckoutPageJasaState();
  
}

class _CheckoutPageJasaState extends State<CheckoutPageJasa> {
  List<CheckoutItemJasa> _currentCheckoutItemJasa = [];
    DateTime? _dateTime = DateTime.now(); //buat milih tanggal jasa
    //final List<CheckoutItemJasa> checkoutItemJasa;
    final DateTime dtNow = DateTime.now();// untuk ambil data checkout awal dan pada saat refresh halaman
    int timestamp1 = 0;
    int? timestamp2;
    DateTime? tglplus1;
    int jmlantrian = 0;
  Future<void> _fetchCurrentCheckoutData() async {
    // ambil current_checkout_item dari user saat ini
    List<CheckoutJasa> currentCheckoutJasa = [];

    await firestore
        .collection('/users')
        .where('email', isEqualTo: fireAuth.currentUser!.email)
        .get()
        .then(
      (col) {
        var datas = col.docs.first.data()['current_checkout_jasa'] as List;
        currentCheckoutJasa =
            datas.map((e) => CheckoutJasa.fromJSON(e)).toList();
      },
    );

    // setelah ambil currentCheckoutItems, bikin semua jadi currentCheckoutItemDatas
    currentCheckoutJasa.forEach((item) async {
      await firestore
          .collection('/jasa')
          .doc(item.itemId)
          .get()
          .then(
            (doc) => Jasa.fromJSON(
              <String, dynamic>{
                ...doc.data()!,
                'id': item.itemId,
              },
            ),
          )
          .then((jasa) async {
        var checkoutItemJasa = CheckoutItemJasa(
          jasa: jasa,
          amount: item.amount,
          tanggal: timestamp1!,
        );

        // ambil data download url
        var photoName = jasa.photoNamejs;
        var kategori = Jasa.kategoriToString(jasa.kategoriJasa);

        var refURL =
            'gs://apolo-bengkel.appspot.com/app/foto_jasa/$kategori/$photoName';

        var photoDownloadURL =
            await firestorage.refFromURL(refURL).getDownloadURL();

        checkoutItemJasa.photoDownloadURL = photoDownloadURL;

        if (mounted) {
          // kalau selesai langsung setState agar halaman refresh
          setState(() {
            _currentCheckoutItemJasa.add(checkoutItemJasa);
          });
        }
      });
    });
  }

  // untuk update banyak item
  Future<void> _updateCheckoutAmount(CheckoutItemJasa item, int banyak) async {
    print('amount updated');
    // get user email
    var email = fireAuth.currentUser!.email;
    var query = firestore.collection('/users').where('email', isEqualTo: email);
    List<CheckoutJasa> tempCheckoutJasa = [];
    if(timestamp1 == 0){
      return;
    }
    // ambil semua checkout item dulu
    await query.get().then((col) => col.docs.first).then((user) async {
      /// ambil semua item kecuali item dengan id dari variable [item]
      tempCheckoutJasa = (user.data()['current_checkout_jasa'] as List)
          .map((e) => CheckoutJasa.fromJSON(e))
          .where((i) => i.itemId != item.jasa.id)
          .toList();

      // tambahkan item checkout yang baru (dengan id sama tapi amount yang baru) ke variabel tempCheckoutItems
      tempCheckoutJasa.add(
        CheckoutJasa(
          itemId: item.jasa.id,
          amount: banyak,
          tanggal: timestamp1!,
        ),
      );

      /// buat tiap anggotanya ke bentuk map<string, dynamic> agar bisa di save ke firestore
      var newCurrentCheckoutJasa =
          tempCheckoutJasa.map((e) => e.toJSON()).toList();

      /// lalu update data [current_checkout_items] di firestore dengan array yang baru
      await user.reference.update({
        'current_checkout_jasa': newCurrentCheckoutJasa,
      });
    }).then((value) {
      /// jika sukses, maka update juga banyak [item] di UI (agar total harga ter-update juga)
      setState(() {
        _currentCheckoutItemJasa
            .where((e) => e.jasa.id == item.jasa.id)
            .first
            .amount = banyak;
      });
      setState(() {
        _currentCheckoutItemJasa
            .where((e) => e.jasa.id == item.jasa.id)
            .first
            .tanggal = timestamp1!;
      });
    });
  }

  /// untuk remove item checkout dari firestore (saat swipe item ke samping)
  Future<void> _removeItem(CheckoutItemJasa item) async {
    // ambil user email user
    var email = fireAuth.currentUser!.email;

    // bikin query untuk ambil data collection /users
    var query = firestore.collection('/users').where('email', isEqualTo: email);

    // ambil data user dari query
    await query.get().then((col) => col.docs.first).then((user) {
      // ambil data current_checkout_items dari data user
      var currentCheckoutItems =
          List.from(user.data()['current_checkout_items'])
              .map((e) => CheckoutJasa.fromJSON(e))
              .toList();

      /// bikin data [current_checkout_items] yang baru, tanpa item dengan id dari variable [item] (dibuang)
      var currentCheckoutJasaBaru = currentCheckoutItems
          .where((e) => e.itemId != item.jasa.id)
          .map((e) => e.toJSON())
          .toList();

      user.reference.set(
          <String, dynamic>{
            'current_checkout_jasa': currentCheckoutJasaBaru,
          },
          SetOptions(
            merge: true,
          ));
    }).then((value) {
      /// update [item] yang dipesan di UI (agar total harga ter-update juga)
      setState(() {
        _currentCheckoutItemJasa = _currentCheckoutItemJasa
            .where((e) => e.jasa.id != item.jasa.id)
            .toList();
      });
    });

    return;
  }

  // void countDocument() async {
  //   QuerySnapshot _myDoc = await firestore
  //       .collection('/checkoutHistories')
  //       .where('tanggaljs', isGreaterThanOrEqualTo: timestamp1)
  //       .where('tanggaljs', isLessThan: timestamp2)
  //       .get();
  //   List<DocumentSnapshot> _myDocCount = _myDoc.documents;
      
  //   }
  void _navigateToConfirmationPage() async {
    if(timestamp1 != 0){
      var email = fireAuth.currentUser!.email;
      var query = firestore.collection('/users').where('email', isEqualTo: email);
    
      List<CheckoutJasa> tempCheckoutJasa = [];
      final List<CheckoutItemJasa> checkoutItemJasas = [];
    // ambil semua checkout item dulu
    await query.get().then((col) => col.docs.first).then((user) async {
      /// ambil semua item kecuali item dengan id dari variable [item]
      tempCheckoutJasa = (user.data()['current_checkout_jasa'] as List)
          .map((e) => CheckoutJasa.fromJSON(e))
          .map((item) {
            item.tanggal = timestamp1;
            return item;
           })
          .toList();

      /// buat tiap anggotanya ke bentuk map<string, dynamic> agar bisa di save ke firestore
      var newCurrentCheckoutJasa =
          tempCheckoutJasa.map((e) => e.toJSON()).toList();

      /// lalu update data [current_checkout_items] di firestore dengan array yang baru
      await user.reference.update({
        'current_checkout_jasa': newCurrentCheckoutJasa,
      });
        return tempCheckoutJasa;
    }).then((checkoutJasas) async {
      /// jika sukses, maka update juga banyak [item] di UI (agar total harga ter-update juga)
      
        await firestore
        .collection('/checkoutHistories')
        .where('tanggaljs', isGreaterThanOrEqualTo: timestamp1)
        .where('tanggaljs', isLessThan: timestamp2)
        .get()
        .then(
          (col){
            var datas = col.docs.first.data()['jmldoc'] as List;
            // var mep = datas.asMap();
            // mep.keys.toList();
            jmlantrian = datas.length;
          }
        );
        
      Future.wait(checkoutJasas.map((item) async {
      await firestore
          .collection('/jasa')
          .doc(item.itemId)
          .get()
          .then(
            (doc) => Jasa.fromJSON(
              <String, dynamic>{
                ...doc.data()!,
                'id': item.itemId,
              },
            ),
          )
          .then((jasa) async {
            
        var checkoutItemJasa = CheckoutItemJasa(
          jasa: jasa,
          amount: item.amount,
          tanggal: timestamp1!,
        );

        // ambil data download url
        var photoName = jasa.photoNamejs;
        var kategori = Jasa.kategoriToString(jasa.kategoriJasa);

        var refURL =
            'gs://apolo-bengkel.appspot.com/app/foto_jasa/$kategori/$photoName';

        var photoDownloadURL =
            await firestorage.refFromURL(refURL).getDownloadURL();

        checkoutItemJasa.photoDownloadURL = photoDownloadURL;

        checkoutItemJasas.add(checkoutItemJasa);
        });
      })).then((value) {
      Navigator.pushNamed(context, '/confirmation_page_jasa',

        arguments: <String, dynamic>{
          'checkoutItemJasa': checkoutItemJasas,
      });
      });
    });
    }
  }

  num _hargaSetelahDiskon(Jasa jasa) =>
      jasa.hargajs - jasa.hargajs * jasa.promojs;

  // untuk hitung total harga dari item-item yang di checkout
  num _hargaTotal(List<CheckoutItemJasa> _c) => _c.fold(
        0,
        (prev, curr) => prev + _hargaSetelahDiskon(curr.jasa) * curr.amount,
      );

  @override
  void initState() {
    super.initState();

    /// pas pertama kali halaman di load langsung ambil data sekaligus refresh halaman.
    _fetchCurrentCheckoutData();
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
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back_ios_outlined,
          color: Colors.blue,
        ),
      ),
      title: Text(
        'Checkout',
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _body() {
    return Stack(
      children: <Widget>[
        RefreshIndicator(
          onRefresh: _fetchCurrentCheckoutData,
          child: ListView.builder(
            itemCount: _currentCheckoutItemJasa.length,
            itemBuilder: (_, idx) {
              var itemData = _currentCheckoutItemJasa[idx];
              return Dismissible(
                key: Key(itemData.jasa.id),
                background: Container(
                  color: Theme.of(context).buttonColor,
                ),
                onDismissed: (direction) {
                  _removeItem(itemData);
                },
                child: ListTile(
                  leading: Container(
                    height: 40,
                    width: 40,
                    child: Image.network(
                      itemData.photoDownloadURL,
                    ),
                  ),
                  title: Text(
                    itemData.jasa.namajs,
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  subtitle: Text(
                    '${rupiahFormatter.format(_hargaSetelahDiskon(itemData.jasa))}',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      child: CustomNumberPicker(
                        onValue: (val) {
                          _updateCheckoutAmount(
                            itemData,
                            val,
                          );
                        },
                        initialValue: itemData.amount,
                        maxValue: 100,
                        minValue: 1,

                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(
            top: 420.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
              _dateTime != null ? DateFormat('dd MMMM yyyy').format(_dateTime!) : "Pilih Tanggal Booking",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold, 
                  ),
              ),
              ElevatedButton(
                onPressed: _dateTime == null ? null : () async{
                  DateTime? _newDate = await showDatePicker(
                    context: context, 
                    initialDate: DateTime.now()
                    firstDate: DateTime.now() 
                    lastDate: DateTime.now().add(Duration(days: 30)),
                    );
                    if (_newDate != null){
                      setState(() {
                        _dateTime = _newDate;
                        timestamp1 = _newDate.millisecondsSinceEpoch;
                        tglplus1 = DateTime.fromMillisecondsSinceEpoch(timestamp1);
                        tglplus1 = tglplus1!.add(Duration(days: 1));
                        timestamp2 = tglplus1!.millisecondsSinceEpoch;
                      });
                    }
                },
                child: const Text('Pilih Tanggal Booking',
                style: const TextStyle(
                  color: Colors.white
                )),
              ),
            ],
          )
        ),
        Container(
          alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            bottom: 10.0,
          ),
          child: Container(
            height: 100.0,
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
            padding: const EdgeInsets.only(
              top: 20.0,
              left: 10.0,
              right: 10.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '${rupiahFormatter.format(_hargaTotal(_currentCheckoutItemJasa))}',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  child: MaterialButton(
                    child: Text(
                      'Beli Sekarang',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _currentCheckoutItemJasa.isNotEmpty
                        ? _navigateToConfirmationPage
                        : null,
                    color: Theme.of(context).buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
