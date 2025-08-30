# Diagram Sequence - Sistem Kolam Renang Syariah

## 1. Diagram Sequence Registrasi Member

```mermaid
sequenceDiagram
    participant U as Pengguna
    participant S as Sistem
    participant A as Admin
    participant DB as Database
    participant E as Email/SMS

    U->>S: Akses Halaman Registrasi
    S->>U: Tampilkan Form Registrasi

    U->>S: Isi Form Registrasi
    S->>DB: Validasi Data Pengguna
    DB->>S: Hasil Validasi

    U->>S: Upload Dokumen
    S->>DB: Simpan Dokumen
    DB->>S: URL Dokumen

    U->>S: Pilih Paket
    S->>DB: Dapatkan Detail Paket
    DB->>S: Informasi Paket

    U->>S: Kirim Registrasi
    S->>DB: Buat Akun Sementara
    DB->>S: Akun Dibuat

    S->>A: Notifikasi Admin: Registrasi Baru
    A->>S: Akses Panel Admin

    A->>S: Review Dokumen
    S->>DB: Dapatkan Dokumen Pengguna
    DB->>S: Data Dokumen

    A->>S: Setujui/Tolak Registrasi
    alt Registrasi Disetujui
        S->>DB: Aktifkan Akun Pengguna
        DB->>S: Akun Diaktifkan
        S->>DB: Generate Kartu Member
        DB->>S: Data Kartu Member
        S->>E: Kirim Email/SMS Selamat Datang
        E->>U: Pesan Selamat Datang
    else Registrasi Ditolak
        S->>E: Kirim Pemberitahuan Penolakan
        E->>U: Detail Penolakan
    end
```

## 2. Diagram Sequence Proses Booking

```mermaid
sequenceDiagram
    participant U as Pengguna
    participant S as Sistem
    participant C as Kalender
    participant P as Pembayaran
    participant DB as Database
    participant E as Email/SMS

    U->>S: Akses Halaman Booking
    S->>C: Muat Interface Kalender
    C->>S: Data Bulan Saat Ini

    U->>C: Navigasi ke Bulan Depan
    C->>S: Data Bulan Depan
    S->>U: Tampilkan Kalender

    U->>S: Pilih Tanggal Tersedia
    S->>DB: Dapatkan Ketersediaan Sesi
    DB->>S: Data Sesi

    S->>U: Tampilkan Opsi Sesi
    U->>S: Pilih Sesi
    S->>DB: Periksa Kapasitas Sesi
    DB->>S: Status Kapasitas

    U->>S: Pilih Tipe Pengguna (Member/Tamu)
    alt Pengguna Member
        U->>S: Login ke Akun
        S->>DB: Validasi Kredensial
        DB->>S: Profil Pengguna
    else Pengguna Tamu
        U->>S: Isi Form Tamu
        S->>DB: Buat Record Tamu
        DB->>S: ID Tamu
    end

    S->>DB: Hitung Total Biaya
    DB->>S: Informasi Harga
    S->>U: Tampilkan Ringkasan Booking

    U->>S: Konfirmasi Booking
    S->>P: Inisiasi Proses Pembayaran

    alt Pembayaran Manual
        P->>S: Tampilkan Instruksi Transfer
        S->>U: Instruksi Pembayaran
        U->>S: Upload Bukti Pembayaran
        S->>DB: Simpan Bukti Pembayaran
        DB->>S: Bukti Tersimpan

        S->>A: Notifikasi Admin: Pembayaran Pending

        A->>S: Verifikasi Pembayaran
        S->>DB: Perbarui Status Pembayaran
        DB->>S: Status Diperbarui
    else Pembayaran Online
        P->>S: Proses Pembayaran Online
        S->>DB: Simpan Record Pembayaran
        DB->>S: Pembayaran Dikonfirmasi
    end

    S->>DB: Buat Record Booking
    DB->>S: Booking Dikonfirmasi
    S->>DB: Generate QR Code
    DB->>S: Data QR Code

    S->>E: Kirim Konfirmasi
    E->>U: Konfirmasi Booking
    S->>U: Tampilkan Detail Booking
```

## 3. Diagram Sequence Proses Pesanan Kafe

