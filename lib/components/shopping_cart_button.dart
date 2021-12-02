import 'package:badges/badges.dart';
import 'package:apollo_bengkel/firebase.dart';
import 'package:flutter/material.dart';

class ShoppingCartButton extends StatefulWidget {
  const ShoppingCartButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final void Function() onPressed;

  @override
  _ShoppingCartButtonState createState() => _ShoppingCartButtonState(
        onPressed: onPressed,
      );
}

class _ShoppingCartButtonState extends State<ShoppingCartButton> {
  _ShoppingCartButtonState({
    required this.onPressed,
  });

  final void Function() onPressed;

  Future<num> _fetchShoppingAmounts() {
    return firestore
        .collection('/users')
        .where('email', isEqualTo: fireAuth.currentUser!.email)
        .get()
        .then(
          (col) => (col.docs.first.data()['current_checkout_items'] as List)
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
