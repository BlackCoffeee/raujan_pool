# Diagram Use Case - Sistem Kolam Renang Syariah

## 1. Diagram Use Case - Admin

```mermaid
graph TB
    subgraph "Use Case Admin"
        A1[Admin]

        subgraph "Manajemen Sistem"
            UC1[Daftar Member]
            UC2[Perbarui Profil]
            UC3[Kelola Paket]
            UC4[Lihat Riwayat]
            UC5[Perpanjang Keanggotaan]
            UC6[Kelola Konfigurasi Sistem]
            UC7[Kelola Peran Pengguna]
            UC8[Kelola Izin]
            UC9[Backup Sistem]
            UC10[Restore Sistem]
            UC11[Lihat Log Sistem]
            UC12[Kelola API Keys]
            UC13[Konfigurasi Integrasi]
            UC14[Monitoring Sistem]
            UC15[Optimasi Performa]
        end

        subgraph "Sistem Harga Dinamis"
            UC16[Konfigurasi Harga Dinamis]
            UC17[Perbarui Konfigurasi Harga]
            UC18[Lihat Riwayat Harga]
            UC19[Kelola Aturan Harga]
            UC20[Set Harga Musiman]
            UC21[Konfigurasi Diskon Member]
        end

        subgraph "Sistem Promosi"
            UC22[Buat Kampanye Promosi]
            UC23[Kelola Template Kampanye]
            UC24[Lihat Analitik Kampanye]
            UC25[Konfigurasi Harga Dinamis]
            UC26[Terapkan Harga Promosi]
        end

        subgraph "Manajemen Pengguna Tamu"
            UC27[Daftar sebagai Tamu]
            UC28[Konversi Tamu ke Member]
            UC29[Kelola Pengguna Tamu]
            UC30[Analitik Pengguna Tamu]
            UC31[Pelacakan Konversi Tamu]
        end

        subgraph "Integrasi Google SSO"
            UC32[Login via Google SSO]
            UC33[Daftar via Google SSO]
            UC34[Sinkronisasi Profil Google]
            UC35[Konfigurasi Pengaturan SSO]
            UC36[Kelola Sesi SSO]
        end

        subgraph "Sistem Notifikasi"
            UC37[Kirim Push Notifikasi]
            UC38[Konfigurasi Notifikasi]
            UC39[Kelola Template Notifikasi]
            UC40[Jadwalkan Notifikasi]
            UC41[Lacak Pengiriman Notifikasi]
        end

        subgraph "Sistem Pembayaran Manual"
            UC42[Verifikasi Bukti Pembayaran]
            UC43[Konfirmasi Pembayaran]
            UC44[Tolak Pembayaran]
            UC45[Minta Koreksi Pembayaran]
            UC46[Generate Instruksi Pembayaran]
            UC47[Lacak Riwayat Pembayaran]
        end

        subgraph "Manajemen Kuota Member Dinamis"
            UC48[Konfigurasi Kuota Member]
            UC49[Monitor Posisi Antrian]
            UC50[Proses Kedaluwarsa Member]
            UC51[Kirim Peringatan Kedaluwarsa]
            UC52[Auto-Promote Antrian]
            UC53[Konfirmasi Penawaran Promosi]
            UC54[Perbarui Pengaturan Kuota]
            UC55[Lacak Riwayat Kuota]
            UC56[Lihat Dashboard Kuota]
        end

        subgraph "Manajemen Sistem Kafe"
            UC57[Buat Menu]
            UC58[Perbarui Menu]
            UC59[Kelola Stok]
            UC60[Lihat Analitik Menu]
            UC61[Generate Barcode Menu]
            UC62[Download Barcode]
            UC63[Generate Laporan Keuangan]
            UC64[Lihat Dashboard Analitik]
        end

        subgraph "Sistem Pelaporan Komprehensif"
            UC65[Generate Laporan Pendapatan]
            UC66[Generate Laporan Pengeluaran]
            UC67[Generate Laporan Laba Rugi]
            UC68[Generate Laporan Arus Kas]
            UC69[Generate Laporan Pajak]
            UC70[Generate Analisis Budget]
            UC71[Generate Analitik Booking]
            UC72[Generate Laporan Member]
            UC73[Generate Laporan Sesi]
            UC74[Generate Laporan Staff]
            UC75[Generate Laporan Fasilitas]
            UC76[Generate Analitik Pelanggan]
            UC77[Generate Laporan Inventori]
            UC78[Generate Laporan Promosi]
            UC79[Export Laporan]
            UC80[Jadwalkan Laporan]
            UC81[Konfigurasi Template Laporan]
            UC82[Lihat Dashboard Real-time]
        end

        subgraph "Manajemen Data"
            UC83[Import Data]
            UC84[Export Data]
            UC85[Validasi Data]
            UC86[Pembersihan Data]
            UC87[Migrasi Data]
            UC88[Arsip Data]
            UC89[Pemulihan Data]
            UC90[Backup Data]
            UC91[Kelola Retensi Data]
            UC92[Kepatuhan Data]
        end
    end

    linkStyle 0 stroke:#ff6b6b,stroke-width:2px
    A1 -.-> UC1
    A1 -.-> UC2
    A1 -.-> UC3
    A1 -.-> UC4
    A1 -.-> UC5
    A1 -.-> UC6
    A1 -.-> UC7
    A1 -.-> UC8
    A1 -.-> UC9
    A1 -.-> UC10
    A1 -.-> UC11
    A1 -.-> UC12
    A1 -.-> UC13
    A1 -.-> UC14
    A1 -.-> UC15
    A1 -.-> UC16
    A1 -.-> UC17
    A1 -.-> UC18
    A1 -.-> UC19
    A1 -.-> UC20
    A1 -.-> UC21
    A1 -.-> UC22
    A1 -.-> UC23
    A1 -.-> UC24
    A1 -.-> UC25
    A1 -.> UC26
    A1 -.> UC27
    A1 -.> UC28
    A1 -.> UC29
    A1 -.> UC30
    A1 -.> UC31
    A1 -.> UC32
    A1 -.> UC33
    A1 -.> UC34
    A1 -.> UC35
    A1 -.> UC36
    A1 -.> UC37
    A1 -.> UC38
    A1 -.> UC39
    A1 -.> UC40
    A1 -.> UC41
    A1 -.> UC42
    A1 -.> UC43
    A1 -.> UC44
    A1 -.> UC45
    A1 -.> UC46
    A1 -.> UC47
    A1 -.> UC48
    A1 -.> UC49
    A1 -.> UC50
    A1 -.> UC51
    A1 -.> UC52
    A1 -.> UC53
    A1 -.> UC54
    A1 -.> UC55
    A1 -.> UC56
    A1 -.> UC57
    A1 -.> UC58
    A1 -.> UC59
    A1 -.> UC60
    A1 -.> UC61
    A1 -.> UC62
    A1 -.> UC63
    A1 -.> UC64
    A1 -.> UC65
    A1 -.> UC66
    A1 -.> UC67
    A1 -.> UC68
    A1 -.> UC69
    A1 -.> UC70
    A1 -.> UC71
    A1 -.> UC72
    A1 -.> UC73
    A1 -.> UC74
    A1 -.> UC75
    A1 -.> UC76
    A1 -.> UC77
    A1 -.> UC78
    A1 -.> UC79
    A1 -.> UC80
    A1 -.> UC81
    A1 -.> UC82
    A1 -.> UC83
    A1 -.> UC84
    A1 -.> UC85
    A1 -.> UC86
    A1 -.> UC87
    A1 -.> UC88
    A1 -.> UC89
    A1 -.> UC90
    A1 -.> UC91
    A1 -.> UC92
```

