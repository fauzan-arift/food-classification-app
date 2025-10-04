# Food Classification App

Aplikasi mobile untuk mengidentifikasi makanan menggunakan kamera dan machine learning.

## Fitur

- Ambil foto makanan dengan kamera
- Klasifikasi makanan otomatis menggunakan TensorFlow Lite
- Pencarian resep dari TheMealDB API
- Tab navigasi untuk multiple hasil resep
- UI yang responsive dan user-friendly

## Tech Stack

- **Framework**: Flutter 3.8.1
- **State Management**: Provider
- **ML Model**: TensorFlow Lite
- **API**: TheMealDB
- **Camera**: Camera plugin

## Cara Install

1. Clone repository ini
2. Buka terminal di folder project
3. Jalankan `flutter pub get`
4. Connect device atau start emulator
5. Run `flutter run`

## Struktur Project

```
lib/
├── controller/          # Provider classes
├── models/             # Data models
├── services/           # API & ML services
├── ui/                 # Halaman utama
├── widget/             # Custom widgets
└── main.dart          # Entry point
```

## Asset

- Model ML: `assets/models/1.tflite`
- Labels: `assets/models/labels.txt`

## Dependencies

- flutter
- provider
- camera
- tflite_flutter
- http
- image

## Catatan

Pastikan device support camera dan internet untuk fitur lengkap.
