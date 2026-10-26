import 'data.dart';
import 'input.dart';

// ============================================================
// Fungsi bantu
// ============================================================

/// Mencari barang berdasarkan kode. Mengembalikan null jika tidak ada.
Map<String, dynamic>? cariByKode(String kode) {
  for (final barang in daftarBarang) {
    if (barang['kode'] == kode) return barang;
  }
  return null;
}

/// Menghitung total harga semua barang di keranjang (sebelum diskon).
int hitungTotal() {
  var total = 0;
  keranjang.forEach((kode, jumlah) {
    final barang = cariByKode(kode)!;
    total += (barang['harga'] as int) * jumlah;
  });
  return total;
}

/// Mencetak isi keranjang beserta subtotal setiap barang.
void cetakIsiKeranjang(Map<String, int> isi) {
  isi.forEach((kode, jumlah) {
    final barang = cariByKode(kode)!;
    final harga = barang['harga'] as int;
    print(
      '$kode | ${barang['nama']} | $jumlah x Rp$harga = Rp${harga * jumlah}',
    );
  });
}

// ============================================================
// Fitur yang sudah jadi
// ============================================================

/// Menu 1: menampilkan semua barang.
void tampilkanBarang() {
  print('\n=== Daftar Barang ===');
  for (final barang in daftarBarang) {
    print(
      '${barang['kode']} | ${barang['nama']} | '
      'Rp${barang['harga']} | stok ${barang['stok']}',
    );
  }
}

/// Menu 2: memasukkan barang ke keranjang.
void tambahKeKeranjang() {
  print('\n=== Tambah ke Keranjang ===');
  final kode = bacaTeks('Kode barang').toUpperCase();
  final barang = cariByKode(kode);
  if (barang == null) {
    print('Barang dengan kode $kode tidak ditemukan.');
    return;
  }
  final jumlah = bacaInt('Jumlah', min: 1, max: 1000);
  final sudahDiKeranjang = keranjang[kode] ?? 0;
  final stok = barang['stok'] as int;
  if (sudahDiKeranjang + jumlah > stok) {
    print(
      'Stok tidak cukup. Stok ${barang['nama']}: $stok, '
      'di keranjang: $sudahDiKeranjang.',
    );
    return;
  }
  keranjang[kode] = sudahDiKeranjang + jumlah;
  print('$jumlah ${barang['nama']} masuk ke keranjang.');
}

/// Menu 3: menampilkan isi keranjang, diskon, dan total bayar.
void tampilkanKeranjang() {
  print('\n=== Keranjang ===');
  if (keranjang.isEmpty) {
    print('Keranjang kosong.');
    return;
  }
  cetakIsiKeranjang(keranjang);
  final total = hitungTotal();
  final diskon = hitungDiskon(total);
  print('Total      : Rp$total');
  print('Diskon     : Rp$diskon');
  print('Total bayar: Rp${total - diskon}');
}

// ============================================================
// Fitur pilihan (pilih minimal 3, lihat README.md)
// ============================================================

/// Menu 4 [Mudah]: menambah barang baru ke daftar barang.

void tambahBarangBaru() {
  print('\n=== Tambah Barang Baru ===');

  final kode = bacaTeks('Kode barang').toUpperCase();

  if (cariByKode(kode) != null) {
    print('Kode barang $kode sudah digunakan.');
    return;
  }

  final nama = bacaTeks('Nama barang');
  final harga = bacaInt('Harga', min: 1);
  final stok = bacaInt('Stok', min: 0);

  daftarBarang.add({
    'kode': kode,
    'nama': nama,
    'harga': harga,
    'stok': stok,
  });

  print('Barang $nama berhasil ditambahkan.');
}


/// Menu 5 [Mudah]: menghapus satu barang dari keranjang.
void hapusDariKeranjang() {
  print('\n=== Hapus dari Keranjang ===');

  final kode = bacaTeks('Kode barang').toUpperCase();

  if (!keranjang.containsKey(kode)) {
    print('Barang $kode tidak ada di keranjang.');
    return;
  }

  keranjang.remove(kode);
  print('Barang $kode dihapus dari keranjang.');
}
/// [Sedang] Menghitung potongan diskon dari [total] belanja.
///
/// Fungsi ini sudah dipakai di menu 3. Selama belum dibuat, diskon selalu 0.