## 2. Diagram Use Case - Staff Front Desk

```mermaid
graph TB
    subgraph "Use Case Staff Front Desk"
        A2[Staff Front Desk]

        subgraph "Manajemen Booking"
            UC1[Proses Check-in]
            UC2[Proses Check-out]
            UC3[Tangani No-Show]
            UC4[Lihat Jadwal]
            UC5[Periksa Ketersediaan Real-time]
            UC6[Generate Laporan]
        end

        subgraph "Manajemen Member"
            UC7[Daftar Member]
            UC8[Perbarui Profil Member]
            UC9[Kelola Paket Member]
            UC10[Proses Perpanjangan Keanggotaan]
        end

        subgraph "Proses Pembayaran"
            UC11[Proses Pembayaran Sesi Reguler]
            UC12[Proses Pembayaran Sesi Privat]
            UC13[Proses Refund]
            UC14[Verifikasi Pembayaran Manual]
            UC15[Konfirmasi Pembayaran]
            UC16[Tolak Pembayaran]
            UC17[Lihat Status Pembayaran]
        end

        subgraph "Manajemen Peralatan"
            UC18[Kelola Peralatan]
            UC19[Lacak Kehadiran]
            UC20[Berikan Peralatan]
            UC21[Kumpulkan Peralatan]
            UC22[Log Perawatan Peralatan]
        end

        subgraph "Layanan Tamu"
            UC23[Daftar Pengguna Tamu]
            UC24[Konversi Tamu ke Member]
            UC25[Bantu dengan Booking]
            UC26[Berikan Dukungan Pelanggan]
        end

        subgraph "Operasi Harian"
            UC27[Monitor Kapasitas Harian]
            UC28[Kelola Slot Sesi]
            UC29[Tangani Keluhan Pelanggan]
            UC30[Proses Pembatalan]
        end
    end

    linkStyle 0 stroke:#4ecdc4,stroke-width:2px
    A2 -.-> UC1
    A2 -.-> UC2
    A2 -.-> UC3
    A2 -.-> UC4
    A2 -.-> UC5
    A2 -.-> UC6
    A2 -.-> UC7
    A2 -.-> UC8
    A2 -.-> UC9
    A2 -.-> UC10
    A2 -.-> UC11
    A2 -.-> UC12
    A2 -.-> UC13
    A2 -.-> UC14
    A2 -.-> UC15
    A2 -.-> UC16
    A2 -.-> UC17
    A2 -.> UC18
    A2 -.> UC19
    A2 -.> UC20
    A2 -.> UC21
    A2 -.> UC22
    A2 -.> UC23
    A2 -.> UC24
    A2 -.> UC25
    A2 -.> UC26
    A2 -.> UC27
    A2 -.> UC28
    A2 -.> UC29
    A2 -.> UC30
```

