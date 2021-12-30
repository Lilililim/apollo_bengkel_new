import 'package:apollo_bengkel/pages/payment_account_jasa/cash_tab_js.dart';
import 'package:apollo_bengkel/pages/payment_account_jasa/virtual_account_tab_js.dart';
import 'package:flutter/material.dart';

class PaymentMethodPageJs extends StatefulWidget {
  const PaymentMethodPageJs({Key? key}) : super(key: key);

  @override
  _PaymentMethodPageJsState createState() => _PaymentMethodPageJsState();
}

class _PaymentMethodPageJsState extends State<PaymentMethodPageJs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      initialIndex: 0,
      vsync: this,
    );
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
        onPressed: _goBack,
        icon: Icon(
          Icons.arrow_back_ios_outlined,
          color: Colors.blue,
        ),
      ),
      title: Text(
        'Pilih Metode Pembayaran',
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
      bottom: PreferredSize(
        child: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.white.withOpacity(
            0.3,
          ),
          indicatorColor: Colors.blue,
          tabs: [
            Tab(
              child: Text(
                'Virtual Account',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Cash',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        preferredSize: Size.fromHeight(
          30.0,
        ),
      ),
    );
  }

  Widget _body() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        VirtualAccountTabJs(),
        CashTabJs(),
      ],
    );
  }
}
