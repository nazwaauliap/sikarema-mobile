# 🎓 SIKAREMA Mobile 

> Sistem Klaim Reward Mahasiswa berbasis Flutter yang terintegrasi dengan backend Laravel melalui REST API.

## 📱 Tentang Project

SIKAREMA Mobile merupakan aplikasi mobile yang dikembangkan menggunakan **Flutter** sebagai frontend dan **Laravel** sebagai backend. Aplikasi ini memungkinkan mahasiswa untuk mengelola prestasi, mengajukan klaim reward, serta memantau status pengajuan secara langsung melalui perangkat mobile.

Project ini merupakan pengembangan dari aplikasi web SIKAREMA agar mahasiswa dapat mengakses layanan dengan lebih mudah dan praktis.

---

## ✨ Fitur yang Telah Diimplementasikan

### 🔐 Authentication
- Login menggunakan REST API
- Laravel Sanctum Authentication
- Penyimpanan token lokal
- Logout

### 🏠 Dashboard
- Dashboard modern
- Ringkasan data mahasiswa
- Banner informasi
- Bottom Navigation

### 🏆 Prestasi
- Struktur halaman Prestasi
- Persiapan integrasi API

### 🎁 Klaim Reward
- Struktur halaman Klaim Reward
- Persiapan integrasi API

### 👤 Profile
- Struktur halaman Profile
- Persiapan integrasi API

---

## 🚧 Progress Pengembangan

| Fitur | Status |
|--------|:------:|
| Login API | ✅ |
| Dashboard UI | ✅ |
| Dashboard API | 🚧 |
| Prestasi API | 🚧 |
| Klaim Reward API | 🚧 |
| Profile API | 🚧 |
| Master Data API | 🚧 |

---

## 🛠 Tech Stack

### Frontend
- Flutter
- Dart
- Dio
- GoRouter

### Backend
- Laravel
- Laravel Sanctum
- MySQL

---

## 📂 Struktur Project

```text
lib/
│
├── app/
│
├── core/
│   ├── network/
│   └── storage/
│
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── prestasi/
│   ├── klaim/
│   ├── profile/
│   └── riwayat/
│
└── shared/
```

---

## 🔌 REST API

Saat ini aplikasi telah terhubung dengan beberapa endpoint Laravel.

### Authentication

```
POST /api/v1/login
GET  /api/v1/profile
POST /api/v1/logout
```

### Dashboard

```
GET /api/v1/dashboard
```

### Prestasi

```
GET  /api/v1/prestasi
GET  /api/v1/prestasi/{id}
POST /api/v1/prestasi
```

### Klaim Reward

```
GET  /api/v1/klaim-reward
POST /api/v1/klaim-reward
```

### Master Data

```
GET /api/v1/kategori-prestasi
GET /api/v1/tingkat-prestasi
GET /api/v1/jenis-reward
```

---

## 🚀 Cara Menjalankan Project

### Clone Repository

```bash
git clone https://github.com/username/sikarema_mobile.git
```

### Install Dependency

```bash
flutter pub get
```

### Jalankan Project

```bash
flutter run
```

---

## 📸 Screenshot

> Screenshot aplikasi akan ditambahkan setelah seluruh fitur selesai diimplementasikan.

---

## 📌 Status Project

🚧 **On Going Development**

Project masih dalam tahap pengembangan dan integrasi API.

---

## 👨‍💻 Developer

Developed with ❤️ using Flutter & Laravel.
