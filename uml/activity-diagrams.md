# Diagram Aktivitas - Sistem Kolam Renang Syariah

## 1. Diagram Aktivitas Registrasi Member

```mermaid
flowchart TD
    A[Mulai] --> B[Pengguna Akses Halaman Registrasi]
    B --> C[Isi Form Registrasi]
    C --> D[Upload Dokumen yang Diperlukan]
    D --> E[Pilih Paket]
    E --> F[Hitung Total Biaya]
    F --> G[Lanjut ke Pembayaran]
    G --> H[Lakukan Pembayaran]
    H --> I{Pembayaran Berhasil?}
    I -->|Ya| J[Generate Akun Sementara]
    I -->|Tidak| K[Tampilkan Error Pembayaran]
    K --> L[Coba Ulang Pembayaran]
    L --> I
    J --> M[Admin Review Dokumen]
    M --> N{Dokumen Valid?}
    N -->|Ya| O[Aktifkan Akun Member]
    N -->|Tidak| P[Minta Koreksi Dokumen]
    P --> Q[Pengguna Upload Dokumen yang Diperbaiki]
    Q --> M
    O --> R[Generate Kartu Member]
    R --> S[Kirim Email/SMS Selamat Datang]
    S --> T[Selesai]
```

## 2. Diagram Aktivitas Proses Booking

```mermaid
flowchart TD
    A[Mulai] --> B[Pengguna Akses Halaman Booking]
    B --> C[Lihat Interface Kalender]
    C --> D{Navigasi ke Bulan Depan?}
    D -->|Ya| E[Maju Kalender]
    D -->|Tidak| F[Pilih Tanggal Tersedia]
    E --> F
    F --> G[Lihat Detail Sesi]
    G --> H{Sesi Tersedia?}
    H -->|Ya| I[Pilih Sesi]
    H -->|Tidak| J[Tampilkan Sesi Alternatif]
    J --> I
    I --> K[Pilih Tipe Pengguna]
    K --> L{Member atau Tamu?}
    L -->|Member| M[Login ke Akun]
    L -->|Tamu| N[Isi Form Tamu]
    M --> O[Muat Profil Member]
    N --> O
    O --> P[Hitung Total Biaya]
    P --> Q[Review Detail Booking]
    Q --> R{Detail Benar?}
    R -->|Ya| S[Lanjut ke Pembayaran]
    R -->|Tidak| T[Edit Detail Booking]
    T --> P
    S --> U[Pilih Metode Pembayaran]
    U --> V{Tipe Pembayaran?}
    V -->|Transfer Manual| W[Tampilkan Instruksi Transfer]
    V -->|Lainnya| X[Proses Pembayaran Online]
    W --> Y[Upload Bukti Pembayaran]
    X --> Z{Pembayaran Berhasil?}
    Z -->|Ya| AA[Generate Konfirmasi Booking]
    Z -->|Tidak| BB[Tampilkan Error Pembayaran]
    BB --> S
    Y --> CC[Admin Verifikasi Pembayaran]
    CC --> DD{Pembayaran Terverifikasi?}
    DD -->|Ya| AA
    DD -->|Tidak| EE[Minta Koreksi Pembayaran]
    EE --> Y
    AA --> FF[Kirim Email/SMS Konfirmasi]
    FF --> GG[Generate QR Code]
    GG --> HH[Selesai]
```

## 3. Diagram Aktivitas Proses Pesanan Kafe