## 3. Diagram Use Case - Staff Kafe

```mermaid
graph TB
    subgraph "Use Case Staff Kafe"
        A3[Staff Kafe]

        subgraph "Manajemen Menu"
            UC1[Buat Item Menu]
            UC2[Perbarui Item Menu]
            UC3[Kelola Stok]
            UC4[Perbarui Level Stok]
            UC5[Generate Barcode Menu]
            UC6[Download Barcode]
        end

        subgraph "Proses Pesanan"
            UC7[Terima Pesanan]
            UC8[Siapkan Makanan]
            UC9[Perbarui Status Pesanan]
            UC10[Antar Pesanan]
            UC11[Konfirmasi Penerimaan Pesanan]
            UC12[Tangani Permintaan Khusus]
        end

        subgraph "Manajemen Inventori"
            UC13[Lacak Penjualan]
            UC14[Kelola Inventori]
            UC15[Periksa Level Stok]
            UC16[Pesan Stok]
            UC17[Perbarui Catatan Stok]
        end

        subgraph "Layanan Pelanggan"
            UC18[Bantu Pemilihan Menu]
            UC19[Proses Pembayaran]
            UC20[Tangani Keluhan Pelanggan]
            UC21[Berikan Rekomendasi Menu]
        end

        subgraph "Pelaporan"
            UC22[Generate Laporan Penjualan]
            UC23[Lihat Analitik Menu]
            UC24[Lacak Preferensi Pelanggan]
            UC25[Monitor Metrik Performa]
        end
    end

    linkStyle 0 stroke:#45b7d1,stroke-width:2px
    A3 -.-> UC1
    A3 -.-> UC2
    A3 -.-> UC3
    A3 -.-> UC4
    A3 -.-> UC5
    A3 -.-> UC6
    A3 -.-> UC7
    A3 -.-> UC8
    A3 -.-> UC9
    A3 -.-> UC10
    A3 -.-> UC11
    A3 -.> UC12
    A3 -.> UC13
    A3 -.> UC14
    A3 -.> UC15
    A3 -.> UC16
    A3 -.> UC17
    A3 -.> UC18
    A3 -.> UC19
    A3 -.> UC20
    A3 -.> UC21
    A3 -.> UC22
    A3 -.> UC23
    A3 -.> UC24
    A3 -.> UC25
```

