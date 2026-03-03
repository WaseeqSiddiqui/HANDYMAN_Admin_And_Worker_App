# 🔧 HANDYMAN Admin And Worker App

A comprehensive **Flutter-based** admin and worker management application for the HANDYMAN service platform. This app streamlines service management, worker coordination, financial tracking, and customer interactions — all powered by **Firebase**.

---

## 📱 Screenshots

> *Coming soon*

---

## ✨ Features

### 🛡️ Admin Panel
- **Dashboard** — Real-time overview of services, workers, earnings & analytics
- **Worker Management** — Add, edit, monitor and manage worker profiles
- **Customer Management** — View customer details and service history
- **Service Management** — Create and manage service categories & offerings
- **Service Requests** — Track, assign and manage incoming service requests
- **Invoice Management** — Generate, view and manage professional PDF invoices with VAT support
- **Financial Reports** — Detailed financial analytics with monthly comparisons
- **Commission Management** — Configure and track worker commission rates
- **Credit & Withdrawal Requests** — Approve/reject worker credit and withdrawal requests
- **VAT Management** — Configure and manage VAT settings
- **Admin Wallet** — Track admin earnings and transactions
- **Push Notifications** — Send notifications to workers and customers
- **Reviews & Ratings** — Monitor customer reviews and ratings

### 👷 Worker Panel
- **Worker Dashboard** — Personal overview of assigned jobs and earnings
- **Wallet** — Track earnings, commissions, and transaction history
- **Credit Screen** — Request credits and view credit history
- **Job Management** — Accept, track and complete assigned service requests
- **Profile Management** — Update personal details and availability

### 🌐 General Features
- 🌍 **Multi-language Support** — Arabic & English with full RTL support
- 🔔 **Push Notifications** — Firebase Cloud Messaging integration
- 📶 **Offline Handling** — Graceful no-internet detection and recovery
- 🔒 **Secure Authentication** — Firebase Auth with role-based access
- 📊 **Real-time Data** — Cloud Firestore for live data synchronization
- 📄 **PDF Invoice Generation** — Professional invoices with printing support
- 📸 **Image Upload** — Firebase Storage for profile pictures and media
- 📉 **Crash Analytics** — Firebase Crashlytics & Analytics integration

---

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── admin/                       # Admin panel screens
│   ├── admin_wallet_screen.dart
│   ├── commission_management_screen.dart
│   ├── credit_requests_screen.dart
│   ├── customer_management_screen.dart
│   ├── financial_reports_screen.dart
│   ├── generate_invoice_screen.dart
│   ├── invoice_management_screen.dart
│   ├── notifications_screen.dart
│   ├── reviews_screen.dart
│   ├── service_management_screen.dart
│   ├── service_requests_screen.dart
│   ├── vat_management_screen.dart
│   ├── withdrawl_requests_screen.dart
│   └── worker_management_screen.dart
├── worker/                      # Worker panel screens
│   ├── credit_screen.dart
│   └── wallet_screen.dart
├── screens/                     # Shared screens
│   ├── dashboard/
│   │   ├── complete_admin_dashboard.dart
│   │   └── worker_dashboard.dart
│   ├── splash_screen.dart
│   └── no_internet_screen.dart
├── models/                      # Data models
├── services/                    # Business logic & Firebase services
├── providers/                   # State management (Provider)
├── handlers/                    # Event handlers
├── utils/                       # Utilities & translations
└── widgets/                     # Reusable UI components
```

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform UI framework |
| **Dart** | Programming language |
| **Firebase Auth** | User authentication |
| **Cloud Firestore** | Real-time NoSQL database |
| **Firebase Storage** | File & image storage |
| **Firebase Cloud Messaging** | Push notifications |
| **Firebase Crashlytics** | Crash reporting |
| **Firebase Analytics** | Usage analytics |
| **Provider** | State management |
| **PDF / Printing** | Invoice generation |

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** `^3.9.2`
- **Dart SDK** (bundled with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Firebase Project** configured with required services

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/WaseeqSiddiqui/HANDYMAN-Admin-And-Worker-App.git
   cd HANDYMAN-Admin-And-Worker-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Set up a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update `firebase_options.dart` with your configuration

4. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release
```

---

## 📦 Key Dependencies

| Package | Version | Description |
|---|---|---|
| `firebase_core` | ^2.24.0 | Firebase initialization |
| `firebase_auth` | ^4.17.3 | Authentication |
| `cloud_firestore` | ^4.13.3 | Firestore database |
| `firebase_storage` | ^11.5.3 | Cloud storage |
| `firebase_messaging` | ^14.7.3 | Push notifications |
| `firebase_analytics` | ^10.8.3 | Analytics |
| `firebase_crashlytics` | ^3.2.3 | Crash reporting |
| `provider` | ^6.1.2 | State management |
| `pdf` | ^3.10.7 | PDF generation |
| `printing` | ^5.11.1 | Printing support |
| `http` | ^1.2.1 | HTTP client |
| `image_picker` | ^1.2.1 | Image selection |
| `connectivity_plus` | ^6.1.5 | Network detection |
| `shared_preferences` | ^2.2.3 | Local storage |

---

## 👥 Contributors

- **Waseeq Siddiqui** — Lead Developer
- **Eiman Fatima** — Contributor ([eimanfkhan18@gmail.com](mailto:eimanfkhan18@gmail.com))

---

## 📄 License

This project is proprietary software. All rights reserved.

---

## 📞 Support

For support and queries, please reach out to the development team.

---

> **Version:** 8.0.1+13 | **Min Android SDK:** 21