```mermaid
flowchart TD
    A[Mulai] --> B[Pengguna Scan Barcode/QR Code]
    B --> C[Sistem Muat Menu Berdasarkan Lokasi]
    C --> D[Tampilkan Item Menu Tersedia]
    D --> E[Pengguna Jelajahi Menu]
    E --> F[Pilih Item Menu]
    F --> G{Item Tersedia?}
    G -->|Ya| H[Tambah ke Keranjang]
    G -->|Tidak| I[Tampilkan Pesan Stok Habis]
    I --> E
    H --> J[Tambah Catatan Khusus/Permintaan]
    J --> K[Perbarui Total Keranjang]
    K --> L{Tambah Item Lagi?}
    L -->|Ya| E
    L -->|Tidak| M[Review Keranjang]
    M --> N{Keranjang Benar?}
    N -->|Ya| O[Lanjut ke Pembayaran]
    N -->|Tidak| P[Edit Keranjang]
    P --> E
    O --> Q[Pilih Metode Pembayaran]
    Q --> R{Tipe Pembayaran?}
    R -->|Transfer Manual| S[Tampilkan Instruksi Transfer]
    R -->|Pembayaran Online| T[Proses Pembayaran Online]
    S --> U[Upload Bukti Pembayaran]
    T --> V{Pembayaran Berhasil?}
    V -->|Ya| W[Generate Konfirmasi Pesanan]
    V -->|Tidak| X[Tampilkan Error Pembayaran]
    X --> O
    U --> Y[Admin Verifikasi Pembayaran]
    Y --> Z{Pembayaran Valid?}
    Z -->|Ya| W
    Z -->|Tidak| AA[Minta Koreksi Pembayaran]
    BB --> GG[Kirim Pesanan ke Dapur]
    FF --> GG
    GG --> HH[Perbarui Status Pesanan: Mempersiapkan]
    HH --> II[Dapur Siapkan Makanan]
    II --> JJ[Perbarui Status Pesanan: Siap]
    JJ --> KK[Staff Antar Pesanan]
    KK --> LL[Pelanggan Konfirmasi Penerimaan]
    LL --> MM[Perbarui Status Pesanan: Terkirim]
    MM --> NN[Selesai]
```

## 4. Diagram Aktivitas Sistem Rating

```mermaid
flowchart TD
    A[Mulai] --> B[Pengguna Selesaikan Layanan/Pesanan]
    B --> C[Sistem Minta Rating]
    C --> D[Pengguna Akses Halaman Rating]
    D --> E[Pilih Rating Keseluruhan 1-5 Bintang]
    E --> F[Rating Komponen Individual]
    F --> G[Rating Pengalaman Booking]
    G --> H[Rating Layanan Staff]
    H --> I[Rating Kualitas Fasilitas]
    I --> J[Rating Layanan Kafe]
    J --> K[Tambah Komentar Tertulis]
    K --> L[Kirim Rating]
    L --> M[Sistem Validasi Rating]
    M --> N{Rating Valid?}
    N -->|Ya| O[Simpan Rating ke Database]
    N -->|Tidak| P[Tampilkan Error Validasi]
    P --> E
    O --> Q[Perbarui Analitik Rating]
    Q --> R[Hitung Rating Rata-rata]
    R --> S[Perbarui Metrik Performa Staff]
    S --> T[Generate Ringkasan Rating]
    T --> U[Kirim Pesan Terima Kasih]
    U --> V[Selesai]
```

## 5. Diagram Aktivitas Proses Check-in

```mermaid
flowchart TD
    A[Mulai] --> B[Pelanggan Datang ke Kolam]
    B --> C[Berikan Referensi Booking/QR Code]
    C --> D[Staff Scan/Masukkan Referensi]
    D --> E[Sistem Validasi Booking]
    E --> F{Booking Valid?}
    F -->|Tidak| G[Tampilkan Error Booking Tidak Valid]
    G --> H[Resolusi Pelanggan]
    H --> C
    F -->|Ya| I[Periksa Status Booking]
    I --> J{Sudah Check-in?}
    J -->|Ya| K[Tampilkan Pesan Sudah Check-in]
    J -->|Tidak| L[Verifikasi Identitas Pelanggan]
    L --> M{Identitas Cocok?}
    M -->|Tidak| N[Minta Verifikasi ID]
    N --> L
    M -->|Ya| O[Proses Check-in]
    O --> P[Perbarui Status Booking]
    P --> Q[Berikan Peralatan Kolam]
    Q --> R[Catat Waktu Check-in]
    R --> S[Kirim Konfirmasi Check-in]
    S --> T[Pelanggan Akses Kolam]
    T --> U[Monitor Penggunaan Kolam]
    U --> V[Pelanggan Minta Check-out]
    V --> W[Kumpulkan Peralatan Kolam]
    W --> X[Catat Waktu Check-out]
    X --> Y[Perbarui Catatan Kehadiran]
    Y --> Z[Generate Laporan Penggunaan]
    Z --> AA[Selesai]
```

## 6. Diagram Aktivitas Harga Promosi