```mermaid
sequenceDiagram
    participant C as Pelanggan
    participant B as Barcode Scanner
    participant S as Sistem
    participant M as Menu
    participant P as Pembayaran
    participant K as Dapur
    participant DB as Database

    C->>B: Scan Barcode Menu
    B->>S: Data Barcode
    S->>DB: Dapatkan Menu berdasarkan Lokasi
    DB->>S: Item Menu
    S->>M: Muat Interface Menu

    C->>M: Jelajahi Item Menu
    M->>S: Dapatkan Item Tersedia
    S->>DB: Periksa Level Stok
    DB->>S: Data Ketersediaan
    S->>M: Tampilkan Item Tersedia

    C->>M: Pilih Item Menu
    M->>S: Tambah Item ke Keranjang
    S->>DB: Perbarui Keranjang
    DB->>S: Keranjang Diperbarui

    C->>M: Tambah Catatan Khusus
    M->>S: Simpan Catatan
    S->>DB: Simpan Catatan
    DB->>S: Catatan Tersimpan

    C->>M: Selesaikan Pesanan
    M->>S: Kirim Pesanan
    S->>P: Proses Pembayaran

    P->>S: Pembayaran Berhasil
    S->>DB: Buat Record Pesanan
    DB->>S: Pesanan Dibuat

    S->>K: Kirim Pesanan ke Dapur
    K->>S: Pesanan Diterima

    K->>S: Perbarui Status: Mempersiapkan
    S->>DB: Perbarui Status Pesanan
    DB->>S: Status Diperbarui

    K->>S: Perbarui Status: Siap
    S->>C: Notifikasi Pelanggan: Pesanan Siap

    C->>S: Konfirmasi Penerimaan Pesanan
    S->>DB: Perbarui Status: Terkirim
    DB->>S: Pesanan Selesai
```

## 4. Diagram Sequence Sistem Rating

```mermaid
sequenceDiagram
    participant U as Pengguna
    participant S as Sistem
    participant R as Modul Rating
    participant A as Analitik
    participant DB as Database

    U->>S: Selesaikan Layanan/Pesanan
    S->>U: Minta Rating

    U->>S: Akses Halaman Rating
    S->>R: Muat Interface Rating
    R->>U: Tampilkan Form Rating

    U->>R: Kirim Rating Keseluruhan
    U->>R: Rating Komponen Individual
    U->>R: Tambah Komentar
    R->>S: Kirim Data Rating

    S->>DB: Validasi Data Rating
    DB->>S: Hasil Validasi

    S->>DB: Simpan Rating
    DB->>S: Rating Tersimpan

    S->>A: Perbarui Analitik
    A->>DB: Hitung Rating Rata-rata
    DB->>A: Perhitungan Rating
    A->>DB: Perbarui Tabel Analitik

    S->>U: Kirim Pesan Terima Kasih
    S->>DB: Generate Ringkasan Rating
    DB->>S: Data Ringkasan
```

## 5. Diagram Sequence Proses Check-in

```mermaid
sequenceDiagram
    participant C as Pelanggan
    participant S as Staff
    participant SYS as Sistem
    participant DB as Database
    participant E as Peralatan

    C->>S: Berikan Referensi Booking
    S->>SYS: Masukkan/Scan Referensi
    SYS->>DB: Validasi Booking
    DB->>SYS: Data Booking

    SYS->>S: Tampilkan Detail Booking
    S->>C: Verifikasi Identitas

    S->>SYS: Proses Check-in
    SYS->>DB: Perbarui Status Booking
    DB->>SYS: Status Diperbarui

    SYS->>E: Minta Peralatan
    E->>S: Berikan Peralatan
    S->>DB: Catat Waktu Check-in
    DB->>SYS: Waktu Tercatat

    SYS->>C: Konfirmasi Check-in
    SYS->>C: Berikan Peralatan

    Note over C,SYS: Waktu Penggunaan Kolam

    C->>S: Minta Check-out
    S->>E: Kumpulkan Peralatan
    S->>SYS: Proses Check-out
    SYS->>DB: Catat Waktu Check-out
    DB->>SYS: Waktu Tercatat

    SYS->>DB: Generate Laporan Penggunaan
    DB->>SYS: Data Laporan
    SYS->>C: Konfirmasi Check-out
```

## 6. Diagram Sequence Sistem Pembayaran Manual

```mermaid
sequenceDiagram
    participant U as Pengguna
    participant S as Sistem
    participant A as Admin
    participant B as Sistem Bank
    participant DB as Database

    U->>S: Pilih Pembayaran Manual
    S->>U: Tampilkan Instruksi Pembayaran
    S->>B: Dapatkan Detail Rekening Bank
    B->>S: Informasi Rekening
    S->>U: Tampilkan Detail Transfer

    U->>B: Lakukan Transfer Bank
    B->>U: Konfirmasi Transfer
    U->>S: Upload Bukti Pembayaran
    S->>DB: Simpan Bukti Pembayaran
    DB->>S: Bukti Tersimpan

    S->>A: Notifikasi Admin: Pembayaran Diterima
    A->>S: Akses Verifikasi Pembayaran

    A->>S: Review Bukti Pembayaran
    S->>DB: Dapatkan Data Pembayaran
    DB->>S: Informasi Pembayaran

    A->>S: Verifikasi Detail Pembayaran
    S->>DB: Perbarui Status Pembayaran
    DB->>S: Status Diperbarui

    alt Pembayaran Terverifikasi
        S->>DB: Proses Booking/Pembelian
        DB->>S: Transaksi Selesai
        S->>U: Kirim Konfirmasi
    else Pembayaran Ditolak
        S->>U: Kirim Pemberitahuan Penolakan
        S->>DB: Tandai untuk Koreksi
        DB->>S: Koreksi Diperlukan
    end
```

