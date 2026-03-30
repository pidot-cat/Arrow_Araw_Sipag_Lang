# Arrow Araw Sipag Lang 🎮

A vibrant arrow puzzle escape mobile game built with Flutter.

## 📱 Overview

**Arrow Araw Sipag Lang** is an engaging puzzle game where players strategically tap colorful arrows to clear a 6x6 grid board. Navigate through obstacles, manage your 3 lives, and achieve victory by clearing all arrows!

## ✨ Features

### Complete 17-Screen Application
1. **Splash Screen** - Animated app entry with logo
2. **Login Screen** - User authentication
3. **Sign Up Screen** - New user registration
4. **Home Screen** - Main navigation hub
5. **Game Screen (3 Hearts)** - Full health gameplay
6. **Game Screen (2 Hearts)** - Medium tension state
7. **Game Screen (1 Heart)** - High tension, final life
8. **Game Over Screen** - Loss state overlay
9. **Victory Screen** - Win state celebration
10. **Records Screen** - Player statistics
11. **Settings Screen** - App configuration
12. **Contact Screen** - Help & support
13. **Terms Screen** - Terms of Service
14. **Policy Screen** - Privacy Policy
15. **About Screen** - App information
16. **Game Win (Variant)** - Alternative victory screen
17. **Code View** - Developer documentation

### 🎯 Core Gameplay Mechanics
- **6x6 Grid Board** - Strategic puzzle layout
- **Colorful Arrows** - 6 vibrant arrow types (Cyan, Orange, Green, Purple, Red, Yellow)
- **Directional Movement** - Arrows travel in their indicated direction
- **Obstacle System** - 20% random obstacle density
- **3 Lives System** - Heart-based health indicator
- **Win Condition** - Clear all arrows from the board
- **Lose Condition** - Arrows hit obstacles or each other

### 🎨 Visual Design
- **Color Palette**:
  - Primary Gradient: Deep Blue (#271E9A) to Dark Grey (#212125)
  - Secondary Gradient: Silver Grey (#A2A2A3) to Dark Grey (#3D3D3D)
  - Vibrant Arrow Colors: Cyan, Orange, Green, Purple, Red, Yellow
- **Futuristic Theme** - Cityscape background with particle effects
- **Smooth Animations** - Splash transitions, arrow movements

### 📊 Statistics Tracking
- Total Wins
- Total Losses
- Total Matches
- Total Days
- Win Rate Percentage

## 🛠️ Technology Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Language**: Dart
- **IDE**: VS Code

## 📂 Project Structure

```
arrow_araw_sipag_lang/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   ├── arrow_model.dart      # Arrow entity
│   │   └── game_stats_model.dart # Statistics model
│   ├── providers/
│   │   ├── game_provider.dart    # Game state management
│   │   └── auth_provider.dart    # Authentication logic
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── home_screen.dart
│   │   ├── game_screen.dart
│   │   ├── records_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── contact_screen.dart
│   │   ├── terms_screen.dart
│   │   ├── policy_screen.dart
│   │   └── about_screen.dart
│   ├── widgets/
│   │   ├── gradient_button.dart
│   │   ├── gradient_input_field.dart
│   │   ├── background_wrapper.dart
│   │   └── life_indicator.dart
│   └── utils/
│       ├── app_colors.dart       # Color constants
│       └── constants.dart        # App constants
├── assets/
│   ├── Back Button Icon.png
│   ├── background.png
│   ├── Game Over.png
│   ├── heart icon Black.png
│   ├── heart icon Red.png
│   ├── LOGO WITH BACKGROUND.png
│   ├── logo.png
│   ├── Setting Icon.png
│   ├── Timer.webp
│   └── Victory.png
└── pubspec.yaml                  # Dependencies
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- VS Code or Android Studio
- Android Emulator or iOS Simulator

### Installation

1. **Clone or extract the project**
```bash
cd arrow_araw_sipag_lang
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

## 🎮 How to Play

1. **Start Game** - Tap the PLAY button from the home screen
2. **Tap Arrows** - Click any arrow to activate it
3. **Arrow Movement** - The arrow moves in its indicated direction
4. **Clear Board** - Remove all arrows to win
5. **Avoid Obstacles** - Don't let arrows hit obstacles (grey cells)
6. **Manage Lives** - You have 3 hearts; hitting obstacles costs 1 life
7. **Victory** - Clear all arrows without losing all lives
8. **Game Over** - Try again if you lose all 3 lives

## 🔧 Configuration

### Modify Game Settings
Edit `lib/utils/constants.dart`:
```dart
static const int gridSize = 6;           // Board size
static const int initialLives = 3;        // Starting lives
static const double obstacleDensity = 0.2; // 20% obstacles
```

### Change Colors
Edit `lib/utils/app_colors.dart`:
```dart
static const Color arrowCyan = Color(0xFF00E5FF);
static const Color primaryDark = Color(0xFF271E9A);
```

## 📱 Screens Overview

### Authentication Flow
- **Splash** → Auto-navigate after 3 seconds
- **Login** → Enter credentials or go to Sign Up
- **Sign Up** → Create account with username & password

### Main Flow
- **Home** → Navigate to Play, Records, or Settings
- **Game** → Play the puzzle game
- **Records** → View your statistics
- **Settings** → Access app info and logout

### Info Pages
- **Contact** → Submit support requests
- **Terms** → Read Terms of Service
- **Policy** → Read Privacy Policy
- **About** → Learn about the app

## 🎨 Design Features

### Gradients
- **Primary Buttons**: Deep Blue to Dark Grey
- **Input Fields**: Silver Grey to Dark Grey
- **Backgrounds**: Cityscape with 30% opacity

### Assets Integration
All 10 assets are integrated:
- Logo variations for splash and headers
- Heart icons for life indicators
- Victory/Game Over overlays
- Background and UI icons

## 🔐 Data Persistence

User data stored locally using SharedPreferences:
- Username
- Login state
- Total wins
- Total losses
- Total matches
- Total days played

## 🏗️ Architecture

### State Management
- **Provider Pattern** - Centralized state management
- **GameProvider** - Handles game logic and state
- **AuthProvider** - Manages authentication

### Separation of Concerns
- **Models** - Data structures
- **Providers** - Business logic
- **Screens** - UI components
- **Widgets** - Reusable components
- **Utils** - Constants and helpers

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  shared_preferences: ^2.2.0
  cupertino_icons: ^1.0.2
```

## 🚀 Build for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🐛 Troubleshooting

### Assets Not Loading
```bash
flutter clean
flutter pub get
flutter run
```

### State Not Persisting
Check SharedPreferences initialization in providers

### Grid Not Rendering
Verify gridSize constant and device screen size

## 📄 License

© 2026 Arrow Araw Sipag Lang. All rights reserved.

## 👥 Support

- Email: support@arrowaraw.com
- Privacy: privacy@arrowaraw.com

## 🎯 Future Enhancements

- [ ] Multiple difficulty levels
- [ ] Leaderboard system
- [ ] Daily challenges
- [ ] Sound effects
- [ ] Haptic feedback
- [ ] Achievement system
- [ ] Theme customization

---

**Made with ❤️ using Flutter**