```mermaid
flowchart TD
    A[Mulai] --> B[Admin Akses Manajemen Promosi]
    B --> C[Buat Kampanye Baru]
    C --> D[Set Detail Kampanye]
    D --> E[Nama & Deskripsi Kampanye]
    E --> F[Pilih Tipe Kampanye]
    F --> G{Tipe Diskon?}
    G -->|Persentase| H[Set Persentase Diskon]
    G -->|Jumlah Tetap| I[Set Jumlah Diskon]
    G -->|Beli Satu Dapat Satu| J[Konfigurasi Aturan BOGO]
    H --> K[Set Durasi Kampanye]
    I --> K
    J --> K
    K --> L[Konfigurasi Aturan Targeting]
    L --> M[Pilih Layanan Target]
    M --> N[Set Kelayakan Pengguna]
    N --> O[Konfigurasi Pembatasan Waktu]
    O --> P[Aktifkan Kampanye]
    P --> Q[Sistem Terapkan Aturan]
    Q --> R[Monitor Performa Kampanye]
    R --> S[Pengguna Akses Booking/Kafe]
    S --> T[Sistem Periksa Kelayakan]
    T --> U{Layak untuk Promosi?}
    U -->|Ya| V[Terapkan Harga Promosi]
    U -->|Tidak| W[Tampilkan Harga Reguler]
    V --> X[Tampilkan Penawaran Promosi]
    X --> Y[Pengguna Terima Penawaran]
    Y --> Z[Terapkan Diskon]
    Z --> AA[Selesaikan Transaksi]
    AA --> BB[Perbarui Penggunaan Kampanye]
    BB --> CC[Generate Laporan Promosi]
    CC --> DD[Selesai]
```

## 7. Diagram Aktivitas Pembayaran Manual

```mermaid
flowchart TD
    A[Mulai] --> B[Pengguna Pilih Pembayaran Manual]
    B --> C[Sistem Tampilkan Instruksi Pembayaran]
    C --> D[Tampilkan Detail Rekening Bank]
    D --> E[Generate Referensi Pembayaran]
    E --> F[Pengguna Lakukan Transfer Bank]
    F --> G[Pengguna Upload Bukti Pembayaran]
    G --> H[Sistem Terima Bukti Pembayaran]
    H --> I[Notifikasi Admin: Pembayaran Diterima]
    I --> J[Admin Akses Verifikasi Pembayaran]
    J --> K[Admin Review Bukti Pembayaran]
    K --> L{Bukti Valid?}
    L -->|Tidak| M[Admin Tolak Pembayaran]
    L -->|Ya| N[Admin Verifikasi Jumlah]
    M --> O[Kirim Notifikasi Penolakan]
    O --> P[Pengguna Upload Bukti yang Diperbaiki]
    P --> K
    N --> Q{Jumlah Benar?}
    Q -->|Tidak| R[Admin Minta Koreksi]
    Q -->|Ya| S[Admin Konfirmasi Pembayaran]
    R --> T[Kirim Permintaan Koreksi]
    T --> P
    S --> U[Perbarui Status Pembayaran: Terverifikasi]
    U --> V[Proses Booking/Pembelian]
    V --> W[Kirim Pesan Konfirmasi]
    W --> X[Generate Receipt]
    X --> Y[Selesai]
```

## 8. Diagram Aktivitas Kuota Member Dinamis

```mermaid
flowchart TD
    A[Mulai] --> B[Admin Konfigurasi Kuota Member]
    B --> C[Set Batas Maksimal Member]
    C --> D[Konfigurasi Periode Peringatan]
    D --> E[Set Grace Period]
    E --> F[Aktifkan Sistem Kuota]
    F --> G[Pengguna Minta Keanggotaan]
    G --> H{Member Saat Ini < Batas Maks?}
    H -->|Ya| I[Proses Registrasi Keanggotaan]
    H -->|Tidak| J[Tambah Pengguna ke Antrian]
    I --> K[Perbarui Jumlah Member]
    K --> L[Selesai]
    J --> M[Assign Posisi Antrian]
    M --> N[Kirim Konfirmasi Antrian]
    N --> O[Monitor Kedaluwarsa Member]
    O --> P{Member Mendekati Kedaluwarsa?}
    P -->|Ya| Q[Kirim Notifikasi Peringatan]
    Q --> R{Member Perpanjang?}
    R -->|Ya| S[Proses Perpanjangan]
    R -->|Tidak| T[Tunggu Grace Period]
    S --> U[Perbarui Status Member]
    U --> V[Selesai]
    T --> W{Grace Period Berakhir?}
    W -->|Ya| X[Deaktifkan Keanggotaan]
    W -->|Tidak| T
    X --> Y{Antrian Ada Pengguna Menunggu?}
    Y -->|Ya| Z[Promote Pertama di Antrian]
    Y -->|Tidak| AA[Perbarui Statistik Kuota]
    Z --> BB[Kirim Penawaran Promosi]
    BB --> CC{Pengguna Terima?}
    CC -->|Ya| DD[Proses Keanggotaan]
    CC -->|Tidak| EE[Hapus dari Antrian]
    DD --> FF[Perbarui Jumlah Member]
    EE --> GG[Perbarui Posisi Antrian]
    FF --> HH[Selesai]
    GG --> AA
```