## 4. Diagram Use Case - Member

```mermaid
graph TB
    subgraph "Use Case Member"
        A4[Member]

        subgraph "Manajemen Profil"
            UC1[Perbarui Profil]
            UC2[Lihat Detail Keanggotaan]
            UC3[Lihat Riwayat Booking]
            UC4[Perpanjang Keanggotaan]
            UC5[Bayar Biaya Keanggotaan]
        end

        subgraph "Sistem Booking"
            UC6[Akses Interface Kalender]
            UC7[Navigasi Kalender ke Depan]
            UC8[Pilih Tanggal Tersedia]
            UC9[Lihat Detail Sesi]
            UC10[Pilih Sesi]
            UC11[Selesaikan Booking]
            UC12[Terima Konfirmasi]
            UC13[Batal Booking]
            UC14[Check-in/Check-out]
            UC15[Booking Sesi Reguler]
            UC16[Booking Sesi Privat]
            UC17[Periksa Batas Harian]
            UC18[Booking Sesi Gratis]
            UC19[Booking Sesi Berbayar Tambahan]
        end

        subgraph "Sistem Pembayaran"
            UC20[Bayar Sesi Reguler]
            UC21[Bayar Sesi Privat]
            UC22[Pilih Pembayaran Manual]
            UC23[Upload Bukti Transfer]
            UC24[Kirim Bukti Pembayaran]
            UC25[Lihat Status Pembayaran]
            UC26[Generate Instruksi Pembayaran]
        end

        subgraph "Manajemen Kuota Member"
            UC27[Gabung Antrian Member]
            UC28[Monitor Posisi Antrian]
            UC29[Konfirmasi Penawaran Promosi]
            UC30[Lihat Dashboard Kuota]
        end

        subgraph "Sistem Kafe"
            UC31[Scan Barcode/QR Code]
            UC32[Jelajahi Menu]
            UC33[Tambah Item ke Keranjang]
            UC34[Tambah Catatan Khusus]
            UC35[Kelola Keranjang]
            UC36[Proses Pembayaran]
            UC37[Konfirmasi Penerimaan]
        end

        subgraph "Rating & Review"
            UC38[Rating Layanan]
            UC39[Kirim Review]
            UC40[Lihat Analitik Rating]
        end

        subgraph "Autentikasi"
            UC41[Login via Google SSO]
            UC42[Sinkronisasi Profil Google]
        end

        subgraph "Notifikasi"
            UC43[Terima Push Notifikasi]
            UC44[Konfigurasi Notifikasi]
            UC45[Lihat Riwayat Notifikasi]
        end
    end

    linkStyle 0 stroke:#96ceb4,stroke-width:2px
    A4 -.-> UC1
    A4 -.-> UC2
    A4 -.-> UC3
    A4 -.-> UC4
    A4 -.-> UC5
    A4 -.-> UC6
    A4 -.-> UC7
    A4 -.-> UC8
    A4 -.-> UC9
    A4 -.-> UC10
    A4 -.-> UC11
    A4 -.-> UC12
    A4 -.-> UC13
    A4 -.-> UC14
    A4 -.-> UC15
    A4 -.-> UC16
    A4 -.-> UC17
    A4 -.-> UC18
    A4 -.-> UC19
    A4 -.> UC20
    A4 -.> UC21
    A4 -.> UC22
    A4 -.> UC23
    A4 -.> UC24
    A4 -.> UC25
    A4 -.> UC26
    A4 -.> UC27
    A4 -.> UC28
    A4 -.> UC29
    A4 -.> UC30
    A4 -.> UC31
    A4 -.> UC32
    A4 -.> UC33
    A4 -.> UC34
    A4 -.> UC35
    A4 -.> UC36
    A4 -.> UC37
    A4 -.> UC38
    A4 -.> UC39
    A4 -.> UC40
    A4 -.> UC41
    A4 -.> UC42
    A4 -.> UC43
    A4 -.> UC44
    A4 -.> UC45
```