## 7. Diagram Sequence Manajemen Menu Dinamis

```mermaid
sequenceDiagram
    participant A as Admin
    participant S as Sistem
    participant M as Menu Manager
    participant I as Inventori
    participant DB as Database

    A->>S: Akses Manajemen Menu
    S->>M: Muat Interface Menu
    M->>DB: Dapatkan Menu yang Ada
    DB->>M: Data Menu
    M->>A: Tampilkan Daftar Menu

    A->>M: Buat Item Menu Baru
    M->>A: Tampilkan Form Menu

    A->>M: Isi Detail Menu
    M->>S: Validasi Data Menu
    S->>M: Hasil Validasi

    A->>M: Set Informasi Harga
    M->>S: Hitung Margin
    S->>M: Perhitungan Margin

    A->>M: Upload Gambar Menu
    M->>S: Proses Gambar
    S->>DB: Simpan Gambar
    DB->>S: URL Gambar

    A->>M: Simpan Item Menu
    M->>DB: Buat Record Menu
    DB->>M: Menu Dibuat

    M->>I: Perbarui Sistem Inventori
    I->>DB: Buat Record Inventori
    DB->>I: Inventori Dibuat

    M->>S: Generate Analitik Menu
    S->>DB: Perbarui Analitik
    DB->>S: Analitik Diperbarui

    M->>A: Konfirmasi Menu Dibuat
```

## 8. Diagram Sequence Generate & Download Barcode

```mermaid
sequenceDiagram
    participant A as Admin
    participant S as Sistem
    participant B as Barcode Generator
    participant DB as Database
    participant F as File System

    A->>S: Akses Manajemen Barcode
    S->>DB: Dapatkan Item Menu
    DB->>S: Data Menu
    S->>A: Tampilkan Daftar Menu

    A->>S: Pilih Menu untuk Barcode
    S->>B: Generate Nilai Barcode
    B->>S: Nilai Barcode

    S->>B: Buat QR Code
    B->>S: Data QR Code

    S->>B: Generate Gambar Barcode
    B->>F: Simpan Gambar Barcode
    F->>B: URL Gambar

    S->>DB: Perbarui Menu dengan Barcode
    DB->>S: Menu Diperbarui

    S->>A: Tampilkan Preview Barcode

    A->>S: Download Barcode
    S->>F: Dapatkan File Barcode
    F->>S: Data File
    S->>A: Berikan Link Download

    A->>S: Permintaan Export Bulk
    S->>DB: Dapatkan Multiple Menu
    DB->>S: Daftar Menu

    S->>B: Generate Barcode Bulk
    B->>F: Buat Paket ZIP
    F->>S: URL Paket
    S->>A: Berikan Download Bulk
```

## 9. Diagram Sequence Sistem Pelaporan Komprehensif

```mermaid
sequenceDiagram
    participant A as Admin
    participant S as Sistem
    participant R as Report Generator
    participant DB as Database
    participant F as File Exporter

    A->>S: Akses Sistem Pelaporan
    S->>A: Tampilkan Kategori Laporan

    A->>S: Pilih Tipe Laporan
    S->>R: Inisiasi Generate Laporan
    R->>DB: Query Data Laporan

    alt Laporan Keuangan
        R->>DB: Dapatkan Data Keuangan
        DB->>R: Data Pendapatan, Pengeluaran, Laba
    else Laporan Operasional
        R->>DB: Dapatkan Data Operasional
        DB->>R: Data Booking, Sesi, Staff
    else Laporan Pelanggan
        R->>DB: Dapatkan Data Pelanggan
        DB->>R: Data Demografi, Perilaku
    end

    R->>S: Proses Data Laporan
    S->>R: Format Laporan

    A->>S: Permintaan Export
    S->>F: Export Laporan

    F->>S: Generate File Export
    S->>A: Berikan Link Download

    A->>S: Jadwalkan Laporan
    S->>DB: Simpan Jadwal
    DB->>S: Jadwal Tersimpan

    S->>A: Konfirmasi Aksi Laporan
```
