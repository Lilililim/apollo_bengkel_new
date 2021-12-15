import 'package:apollo_bengkel/models/CheckoutHistoryItem.dart';
import 'package:apollo_bengkel/models/CheckoutItemData.dart';
import 'package:apollo_bengkel/pages/checkout_page/checkout_page.dart';
import 'package:apollo_bengkel/pages/confirmation_page/confirmation_page.dart';
import 'package:apollo_bengkel/pages/home_page/home_page.dart';
import 'package:apollo_bengkel/pages/login_page/login_page.dart';
import 'package:apollo_bengkel/pages/order_histories_page/order_histories_page.dart';
import 'package:apollo_bengkel/pages/order_history_detail_page/order_history_detail_page.dart';
import 'package:apollo_bengkel/pages/payment_method_page/payment_method_page.dart';
import 'package:apollo_bengkel/pages/product_detail_page/product_detail_page.dart';
import 'package:apollo_bengkel/pages/product_list_page/product_list_page.dart';
import 'package:apollo_bengkel/pages/profile_page/profile_page.dart';
import 'package:apollo_bengkel/pages/register_page/register_page.dart';
import 'package:apollo_bengkel/pages/splashscreen_page/splashscreen_page.dart';
import 'package:apollo_bengkel/pages/success_buy_page/success_buy_page.dart';
import 'package:apollo_bengkel/utils.dart';
import 'package:flutter/material.dart';
import 'package:apollo_bengkel/pages/jasa_detail_page/jasa_detail_page.dart';
import 'package:apollo_bengkel/pages/jasa_list_page/jasa_list_page.dart';

Route? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/splash_page':
      return MaterialPageRoute(
        builder: (_) => SplashScreenPage(),
      );
    case '/login_page':
      return MaterialPageRoute(
        builder: (_) => LoginPage(),
      );
    case '/register_page':
      return MaterialPageRoute(
        builder: (_) => RegisterPage(),
      );
    case '/home_page':
      return MaterialPageRoute(
        builder: (_) => HomePage(),
      );
    case '/profile_page':
      return MaterialPageRoute(
        builder: (_) => ProfilePage(),
      );
    case '/product_list_page':
      var args = (settings.arguments as Map<String, dynamic>);
      var kategoriProduk = args['kategoriProduk'] as KategoriProductListPage;
      return MaterialPageRoute(
        builder: (_) =>
            ProductListPage(initialKategoriProductListPage: kategoriProduk),
      );
    case '/product_detail_page':
      var product = ((settings.arguments) as Map<String, dynamic>)['product'];
      return MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      );
    case '/checkout_page':
      return MaterialPageRoute(
        builder: (_) => CheckoutPage(),
      );
    case '/confirmation_page':
      var args = (settings.arguments as Map<String, dynamic>);
      var checkoutItemDatas =
          args['checkoutItemDatas'] as List<CheckoutItemData>;
      return MaterialPageRoute(
        builder: (_) => ConfirmationPage(
          checkoutItemDatas: checkoutItemDatas,
        ),
      );
    case '/success_buy_page':
      var args = (settings.arguments as Map<String, dynamic>);
      var checkoutHistoryItemId = args['checkoutHistoryItemId'] as String;

      return MaterialPageRoute(
        builder: (_) => SuccessBuyPage(
          checkoutHistoryItemId: checkoutHistoryItemId,
        ),
      );

    case '/order_histories_page':
      return MaterialPageRoute(
        builder: (_) => OrderHistoriesPage(),
      );

    case '/payment_method_page':
      return MaterialPageRoute(
        builder: (_) => PaymentMethodPage(),
      );

    case '/order_history_detail_page':
      var args = (settings.arguments as Map<String, dynamic>);
      var checkoutHistoryItem =
          args['checkoutHistoryItem'] as CheckoutHistoryItem;
      return MaterialPageRoute(
        builder: (_) => OrderHistoryDetailPage(
          checkoutHistoryItem: checkoutHistoryItem,
        ),
      );
    case '/jasa_list_page':
      var args = (settings.arguments as Map<String, dynamic>);
      var kategoriJasa = args['kategoriJasa'] as KategoriJasaListPage;
      return MaterialPageRoute(
        builder: (_) =>
            JasaListPage(initialKategoriJasaListPage: kategoriJasa),
      );
    case '/jasa_detail_page':
      var jasa = ((settings.arguments) as Map<String, dynamic>)['jasa'];
      return MaterialPageRoute(
        builder: (_) => JasaDetailPage(jasa: jasa),
      );
    default:
      return null;
  }
}
