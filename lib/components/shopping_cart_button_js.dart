import 'package:badges/badges.dart';
import 'package:apollo_bengkel/firebase.dart';
import 'package:flutter/material.dart';

class ShoppingCartButtonJasa extends StatefulWidget {
  const ShoppingCartButtonJasa({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final void Function() onPressed;

  @override
  _ShoppingCartButtonJasaState createState() => _ShoppingCartButtonJasaState(
        onPressed: onPressed,
      );
}

class _ShoppingCartButtonJasaState extends State<ShoppingCartButtonJasa> {
  _ShoppingCartButtonJasaState({
    required this.onPressed,
  });

  final void Function() onPressed;

  Future<num> _fetchShoppingAmounts() {
    return firestore
        .collection('/users')
        .where('email', isEqualTo: fireAuth.currentUser!.email)
        .get()
        .then(
          (col) => (col.docs.first.data()['current_checkout_jasa'] as List)
              .fold<num>(
            0,
            (prev, curr) => prev + curr['amount'],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Badge(
        padding: const EdgeInsets.all(3),
        badgeContent: FutureBuilder(
          future: _fetchShoppingAmounts(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(
                '${snapshot.hasData ? snapshot.data : 0}',
                style: TextStyle(
                  fontSize: 12,
                ),
              );
            }

            return Text(
              '',
            );
          },
        ),
        child: Icon(
          Icons.shopping_cart_outlined,
          color: Colors.blue,
        ),
      ),
    );
  }
}
