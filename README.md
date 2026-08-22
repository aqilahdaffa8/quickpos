# 🚀 QuickPOS - Enterprise Point of Sale

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/Status-Production_Ready-success?style=for-the-badge)

**QuickPOS** adalah aplikasi kasir pintar (Point of Sale) *offline-first* yang dirancang khusus untuk UMKM, ritel, dan bisnis F&B. Dibangun menggunakan **Flutter** dengan pendekatan *Clean Architecture* dan performa tinggi berkat eksekusi database lokal menggunakan **SQLite**.


## ✨ Fitur Utama (Key Features)

- 📦 **Manajemen Inventaris Berbasis Visual:** Kelola produk dan kategori dengan dukungan gambar lokal (`image_picker` & `path_provider`) dan pemetaan ikon dinamis.
- 🛒 **Mesin Kasir (POS) Cepat:** Antarmuka interaktif dengan validasi stok otomatis dan kalkulasi keranjang *real-time*.
- 🛡️ **ACID Compliant Transactions:** Transaksi checkout menggunakan fitur **SQL Batch Processing** untuk menjamin integritas data (rollback otomatis jika terjadi kegagalan pemotongan stok).
- 🖨️ **Sistem Bukti Bayar Hybrid (Hybrid Receipt System):**
  - **Hardware Integration:** Mencetak struk secara instan ke *Printer Thermal* via Bluetooth menggunakan format *raw bytes* (ESC/POS).
  - **Digital Receipt:** Menghasilkan bukti bayar PDF berukuran kertas 80mm dan membagikannya langsung via WhatsApp/Email (Native Share).
- 📈 **Dashboard Analitik & Laporan Bisnis:** Kalkulasi omset bulanan dan laba bersih yang diolah menggunakan *Raw SQL Queries* berat, divisualisasikan dengan grafik interaktif (`fl_chart`).
- ⚡ **100% Offline-First:** Seluruh data disimpan dan diproses secara lokal di perangkat tanpa memerlukan koneksi internet, menjamin kecepatan dan privasi data 100%.

## 🛠️ Tech Stack & Dependencies

- **Framework:** Flutter SDK
- **State Management:** Provider
- **Database:** `sqflite` (SQLite Native Engine)
- **UI/Charts:** `fl_chart`
- **Hardware/IoT:** `print_bluetooth_thermal`, `esc_pos_utils_plus`
- **File Management:** `pdf`, `share_plus`, `path_provider`, `image_picker`

## 🚀 Panduan Instalasi (Getting Started)

### Prasyarat
- Flutter SDK (Versi terbaru)
- Perangkat Android fisik atau Emulator (Sangat disarankan menggunakan perangkat fisik untuk menguji integrasi Printer Bluetooth dan Kamera/Galeri).

### Langkah Instalasi
1. *Clone* repositori ini:
```bash
git clone [https://github.com/username-anda/quick_pos.git](https://github.com/username-anda/quick_pos.git)

```

2. Masuk ke direktori proyek:
```bash
cd quick_pos

```


3. Unduh semua *dependencies*:
```bash
flutter pub get

```


4. Jalankan aplikasi:
```bash
flutter run

```



*(Catatan: Aplikasi tidak akan berfungsi penuh di Web Browser karena keterbatasan isolasi hardware Bluetooth dan SQLite native).*

## 🏗️ Struktur Arsitektur

Proyek ini mengadaptasi prinsip **Feature-First Architecture** dan **Clean Architecture** ringan untuk memastikan skalabilitas kode:

```text
lib/
 ├── core/             # Utilitas inti (DB Helper, Formatters, Print Services, App Colors)
 ├── features/         # Modul independen berbasis fitur
 │   ├── category/     # Modul Manajemen Kategori
 │   ├── dashboard/    # Modul Dashboard Utama
 │   ├── pos/          # Modul Mesin Kasir & Keranjang
 │   ├── product/      # Modul Manajemen Produk & Gambar
 │   ├── report/       # Modul Analitik SQL & Grafik Laporan
 │   ├── splash/       # Modul Splash Screen
 │   └── transaction/  # Modul Checkout, SQL Batch, & Bukti Bayar
 └── main.dart         # Entry point aplikasi

```

## 🤝 Kontribusi

Jika Anda ingin berkontribusi, menemukan *bug*, atau memiliki permintaan fitur, silakan buat *Pull Request* atau buka *Issue* baru.

---

*Didesain dan dibangun dengan ❤️ oleh [Nama Anda/Username Anda]*

```

```
