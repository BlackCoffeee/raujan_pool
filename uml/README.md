# Dokumentasi UML - Sistem Kolam Renang Syariah

Folder ini berisi dokumentasi UML (Unified Modeling Language) untuk Sistem Kolam Renang Syariah yang telah diterjemahkan ke dalam bahasa Indonesia.

## Struktur File

### 1. Use Case Diagrams (`use-case-diagrams.md`)

Berisi diagram use case untuk semua aktor dalam sistem:

- **Admin**: Manajemen sistem, konfigurasi, dan monitoring
- **Staff Front Desk**: Operasi harian, booking, dan layanan pelanggan
- **Staff Kafe**: Manajemen menu, pesanan, dan inventori
- **Member**: Booking, pembayaran, dan layanan member
- **Non-Member**: Booking sebagai tamu dan konversi ke member

### 2. Class Diagrams (`class-diagrams.md`)

Berisi diagram class yang menggambarkan struktur data dan relasi antar entitas:

- **Class Utama**: User, Member, Package, Booking, Session, Payment
- **Sistem Kafe**: Menu, Order, Inventory, dan manajemen stok
- **Sistem Rating**: Rating, komponen rating, dan analitik
- **Sistem Promosi**: Campaign, template, dan analitik promosi
- **Pembayaran Manual**: Verifikasi, konfigurasi bank, dan log
- **Kuota Member**: Konfigurasi, antrian, dan tracking kedaluwarsa
- **Batas Harian**: Penggunaan harian dan override
- **Sewa Kolam Privat**: Booking privat dan pricing
- **Sistem Barcode**: Generate dan scan barcode menu
- **Pelaporan**: Laporan keuangan, operasional, dan analitik
- **Integrasi Sistem**: Notifikasi, log, dan sesi

### 3. Activity Diagrams (`activity-diagrams.md`)

Berisi diagram aktivitas yang menggambarkan alur proses bisnis:

- **Registrasi Member**: Proses pendaftaran dan verifikasi
- **Proses Booking**: Alur booking dari pemilihan hingga konfirmasi
- **Pesanan Kafe**: Proses pesanan dari scan barcode hingga delivery
- **Sistem Rating**: Alur rating dan review layanan
- **Check-in/Check-out**: Proses masuk dan keluar kolam
- **Harga Promosi**: Manajemen kampanye dan diskon
- **Pembayaran Manual**: Verifikasi transfer manual
- **Kuota Member**: Manajemen kuota dan antrian
- **Batas Harian**: Pengaturan limit berenang harian
- **Sewa Kolam Privat**: Booking kolam eksklusif
- **Manajemen Menu**: CRUD menu dan barcode
- **Pelaporan**: Generate dan export laporan

### 4. Sequence Diagrams (`sequence-diagrams.md`)

Berisi diagram sequence yang menggambarkan interaksi antar komponen:

- **Registrasi Member**: Interaksi user, sistem, admin, dan database
- **Proses Booking**: Alur booking dengan kalender dan pembayaran
- **Pesanan Kafe**: Interaksi dengan barcode scanner dan dapur
- **Sistem Rating**: Proses rating dan update analitik
- **Check-in**: Interaksi staff, sistem, dan peralatan
- **Pembayaran Manual**: Verifikasi admin dan konfirmasi
- **Manajemen Menu**: CRUD menu dan update inventori
- **Generate Barcode**: Proses generate dan download barcode
- **Pelaporan**: Generate dan export laporan

## Cara Menggunakan

1. **Untuk Developer**: Gunakan diagram ini sebagai referensi untuk implementasi sistem
2. **Untuk Analis**: Diagram ini membantu memahami requirement dan alur bisnis
3. **Untuk Stakeholder**: Diagram memberikan gambaran visual tentang sistem

## Catatan Penting

- Semua diagram menggunakan bahasa Indonesia untuk kemudahan pemahaman
- Diagram mengikuti standar UML dengan notasi Mermaid
- Setiap diagram dilengkapi dengan penjelasan komponen dan relasi
- Diagram dapat di-render langsung di platform yang mendukung Mermaid

## Teknologi

- **Format**: Markdown dengan Mermaid diagrams
- **Standar**: UML 2.0
- **Bahasa**: Indonesia
- **Tool**: Mermaid.js untuk rendering diagram