## 9. Diagram Aktivitas Batas Harian Berenang Member

```mermaid
flowchart TD
    A[Mulai] --> B[Member Akses Booking]
    B --> C[Pilih Tanggal Sesi]
    C --> D[Sistem Periksa Batas Harian]
    D --> E{Sudah Pakai Sesi Gratis Hari Ini?}
    E -->|Tidak| F[Booking Sesi Gratis]
    E -->|Ya| G[Periksa Batas Sesi Tambahan]
    F --> H[Konfirmasi Booking]
    H --> I[Perbarui Penggunaan Harian]
    I --> J[Selesai]
    G --> K{Ingin Sesi Tambahan?}
    K -->|Tidak| L[Tampilkan Pesan Batas]
    K -->|Ya| M[Hitung Biaya Tambahan]
    L --> N[Selesai]
    M --> O[Tampilkan Informasi Biaya]
    O --> P{Member Terima Biaya?}
    P -->|Ya| Q[Proses Booking Tambahan]
    P -->|Tidak| R[Batal Booking]
    Q --> S[Charge Tarif Normal]
    S --> T[Perbarui Penggunaan Harian]
    T --> U[Tambah ke Catatan Pembayaran]
    U --> V[Selesai]
    R --> W[Selesai]
```

## 10. Diagram Aktivitas Sewa Kolam Privat

```mermaid
flowchart TD
    A[Mulai] --> B[Pelanggan Akses Booking Kolam Privat]
    B --> C[Pilih Tanggal & Waktu Sewa]
    C --> D[Sistem Periksa Riwayat Pelanggan]
    D --> E{Pelanggan Baru?}
    E -->|Ya| F[Terapkan Bonus Pelanggan Baru]
    E -->|Tidak| G[Hitung Tarif Pelanggan Kembali]
    F --> H[Standar 1j 30m + 30m Bonus]
    G --> I[Standar 1j 30m + Biaya Tambahan]
    H --> J[Hitung Total Harga]
    I --> J
    J --> K[Tampilkan Rincian Harga]
    K --> L{Pelanggan Terima Harga?}
    L -->|Ya| M[Proses Pembayaran]
    L -->|Tidak| N[Batal Booking]
    M --> O{Pembayaran Berhasil?}
    O -->|Ya| P[Konfirmasi Booking]
    O -->|Tidak| Q[Tampilkan Error Pembayaran]
    P --> R[Perbarui Riwayat Kunjungan Pelanggan]
    R --> S[Kirim Konfirmasi Booking]
    S --> T[Hari Sewa Tiba]
    T --> U[Pelanggan Check-in]
    U --> V[Mulai Timer Sewa]
    V --> W[Monitor Waktu Penggunaan]
    W --> X{Waktu Hampir Habis?}
    X -->|Ya| Y[Kirim Peringatan Waktu]
    X -->|Tidak| Z{Waktu Habis?}
    Y --> Z
    Z -->|Ya| AA[Akhiri Sesi Sewa]
    Z -->|Tidak| W
    AA --> BB[Pelanggan Check-out]
    BB --> CC[Hitung Penggunaan Aktual]
    CC --> DD[Generate Laporan Penggunaan]
    DD --> EE[Perbarui Riwayat Pelanggan]
    EE --> FF[Selesai]
    Q --> GG[Coba Ulang Pembayaran]
    GG --> M
    N --> HH[Selesai]
```

## 11. Diagram Aktivitas Sistem Kafe dengan Barcode

