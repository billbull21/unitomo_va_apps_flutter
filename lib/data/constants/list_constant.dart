import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final List<String> listItemAchievement = ["SEMUA", "DIBAWAH 30%", "DIBAWAH 50%", "DIBAWAH 100%",];
final List<String> listStatusSO = ["SEMUA", "IN PROCESS", "IN APPROVAL", "APPROVED", "REJECTED", "REVISED", "COMPLETE"];
final List<String> listStatusKirimSO = ["SEMUA", "TERKIRIM < 30%", "TERKIRIM < 50%", "TERKIRIM < 80%", "TERKIRIM  < 100%", "TERKIRIM 100% ATAU LEBIH"];
final List<String> listItemType = ["FINISH GOOD", "WIP", "SPARE PART"];
final List<Map> listSorting = [
  {
    'id': "DESC",
    'name': "TURUN",
  },
  {
    'id': "ASC",
    'name': "NAIK",
  },
];
final List<Map> listFields = [
  {
    'id': "crdlimitperc",
    'name': "BY PERCENTAGE (%)",
  },
  {
    'id': "crdlimit",
    'name': "BY USAGE",
  },
];
final List<String> listSortingByCollection = ["TGL TAGIHAN", "TGL JATUH TEMPO", "SELISIH JATUH TEMPO"];
final List<String> listFilterDisplayCollection = ["SEMUA", "LEWAT JATUH TEMPO", "BELUM JATUH TEMPO"];
final List<String> listDisplayOmsetTarget = ["BULAN BERJALAN", "1 BULAN SEBELUMNYA", "2 BULAN SEBELUMNYA", "3 BULAN SEBELUMNYA"];
final List<String> listSortingByStock = ["STOCK REAL", "STOCK SALES"];
final List<String> listSortingByTopSellingProductDetail = ["TANGGAL SO", "QTY SO"];
final List<String> listDisplayOutstanding = ["SEMUA LIST", "STOK HABIS", "STOK MENCUKUPI"];
final List<String> listSortingOutstanding = ["STOCK REAL", "STOCK SALES", "OUTSTANDING"];
final List<String> listSortingOutstandingOrder = ["TGL SO", "TGL SJ", "OUTSTANDING"];
final List<String> listDisplayOutstandingOrder = ["SEMUA LIST", "BELUM JADI SJ", "SUDAH JADI SJ"];
final List<String> listCheckInOutReasonIn = ["TAKE ORDER", "COLLECTION", "KONFIRMASI PIUTANG", "KUNJUNGAN RUTIN", "LAIN LAIN"];
final List<String> listCheckInOutReasonOut = ["LUPA CHECKOUT", "KESALAHAN SISTEM","LAIN - LAIN"];

final now = DateTime.now();
final List<Map> listPeriodeActivities = List.generate(12, (index) {
  final date = DateTime(now.year, now.month-index, 1);
  return {
    'id': DateFormat("MMyyyy").format(date),
    'name': DateFormat("MMM yyyy", "id").format(date).toUpperCase(),
  };
});
final List<Map> listPeriode = List.generate(4, (index) {
  final date = DateTime(now.year, now.month-index, 1);
  return {
    'id': DateFormat("MMyyyy").format(date),
    'name': index == 0 ? "BULAN BERJALAN" : "$index BULAN YANG LALU",
  };
});

final List<Map> listScheduleType = [
  {
    'id': "UPCOMING",
    'name': "UPCOMING",
    'icon': Icons.schedule,
  },
  {
    'id': "UNDONE",
    'name': "UNDONE",
    'icon': Icons.reorder,
  },
  {
    'id': "HISTORY",
    'name': "HISTORY",
    'icon': Icons.task,
  },
];