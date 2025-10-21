# Student Training Score App

## 📁 Project Structure

```
lib/
├── main.dart                          # Entry point
├── models/                            # Data models
│   ├── activity.dart                  # Activity model
│   └── training_score.dart            # Training score model
├── routes/                            # App routing
│   └── app_routes.dart                # Route definitions
├── screens/                           # UI screens
│   ├── dashboard/                     # Dashboard screens
│   │   ├── dashboard_screen.dart      # Main dashboard
│   │   ├── activity_registration_screen.dart
│   │   ├── activity_detail_screen.dart
│   │   ├── training_score_screen.dart
│   │   └── score_detail_screen.dart
│   └── settings/                      # Settings screens
│       └── settings_screen.dart       # Settings page
└── utils/                             # Utilities
    └── mock_data.dart                 # Mock data for testing
```

## 🎯 Main Features

### 1. **Activity Registration** (Đăng ký hoạt động)
- View upcoming, ongoing, and completed activities
- Filter by category
- Register/Cancel registration
- View activity details

### 2. **Training Score** (Điểm rèn luyện)
- View training scores by semester
- View detailed breakdown by category
- See activity history

### 3. **Settings** (Cài đặt)
- User profile management
- Password change
- Notification settings
- Language preferences
- Dark mode toggle

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.8.1
- Dart SDK ^3.8.1

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd DiemDanhSinhVien
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## 📦 Dependencies

- **intl** (^0.19.0) - Date formatting and internationalization

## 🏗️ Architecture

This project follows a simple **screen-based architecture**:
- **Models**: Data classes representing business entities
- **Screens**: UI components organized by feature
- **Utils**: Helper functions and mock data
- **Routes**: Navigation configuration

## 🎨 Design

- **Primary Color**: #1E90FF (Dodger Blue)
- **Material Design 3**: Enabled
- **Font Family**: Roboto

## 📝 Notes

- Currently using **mock data** for demonstration
- No backend integration (removed Supabase, Auth services)
- Focus on **UI/UX** implementation
- Ready for backend integration when needed

## 🧹 Recent Cleanup

Removed unnecessary folders and files:
- ❌ `lib/view/` (old structure)
- ❌ `lib/views/` (old structure)
- ❌ `lib/viewmodels/` (not using MVVM)
- ❌ `lib/services/` (no backend)
- ❌ Unused dependencies (supabase, dio, provider, etc.)

## 👤 Author

- **Võ Nhật Ngân**
- Student ID: 2021600123
- Major: Information Technology

## 📄 License

This project is part of a thesis/graduation project.

---
**Version**: 1.0.0  
**Last Updated**: October 21, 2025
