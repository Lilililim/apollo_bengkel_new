import 'dart:math';

import 'package:apollo_bengkel/utils.dart';

List<String> constructSteps(Bank bank) {
  var bankName = bank.toString().replaceFirst(r'Bank.', '');
  return [
    'Buka aplikasi layanan bank $bankName.',
    'Lakukan login.',
    'Pada menu utama, pilih transfer antar bank.',
    'Pada form, masukkan nomor virtual account yang dibuat setelah anda menekan tombol konfirmasi pembelian.',
    'Lalu konfirmasi dan selesaikan transaksi.',
  ];
}

String getRandom16Digit() {
  return '0000' +
      List<int>.generate(12, (index) => Random().nextInt(9))
          .fold('', (p, e) => '$p$e');
}