```mermaid
flowchart TD
    A[Mulai] --> B[Pelanggan Datang ke Area Kolam]
    B --> C[Lokasi Barcode/QR Code Menu]
    C --> D[Scan Barcode dengan Perangkat Mobile]
    D --> E[Sistem Identifikasi Lokasi]
    E --> F[Muat Menu Spesifik Lokasi]
    F --> G[Tampilkan Item Menu Tersedia]
    G --> H[Pelanggan Jelajahi Menu]
    H --> I{Item Menu Tersedia?}
    I -->|Ya| J[Pilih Item Menu]
    I -->|Tidak| K[Tampilkan Item Stok Habis]
    J --> L[Tambah Item ke Keranjang]
    K --> H
    L --> M[Set Jumlah]
    M --> N[Tambah Catatan Khusus/Permintaan]
    N --> O[Perbarui Total Keranjang]
    O --> P{Tambah Item Lagi?}
    P -->|Ya| H
    P -->|Tidak| Q[Review Keranjang]
    Q --> R{Keranjang Benar?}
    R -->|Ya| S[Lanjut ke Checkout]
    R -->|Tidak| T[Edit Item Keranjang]
    S --> U[Tampilkan Ringkasan Pesanan]
    T --> H
    U --> V[Pilih Metode Pembayaran]
    V --> W{Tipe Pembayaran?}
    W -->|Transfer Manual| X[Tampilkan Instruksi Transfer]
    W -->|Pembayaran Online| Y[Proses Pembayaran Online]
    X --> Z[Pelanggan Upload Bukti]
    Y --> AA{Pembayaran Berhasil?}
    AA -->|Ya| BB[Generate Konfirmasi Pesanan]
    AA -->|Tidak| CC[Tampilkan Error Pembayaran]
    CC --> V
    Z --> DD[Admin Verifikasi Pembayaran]
    DD --> EE{Pembayaran Valid?}
    EE -->|Ya| BB
    EE -->|Tidak| FF[Minta Koreksi Pembayaran]
    BB --> GG[Kirim Pesanan ke Dapur]
    FF --> Z
    GG --> HH[Perbarui Status Pesanan: Mempersiapkan]
    HH --> II[Dapur Siapkan Makanan]
    II --> JJ[Perbarui Status Pesanan: Siap]
    JJ --> KK[Staff Antar Pesanan]
    KK --> LL[Pelanggan Konfirmasi Penerimaan]
    LL --> MM[Perbarui Status Pesanan: Terkirim]
    MM --> NN[Selesai]
```

## 12. Diagram Aktivitas Manajemen Menu Dinamis

```mermaid
flowchart TD
    A[Mulai] --> B[Admin Akses Manajemen Menu]
    B --> C[Pilih Aksi Menu]
    C --> D{Tipe Aksi?}
    D -->|Buat| E[Buat Item Menu Baru]
    D -->|Perbarui| F[Pilih Menu yang Ada]
    D -->|Hapus| G[Pilih Menu untuk Dihapus]
    E --> H[Isi Detail Menu]
    H --> I[Nama & Deskripsi Menu]
    I --> J[Upload Gambar Menu]
    J --> K[Set Biaya Dasar]
    K --> L[Set Harga Jual]
    L --> M[Hitung Margin]
    M --> N[Pilih Kategori Menu]
    N --> O[Set Informasi Diet]
    O --> P[Tambah Instruksi Memasak]
    P --> Q[Set Informasi Stok]
    Q --> R[Konfigurasi Status Menu]
    R --> S[Simpan Item Menu]
    F --> T[Muat Detail Menu]
    T --> U[Perbarui Informasi Menu]
    U --> H
    G --> V[Konfirmasi Penghapusan]
    V --> W{Konfirmasi Penghapusan?}
    W -->|Ya| X[Hapus Item Menu]
    W -->|Tidak| Y[Batal Penghapusan]
    S --> Z[Perbarui Sistem Inventori]
    X --> AA[Hapus dari Inventori]
    Y --> B
    Z --> BB[Generate Analitik Menu]
    AA --> CC[Perbarui Pesanan Terkait]
    BB --> DD[Selesai]
    CC --> DD
```

## 13. Diagram Aktivitas Generate & Download Barcode

