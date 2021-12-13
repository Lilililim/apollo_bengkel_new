import 'package:apollo_bengkel/components/shopping_cart_button.dart';
import 'package:apollo_bengkel/pages/product_list_page/product_grid_view.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

class JasaListPage extends StatefulWidget {
  const JasaListPage({required this.initialKategoriJasaListPage});

  final KategoriProductListPage initialKategoriJasaListPage;

  @override
  _JasaListPageState createState() =>
      _JasaListPageState(kategoriJasa: initialKategoriJasaListPage);
}

class _JasaListPageState extends State<JasaListPage>
    with TickerProviderStateMixin {
  _JasaListPageState({required this.kategoriJasa});

  KategoriProductListPage kategoriJasa;

  TabController? _tabController;

  void _navigateToCheckoutPage() {
    Navigator.pushNamed(context, '/checkout_page').then((_) => setState(() {}));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: kategoriToInt(kategoriJasa)!,
      length: 5,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          ProductGridView(
            kategoriProductListPage: KategoriProductListPage.All,
          ),
          ProductGridView(
            kategoriProductListPage: KategoriProductListPage.Jasa_oli,
          ),
          ProductGridView(
            kategoriProductListPage: KategoriProductListPage.Jasa_ban,
          ),
          ProductGridView(
            kategoriProductListPage: KategoriProductListPage.Jasa_injeksi,
          ),
          ProductGridView(
            kategoriProductListPage: KategoriProductListPage.Jasa_CVT,
          ),
        ]
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                ),
                child: e,
              ),
            )
            .toList(),
      ),
    );
  }

  PreferredSizeWidget? _appBar() {
    return AppBar(
      title: Text(
        'Katalog Produk',
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_outlined,
          color: Colors.blue,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
          30.0,
        ),
        child: TabBar(
          isScrollable: true,
          unselectedLabelColor: Colors.white.withOpacity(
            0.3,
          ),
          indicatorColor: Colors.blue,
          controller: _tabController,
          tabs: [
            Tab(
              child: Icon(
                FontAwesome.food,
                color: Colors.grey[400],
              ),
            ),
            Tab(
              child: Icon(
                RpgAwesome.meat,
                color: Colors.pink[300],
              ),
            ),
            Tab(
              child: Icon(
                FontAwesome5.carrot,
                color: Colors.orange,
              ),
            ),
            Tab(
              child: Icon(
                FontAwesome5.apple_alt,
                color: Colors.red,
              ),
            ),
            Tab(
              child: Icon(
                RpgAwesome.bubbling_potion,
                color: Colors.brown[400],
              ),
            ),
          ]
              .map(
                (e) => Container(
                  child: e,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                ),
              )
              .toList(),
        ),
      ),
      actions: <Widget>[
        ShoppingCartButton(
          onPressed: _navigateToCheckoutPage,
        ),
      ],
    );
  }
}