int hitungDiskon(int total) {
  if (total >= batasDiskonBesar) {
    return total * persenDiskonBesar ~/ 100;
  } else if (total >= batasDiskonKecil) {
    return total * persenDiskonKecil ~/ 100;
  }
  return 0;
}

/// Menu 6 [Sedang]: membayar belanjaan di keranjang.


int hitungKembalian(int totalBayar, int uang) {
  if (uang < totalBayar) {
    throw Exception('Uang yang diterima kurang.');
  }

  return uang - totalBayar;
}


void bayar() {
  print('\n=== Pembayaran ===');

  if (keranjang.isEmpty) {
    print('Keranjang kosong. Tidak bisa melakukan pembayaran.');
    return;
  }

  final total = hitungTotal();
  final diskon = hitungDiskon(total);
  final totalBayar = total - diskon;

  print('Total belanja : Rp$total');
  print('Diskon        : Rp$diskon');
  print('Total bayar   : Rp$totalBayar');

  final uang = bacaInt('Uang diterima', min: 0);

  try {
    final kembalian = hitungKembalian(totalBayar, uang);

    print('Kembalian     : Rp$kembalian');

    kurangiStok();
    simpanRiwayat(total, diskon, uang, kembalian);

    keranjang.clear();
    print('Pembayaran berhasil. Terima kasih!');
  } catch (e) {
    print('Pembayaran gagal: $e');
  }
}



/// [Sulit] Mengurangi stok barang sesuai isi keranjang.
///
/// Dipanggil dari bayar(), jadi fitur ini membutuhkan menu 6.

void kurangiStok() {
  keranjang.forEach((kode, jumlah) {
    final barang = cariByKode(kode)!;
    barang['stok'] = (barang['stok'] as int) - jumlah;
  });

  print('Stok barang berhasil diperbarui.');
}


/// [Sulit] Menyimpan transaksi yang sudah dibayar ke riwayatTransaksi.
///
/// Dipanggil dari bayar(), jadi fitur ini membutuhkan menu 6.


void simpanRiwayat(int total, int diskon, int uang, int kembalian) {
  final isiBelanja = <Map<String, dynamic>>[];

  keranjang.forEach((kode, jumlah) {
    final barang = cariByKode(kode)!;

    isiBelanja.add({
      'kode': kode,
      'nama': barang['nama'],
      'harga': barang['harga'],
      'jumlah': jumlah,
    });
  });

  riwayatTransaksi.add({
    'isiBelanja': isiBelanja,
    'total': total,
    'diskon': diskon,
    'uang': uang,
    'kembalian': kembalian,
    'tanggal': DateTime.now().toString(),
  });

  print('Transaksi berhasil disimpan ke riwayat.');
}



/// Menu 7 [Sulit]: menampilkan struk semua transaksi.


void tampilkanRiwayat() {
  print('\n=== Riwayat Transaksi ===');

  if (riwayatTransaksi.isEmpty) {
    print('Belum ada transaksi.');
    return;
  }

  for (var i = 0; i < riwayatTransaksi.length; i++) {
    final transaksi = riwayatTransaksi[i];

    print('\n--- Transaksi ${i + 1} ---');
    print('Tanggal      : ${transaksi['tanggal']}');

    print('Isi belanja:');
    final isiBelanja = transaksi['isiBelanja'];

    if (isiBelanja != null) {
      for (final item in isiBelanja) {
        final jumlah = item['jumlah'] as int;
        final harga = item['harga'] as int;

        print(
          '${item['nama']} (${item['kode']}) | '
          '$jumlah x Rp$harga = Rp${jumlah * harga}',
        );
      }
    }

    print('Total belanja: Rp${transaksi['total']}');
    print('Diskon       : Rp${transaksi['diskon']}');
    print(
      'Total bayar  : '
      'Rp${transaksi['total'] - transaksi['diskon']}',
    );
    print('Uang diterima: Rp${transaksi['uang']}');
    print('Kembalian    : Rp${transaksi['kembalian']}');
  }
}