```mermaid
flowchart TD
    A[Mulai] --> B[Admin Akses Manajemen Barcode]
    B --> C[Pilih Item Menu]
    C --> D[Pilih Aksi Barcode]
    D --> E{Tipe Aksi?}
    E -->|Generate| F[Generate Barcode Baru]
    E -->|Download| G[Download Barcode yang Ada]
    E -->|Regenerate| H[Regenerate Barcode]
    F --> I[Sistem Generate Nilai Barcode]
    I --> J[Buat QR Code]
    J --> K[Generate Gambar Barcode]
    K --> L[Simpan Data Barcode]
    L --> M[Perbarui Record Menu]
    M --> N[Tampilkan Preview Barcode]
    G --> O[Muat Informasi Barcode]
    O --> P[Pilih Format Download]
    P --> Q{Tipe Format?}
    Q -->|PNG| R[Generate Barcode PNG]
    Q -->|PDF| S[Generate Barcode PDF]
    Q -->|Export Bulk| T[Pilih Multiple Menu]
    R --> U[Download File PNG]
    S --> V[Download File PDF]
    T --> W[Generate Paket Barcode Bulk]
    V --> X[Selesai]
    U --> X
    W --> Y[Download Paket ZIP]
    Y --> X
    H --> Z[Regenerate Nilai Barcode]
    Z --> I
    N --> AA[Barcode Siap Digunakan]
    AA --> X
```

## 14. Diagram Aktivitas Pelaporan Komprehensif

```mermaid
flowchart TD
    A[Mulai] --> B[Admin Akses Sistem Pelaporan]
    B --> C[Pilih Kategori Laporan]
    C --> D{Kategori Laporan?}
    D -->|Keuangan| E[Laporan Keuangan]
    D -->|Operasional| F[Laporan Operasional]
    D -->|Pelanggan| G[Analitik Pelanggan]
    D -->|Inventori| H[Laporan Inventori]
    E --> I[Pilih Tipe Laporan Keuangan]
    I --> J{Tipe Laporan Keuangan?}
    J -->|Pendapatan| K[Generate Laporan Pendapatan]
    J -->|Pengeluaran| L[Generate Laporan Pengeluaran]
    J -->|Laba Rugi| M[Generate Laporan P&L]
    J -->|Arus Kas| N[Generate Laporan Arus Kas]
    J -->|Pajak| O[Generate Laporan Pajak]
    F --> P[Pilih Tipe Laporan Operasional]
    P --> Q{Tipe Laporan Operasional?}
    Q -->|Booking| R[Generate Analitik Booking]
    Q -->|Sesi| S[Generate Laporan Sesi]
    Q -->|Staff| T[Generate Laporan Staff]
    Q -->|Fasilitas| U[Generate Laporan Fasilitas]
    G --> V[Pilih Tipe Laporan Pelanggan]
    V --> W{Tipe Laporan Pelanggan?}
    W -->|Demografi| X[Generate Laporan Demografi]
    W -->|Perilaku| Y[Generate Analisis Perilaku]
    W -->|Kepuasan| Z[Generate Laporan Kepuasan]
    H --> AA[Pilih Tipe Laporan Inventori]
    AA --> BB{Tipe Laporan Inventori?}
    BB -->|Level Stok| CC[Generate Laporan Level Stok]
    BB -->|Pergerakan| DD[Generate Laporan Pergerakan Stok]
    BB -->|Prediksi| EE[Generate Laporan Prediksi Stok]
    K --> FF[Konfigurasi Parameter Laporan]
    L --> FF
    M --> FF
    N --> FF
    O --> FF
    R --> FF
    S --> FF
    T --> FF
    U --> FF
    X --> FF
    Y --> FF
    Z --> FF
    CC --> FF
    DD --> FF
    EE --> FF
    FF --> GG[Set Rentang Tanggal]
    GG --> HH[Pilih Format Export]
    HH --> II{Format Export?}
    II -->|PDF| JJ[Generate Laporan PDF]
    II -->|Excel| KK[Generate Laporan Excel]
    II -->|CSV| LL[Generate Laporan CSV]
    JJ --> MM[Download Laporan]
    KK --> MM
    LL --> MM
    MM --> NN[Simpan Riwayat Laporan]
    NN --> OO[Jadwalkan Laporan Masa Depan]
    OO --> PP[Selesai]
```