## 5. Diagram Use Case - Non-Member

```mermaid
graph TB
    subgraph "Use Case Non-Member"
        A5[Non-Member]

        subgraph "Registrasi & Autentikasi"
            UC1[Daftar sebagai Tamu]
            UC2[Login via Google SSO]
            UC3[Daftar via Google SSO]
            UC4[Sinkronisasi Profil Google]
        end

        subgraph "Sistem Booking"
            UC5[Akses Interface Kalender]
            UC6[Navigasi Kalender ke Depan]
            UC7[Pilih Tanggal Tersedia]
            UC8[Lihat Detail Sesi]
            UC9[Pilih Sesi]
            UC10[Selesaikan Booking]
            UC11[Terima Konfirmasi]
            UC12[Batal Booking]
            UC13[Booking Sesi Reguler]
            UC14[Booking Sesi Privat]
            UC15[Periksa Ketersediaan Real-time]
        end

        subgraph "Sistem Pembayaran"
            UC16[Bayar Sesi Reguler]
            UC17[Bayar Sesi Privat]
            UC18[Pilih Pembayaran Manual]
            UC19[Upload Bukti Transfer]
            UC20[Kirim Bukti Pembayaran]
            UC21[Lihat Status Pembayaran]
            UC22[Generate Instruksi Pembayaran]
        end

        subgraph "Sistem Kafe"
            UC23[Scan Barcode/QR Code]
            UC24[Jelajahi Menu]
            UC25[Tambah Item ke Keranjang]
            UC26[Tambah Catatan Khusus]
            UC27[Kelola Keranjang]
            UC28[Proses Pembayaran]
            UC29[Konfirmasi Penerimaan]
        end

        subgraph "Konversi Member"
            UC30[Konversi ke Member]
            UC31[Lihat Manfaat Keanggotaan]
            UC32[Bandingkan Paket]
        end

        subgraph "Layanan"
            UC33[Rating Layanan]
            UC34[Kirim Review]
            UC35[Terima Push Notifikasi]
            UC36[Konfigurasi Notifikasi]
        end

        subgraph "Sewa Kolam Privat"
            UC37[Booking Kolam Privat]
            UC38[Periksa Status Pelanggan Baru]
            UC39[Terapkan Bonus Waktu]
            UC40[Proses Pembayaran]
        end
    end

    linkStyle 0 stroke:#feca57,stroke-width:2px
    A5 -.-> UC1
    A5 -.-> UC2
    A5 -.-> UC3
    A5 -.-> UC4
    A5 -.-> UC5
    A5 -.-> UC6
    A5 -.-> UC7
    A5 -.-> UC8
    A5 -.-> UC9
    A5 -.-> UC10
    A5 -.-> UC11
    A5 -.> UC12
    A5 -.> UC13
    A5 -.> UC14
    A5 -.> UC15
    A5 -.> UC16
    A5 -.> UC17
    A5 -.> UC18
    A5 -.> UC19
    A5 -.> UC20
    A5 -.> UC21
    A5 -.> UC22
    A5 -.> UC23
    A5 -.> UC24
    A5 -.> UC25
    A5 -.> UC26
    A5 -.> UC27
    A5 -.> UC28
    A5 -.> UC29
    A5 -.> UC30
    A5 -.> UC31
    A5 -.> UC32
    A5 -.> UC33
    A5 -.> UC34
    A5 -.> UC35
    A5 -.> UC36
    A5 -.> UC37
    A5 -.> UC38
    A5 -.> UC39
    A5 -.> UC40
```
