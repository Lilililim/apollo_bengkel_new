import 'package:apollo_bengkel/models/CheckoutJasa.dart';
import 'package:apollo_bengkel/utils.dart';

enum StatusCheckoutHistoryItem {
  Belum_Datang,
  DiKerjakan,
  Selesai,
}

class CheckoutHistoryJasa {
  CheckoutHistoryJasa({
    this.id,
    required this.userId,
    required this.time,
    required this.checkoutJasas,
    // required this.antrian,
    required this.status,
    required this.paymentMethod,
    this.noVirtualAccount,
    this.bank,
  });

  String? id;
  final String userId;
  final DateTime time;
  final List<CheckoutJasa> checkoutJasas;
  // final int antrian;
  StatusCheckoutHistoryItem status;
  final PaymentMethod paymentMethod;

  /// field tidak null hanya jika [paymentMethod] bernilai VirtualAccount
  String? noVirtualAccount;
  Bank? bank;

  factory CheckoutHistoryJasa.fromJSON(Map<String, dynamic> map) =>
      CheckoutHistoryJasa(
        id: map['id'],
        userId: map['user_id'],
        time: DateTime.fromMillisecondsSinceEpoch(map['time']),
        checkoutJasas: (map['checkout_jasa'] as List)
            .map((e) => CheckoutJasa.fromJSON(e))
            .toList(),
        // antrian: map['no_antrian'],
        status: stringToStatus(map['status']),
        paymentMethod: stringToPaymentMethod(map['payment_method']),
        noVirtualAccount: map['no_vc'],
        bank: stringToBank(map['bank']),
      );

  Map<String, dynamic> toJSON() => {
        'user_id': userId,
        'time': time.millisecondsSinceEpoch,
        'checkout_jasa': checkoutJasas.map((e) => e.toJSON()).toList(),
        // 'no_antrian': antrian.map((e)=>e.to),
        'status': statusToString(status),
        'payment_method': paymentMethodToString(paymentMethod),
        'no_vc': noVirtualAccount,
        'bank': bankToString(bank),
      };

  static PaymentMethod stringToPaymentMethod(String paymentMethod) {
    var paymentMethodMap =
        PaymentMethod.values.fold<Map<String, PaymentMethod>>(
            {},
            (p, e) => {
                  ...p,
                  e.toString().replaceFirst('PaymentMethod.', ''): e,
                });

    return paymentMethodMap[paymentMethod]!;
  }

  static Bank? stringToBank(String? bank) {
    var bankMap = Bank.values.fold<Map<String, Bank>>(
        {},
        (p, e) => {
              ...p,
              e.toString().replaceFirst('Bank.', ''): e,
            });

    return bankMap[bank];
  }

  static StatusCheckoutHistoryItem stringToStatus(String status) {
    var statusMap = StatusCheckoutHistoryItem.values
        .fold<Map<String, StatusCheckoutHistoryItem>>(
            {},
            (p, e) => {
                  ...p,
                  e.toString().replaceFirst('StatusCheckoutHistoryItem.', ''):
                      e,
                });

    return statusMap[status]!;
  }

  static String paymentMethodToString(PaymentMethod paymentMethod) {
    var paymentMethodMap =
        PaymentMethod.values.fold<Map<PaymentMethod, String>>(
            {},
            (p, e) => {
                  ...p,
                  e: e.toString().replaceFirst('PaymentMethod.', ''),
                });

    return paymentMethodMap[paymentMethod]!;
  }

  static String? bankToString(Bank? bank) {
    var bankMap = Bank.values.fold<Map<Bank, String>>(
        {},
        (p, e) => {
              ...p,
              e: e.toString().replaceFirst('Bank.', ''),
            });

    return bankMap[bank];
  }

  static String statusToString(StatusCheckoutHistoryItem status) {
    var statusMap = StatusCheckoutHistoryItem.values
        .fold<Map<StatusCheckoutHistoryItem, String>>(
            {},
            (p, e) => {
                  ...p,
                  e: e
                      .toString()
                      .replaceFirst('StatusCheckoutHistoryItem.', ''),
                });

    return statusMap[status]!;
  }
}
