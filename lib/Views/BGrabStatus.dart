import 'package:flutter/material.dart';

class BGrabStatus {
  var id;
  var notification;
  var title;
  var color;
  BGrabStatus.all() {
    id = "";
    title = "Semua Status";
  }
  BGrabStatus.SUBMITTED() {
    id = "SUBMITTED";
    title = "Belum dikonfirmasi";
    notification = "Belum dikonfirmasi";
    color = Colors.amber[600];
  }
  BGrabStatus.ACCEPTED() {
    id = "ACCEPTED";
    title = "Pesanan berhasil dikonfirmasi";
    notification = "Pesanan berhasil dikonfirmasi";
    color = Colors.amber[600];
  }
  BGrabStatus.BOOKING() {
    id = "BOOKING";
    title = "Mencari Kurir...";
    notification = "Mencari Kurir...";
    color = Colors.red[600];
  }
  BGrabStatus.DRIVER_ALLOCATED() {
    id = "DRIVER_ALLOCATED";
    title = "Kurir segera mengambil pesanan";
    notification = "Kurir segera mengambil pesanan";
    color = Colors.amber[600];
  }
  BGrabStatus.DRIVER_ARRIVED() {
    id = "DRIVER_ARRIVED";
    title = "Kurir telah sampai di Outlet";
    notification = "Kurir telah sampai di Outlet";
    color = Colors.amber[600];
  }
  BGrabStatus.COLLECTED() {
    id = "COLLECTED";
    title = "Pesanan telah diambil Kurir";
    notification = "Pesanan telah diambil Kurir";
    color = Colors.amber[600];
  }
  BGrabStatus.DELIVERED() {
    id = "DELIVERED";
    title = "Pesanan berhasil diantarkan";
    notification = "Pesanan berhasil diantarkan";
    color = Colors.green[600];
  }
  BGrabStatus.CANCELLED() {
    id = "CANCELLED";
    title = "Pesanan telah dibatalkan";
    notification = "Pesanan telah dibatalkan";
    color = Colors.red[600];
  }
  BGrabStatus.FAILED() {
    id = "FAILED";
    title = "Pesanan Gagal";
    notification = "Pesanan Gagal";
    color = Colors.red[600];
  }
  BGrabStatus.READY_FOR_PICKUP() {
    id = "READY_FOR_PICKUP";
    title = "Siap diambil Kurir";
    notification = "Siap diambil Kurir";
    color = Colors.red[600];
  }
  BGrabStatus.OUT_FOR_PICKUP() {
    id = "OUT_FOR_PICKUP";
    title = "Dalam penjemputan";
    notification = "Dalam penjemputan";
    color = Colors.amber[600];
  }
  BGrabStatus.OUT_FOR_DELIVERY() {
    id = "OUT_FOR_DELIVERY";
    title = "Dalam pengiriman";
    notification = "Dalam pengiriman";
    color = Colors.amber[600];
  }
  BGrabStatus.DELIVERY_CANCELLED() {
    id = "DELIVERY_CANCELLED";
    title = "Pengiriman dibatalkan";
    notification = "Pengiriman dibatalkan";
    color = Colors.red[600];
  }
  BGrabStatus.DELIVERY_REJECTED() {
    id = "DELIVERY_REJECTED";
    title = "Pengiriman ditolak";
    notification = "Pengiriman ditolak";
    color = Colors.red[600];
  }
  BGrabStatus.NO_DRIVER() {
    id = "NO_DRIVER";
    title = "Kurir tidak tersedia";
    notification = "Kurir tidak tersedia";
    color = Colors.red[600];
  }
  BGrabStatus.ON_HOLD() {
    id = "ON_HOLD";
    title = "Menunggu pencarian Kurir";
    notification = "Menunggu pencarian Kurir";
    color = Colors.red[600];
  }
  BGrabStatus.IN_RETURN() {
    id = "IN_RETURN";
    title = "Pesanan sedang dikembalikan";
    notification = "Pesanan sedang dikembalikan";
    color = Colors.amber[600];
  }
  BGrabStatus.RETURNED() {
    id = "RETURNED";
    title = "Pesanan berhasil dikembalikan";
    notification = "Pesanan berhasil dikembalikan";
    color = Colors.amber[600];
  }

  BGrabStatus.ORDER_NEED_CONFIRMATION() {
    id = "ORDER_NEED_CONFIRMATION";
    title = " akan berakhir sebentar lagi ";
    notification = " akan berakhir sebentar lagi ";
    color = Colors.amber[600];
  }

  BGrabStatus.STACK_ORDER_NEED_CONFIRMATION() {
    id = "STACK_ORDER_NEED_CONFIRMATION";
    title = " menunggu konfirmasi Anda";
    notification = " menunggu konfirmasi Anda";
    color = Colors.amber[600];
  }
}
