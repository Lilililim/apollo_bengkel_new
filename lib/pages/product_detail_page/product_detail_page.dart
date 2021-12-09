import 'package:apollo_bengkel/components/add_to_cart_layout_pr.dart';
import 'package:apollo_bengkel/components/shopping_cart_button.dart';
import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/Product.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  ProductDetailPage({
    required this.product,
  });

  final Product product;

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState(
        product: product,
      );
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  _ProductDetailPageState({
    required this.product,
  });

  Product product;

  late final AnimationController _checkoutAnimationController =
      AnimationController(
    vsync: this,
    duration: Duration(
      seconds: 2,
    ),
  );

  late final Animation<Offset> _checkoutOffsetAnimation = Tween<Offset>(
    begin: Offset(0, 1),
    end: Offset.zero,
  ).animate(_checkoutAnimationController);

  // untuk nampung gambar agar nggak refresh tiap setState
  late Widget _productImage;

  @override
  void initState() {
    super.initState();
    _checkoutAnimationController.forward(from: 0);
    _buildImage();
  }

  void _backToCatalog() {
    Navigator.pop(context);
  }

  Future<void> _navigateToCheckoutPage() async {
    await Navigator.pushNamed(context, '/checkout_page');
  }

  Future<String> _fetchImageUrl() {
    // * uncomment these lines to fetch actual photo (ini di comment untuk hemat kuota firebase)
    var kategori = Product.kategoriToString(product.kategoriProduct);
    var photoName = product.photoNamepr;

    var ref = firestorage.refFromURL(
      'gs://apolo-bengkel.appspot.com/app/foto_produk/$kategori/$photoName',
    );

    return ref.getDownloadURL();
  }

  Future<void> _refreshPage() async {
    setState(() {});
    print('should be refreshed');
  }

  // build image di awal agar tidak refresh saat setState
  void _buildImage() {
    _productImage = FutureBuilder<String>(
      future: _fetchImageUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return FittedBox(
              fit: BoxFit.fill,
              child: Image.network(
                snapshot.data!,
                fit: BoxFit.fill,
              ),
            );
          }

          return FittedBox(
            fit: BoxFit.fill,
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.fill,
            ),
          );
        }

        return Center(
          child: CircularProgressIndicator(),
        );
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

  Widget _body() {
    return RefreshIndicator(
      onRefresh: _refreshPage,
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                right: 10.0,
                left: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 200,
                    padding: const EdgeInsets.only(
                      right: 20.0,
                      left: 20.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                        child: _productImage,
                      ),
                    ),
                  ),

                  /// deskripsi
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 20,
                    ),
                    child: Text(
                      'Deskripsi',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 20,
                    ),
                    child: Text(
                      product.deskripsipr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 130,
                  ),
                ],
              ),
            ),
          ),
          SlideTransition(
            position: _checkoutOffsetAnimation,
            child: AddToCartLayout(
              product: product,
              refreshCallBack: _refreshPage,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: _backToCatalog,
        icon: Icon(
          Icons.arrow_back_ios_outlined,
          color: Colors.blue,
        ),
      ),
      title: Text(
        product.namapr,
        style: TextStyle(
          color: Colors.blue,
        ),
        maxLines: 1,
        overflow: TextOverflow.fade,
      ),
      actions: <Widget>[
        ShoppingCartButton(
          onPressed: _navigateToCheckoutPage,
        ),
      ],
    );
  }
}
