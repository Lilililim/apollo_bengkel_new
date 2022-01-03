import 'package:apollo_bengkel/components/shopping_cart_button.dart';
import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/Product.dart';
import 'package:apollo_bengkel/models/Jasa.dart';
import 'package:apollo_bengkel/models/UserData.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      drawer: _drawer(),
      body: _body(),
    );
  }

  void _navigateToMePage() {
    Navigator.pushNamed(context, '/profile_page');
  }

  void _navigateToProductListPage(
    KategoriProductListPage kategoriProduk,
  ) {
    Navigator.pushNamed(context, '/product_list_page',
        arguments: <String, dynamic>{
          'kategoriProduk': kategoriProduk,
        }).then((_) => setState(() {}));

    /*Navigator.pushNamed(context, '/jasa_list_page',
        arguments: <String, dynamic>{
          'kategoriProduk': kategoriProduk,
        }).then((_) => setState(() {}));*/
  }

  void _navigateToJasaListPage(
    KategoriJasaListPage kategoriJasa,
  ) {
    Navigator.pushNamed(context, '/jasa_list_page',
        arguments: <String, dynamic>{
          'kategoriJasa': kategoriJasa,
        }).then((_) => setState(() {}));
  }

  /*{
    Navigator.pushNamed(context, '/jasa_list_page',
        arguments: <String, dynamic>{
          'kategoriProduk': kategoriProduk,
        }).then((_) => setState(() {}));
  }*/
  void _navigateToProductListPageWithPop(
    KategoriProductListPage kategoriProduk,
  ) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/product_list_page',
        arguments: <String, dynamic>{
          'kategoriProduk': kategoriProduk,
        }).then((_) => setState(() {}));
  }

  void _navigateToJasaListPageWithPop(
    KategoriJasaListPage kategoriJasa,
  ) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/jasa_list_page',
        arguments: <String, dynamic>{
          'kategoriJasa': kategoriJasa,
        }).then((_) => setState(() {}));
  }

  void _navigateToTransactionHistory() {
    Navigator.pushNamed(context, '/order_histories_page');
  }

  void _logout() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure ?'),
        actions: [
          TextButton(
            child: Text('Yes'),
            onPressed: () async {
              await fireAuth.signOut().then((_) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login_page');
              });
            },
          ),
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _fetchProductAndNavigate(String productId) async {
    var query = firestore.collection('/products').doc(productId);

    await query
        .get()
        .then((doc) => Product.fromJSON(
              <String, dynamic>{
                'id': doc.id,
                ...doc.data()!,
              },
            ))
        .then((product) {
      Navigator.pushNamed(
        context,
        '/product_detail_page',
        arguments: <String, dynamic>{
          'product': product,
        },
      );
    });
  }

  Future<UserData> _fetchUserData() {
    if (fireAuth.currentUser == null) return Future.value();

    return firestore
        .collection('/users')
        .where('email', isEqualTo: fireAuth.currentUser!.email)
        .get()
        .then(
          (snapshot) => UserData.fromJSON(snapshot.docs.first.data()),
        );
  }

  Future<void> _refreshPage() async {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'Home',
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          color: Colors.blue,
          onPressed: Scaffold.of(context).openDrawer,
          icon: Icon(
            Icons.menu,
          ),
        ),
      ),
    );
  }

  Widget _drawer() {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<UserData>(
            future: _fetchUserData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return DrawerHeader(
                  curve: Curves.bounceInOut,
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircleAvatar(
                        child: snapshot.data?.photoURL != null
                            ? Image.network(snapshot.data!.photoURL!)
                            : Image.asset('assets/logo.png'),
                        radius: 40.0,
                      ),
                      Text(
                        snapshot.data?.name ?? 'fetching...',
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        fireAuth.currentUser?.email ?? 'Please wait...',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container();
            },
          ),
          Flexible(
            //sidebar
            child: ListView(
              children: [
                ListTile(
                  title: Text(
                    'Home',
                  ),
                  leading: Icon(
                    Icons.home,
                    color: Colors.blue,
                  ),
                  onTap: () {},
                ),
                Divider(
                  thickness: 1.5,
                ),
                ExpansionTile(
                  title: Text(
                    'Store',
                  ),
                  leading: Icon(
                    Icons.store,
                    color: Colors.blue,
                  ),
                  children: [
                    ListTile(
                      title: Text(
                        'Produk',
                      ),
                      leading: Icon(
                        FontAwesome.food,
                        color: Colors.grey[400],
                      ),
                      onTap: () => _navigateToProductListPageWithPop(
                        KategoriProductListPage.All,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Jasa',
                      ),
                      leading: Icon(
                        Linecons.food,
                        color: Colors.yellow[800],
                      ),
                      onTap: () => _navigateToJasaListPageWithPop(
                        KategoriJasaListPage.Jasa_injeksi,
                      ),
                    ),
                  ]
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                          ),
                          child: e,
                        ),
                      )
                      .toList(),
                ),
                Divider(
                  thickness: 1.5,
                ),
                ListTile(
                  title: Text(
                    'Profil',
                  ),
                  leading: Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                  onTap: _navigateToMePage,
                ),
                Divider(
                  thickness: 1.5,
                ),
                ListTile(
                  title: Text(
                    'Riwayat Transaksi',
                  ),
                  leading: Icon(
                    Icons.money,
                    color: Colors.blue,
                  ),
                  onTap: _navigateToTransactionHistory,
                ),
                Divider(
                  thickness: 1.5,
                ),
                ListTile(
                  title: Text(
                    'Logout',
                  ),
                  leading: Icon(
                    Icons.logout,
                    color: Colors.blue,
                  ),
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return RefreshIndicator(
      onRefresh: _refreshPage,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              /// Section Produk
              Padding(
                padding: const EdgeInsets.only(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Katalog Part',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 22.0,
                        ),
                      ),
                      TextButton(
                        child: Row(
                          children: <Widget>[
                            Text(
                              'See All',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_outlined,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                        onPressed: () => _navigateToProductListPage(
                          KategoriProductListPage.All,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                ),
                child: Container(
                  height: 100,
                  child: GridView.count(
                    crossAxisCount: 4,
                    children: <Widget>[
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.pink,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            splashColor: Colors.pink[300],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  FontAwesome5.tint,
                                  color: Colors.pink[300],
                                ),
                                Text(
                                  'Oli',
                                  style: TextStyle(
                                    color: Colors.pink[300],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _navigateToProductListPage(
                              KategoriProductListPage.Oli,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.orange,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            splashColor: Colors.orange,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  RpgAwesome.cog_wheel,
                                  color: Colors.orange,
                                ),
                                Text(
                                  'Ban',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.orange,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                            onTap: () => _navigateToProductListPage(
                              KategoriProductListPage.Ban,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            splashColor: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  FontAwesome5.wrench,
                                  color: Colors.red,
                                ),
                                Text(
                                  'Grease CVT',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                            onTap: () => _navigateToProductListPage(
                              KategoriProductListPage.Grease_cvt,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.brown,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            splashColor: Colors.brown[400],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  FontAwesome5.broom,
                                  color: Colors.brown[400],
                                ),
                                Text(
                                  'Oli Gardan',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.brown[400],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                            onTap: () => _navigateToProductListPage(
                              KategoriProductListPage.Oli_gardan,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.brown,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            splashColor: Colors.brown[400],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  RpgAwesome.bubbling_potion,
                                  color: Colors.brown[400],
                                ),
                                Text(
                                  'Oli_gardan',
                                  style: TextStyle(
                                    color: Colors.brown[400],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _navigateToProductListPage(
                              KategoriProductListPage.Oli_gardan,
                            ),
                          ),
                        ),
                      ),
                    ].map(
                      (e) {
                        return Padding(
                          padding: const EdgeInsets.all(
                            12.0,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: e,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),

              /// Section Jasa
              Padding(
                padding: const EdgeInsets.only(
                  top: 100.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Booking Service',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 22.0,
                        ),
                      ),
                      /*TextButton(
                        child: Row(
                          children: <Widget>[
                            Text(
                              'See All',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_outlined,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                        onPressed: () => _navigateToProductListPage(
                          KategoriProductListPage.All,
                        ),
                      ),*/
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                ),
                child: Container(
                  height: 100,
                  child: GridView.count(
                    crossAxisCount: 4,
                    children: <Widget>[
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.pink,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            splashColor: Colors.pink[300],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  FontAwesome5.tint,
                                  color: Colors.pink[300],
                                ),
                                Text(
                                  'Ganti Oli',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.pink[300],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                            onTap: () => _navigateToJasaListPage(
                              KategoriJasaListPage.Jasa_oli,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.orange,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            splashColor: Colors.orange,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  RpgAwesome.cog_wheel,
                                  color: Colors.orange,
                                ),
                                Text(
                                  'Ganti Ban',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.orange,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                            onTap: () => _navigateToJasaListPage(
                              KategoriJasaListPage.Jasa_oli,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            splashColor: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  FontAwesome5.wrench,
                                  color: Colors.red,
                                ),
                                Text(
                                  'Service Injeksi',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                            onTap: () => _navigateToJasaListPage(
                              KategoriJasaListPage.Jasa_injeksi,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.brown,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            splashColor: Colors.brown[400],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  FontAwesome5.broom,
                                  color: Colors.brown[400],
                                ),
                                Text(
                                  'Service CVT',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.brown[400],
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                            onTap: () => _navigateToJasaListPage(
                              KategoriJasaListPage.Jasa_CVT,
                            ),
                          ),
                        ),
                      ),
                      /*Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.brown,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              20,
                            ),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            splashColor: Colors.brown[400],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  RpgAwesome.bubbling_potion,
                                  color: Colors.brown[400],
                                ),
                                Text(
                                  'Oli_gardan',
                                  style: TextStyle(
                                    color: Colors.brown[400],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _navigateToProductListPage(
                              KategoriProductListPage.Oli_gardan,
                            ),
                          ),
                        ),
                      ),*/
                    ].map(
                      (e) {
                        return Padding(
                          padding: const EdgeInsets.all(
                            12.0,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: e,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
