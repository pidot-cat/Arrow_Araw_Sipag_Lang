# 🏹 Arrow Araw: Sipag Lang
A vibrant arrow puzzle escape mobile game built with Flutter.

## ✨ Features

### 📱 Application Screens

- Splash Screen - Animated app entry with the official Main Logo.
- Login Screen - Secure user authentication via Supabase.
- Sign Up Screen - New user registration with OTP email verification.
- Forgot Password Screen - 3-step account recovery via OTP email verification.
- Home Screen - The main navigation hub with Welcome message.
- Level Select Screen - Dynamic map featuring 10+ difficulty tiers.

#### 🎮 Game Levels

- Game Screen Level 1 - 5x5 grid shape Heart.
- Game Screen Level 2 - 6x6 grid shape Circle.
- Game Screen Level 3 - 7x7 grid shape Triangle.
- Game Screen Level 4 - 8x8 grid shape Square.
- Game Screen Level 5 - 9x9 grid shape Pentagon.
- Game Screen Level 6 - 10x10 grid shape Hexagon.
- Game Screen Level 7 - 11x11 grid shape Heptagon.
- Game Screen Level 8 - 12x12 grid shape Octagon.
- Game Screen Level 9 - 13x13 grid shape Nonagon.
- Game Screen Level 10 - 14x14 grid shape Decagon.

#### ⚙️ Other Screens

- Settings Screen - App configuration and account management.
- Records Screen - Real-time statistics (Wins/Losses) synced from the cloud.
- About Screen - Development mission and version info (v1.0.0).
- Contact Screen - Support channel for user inquiries.
- Privacy Policy Screen - Data protection and Supabase storage terms.
- Terms of Service Screen - User guidelines and app rules.

## 🎯 Core Gameplay Mechanics

- Supabase Integration – Real-time database for user records and cloud-based authentication.
- OTP Email Verification – 6-digit code sent to email for Sign Up and Forgot Password flows.
- Immersive Audio – Menu music and in-game sound effects using audioplayers.
- Advanced Animations – Smooth UI transitions and pulsing effects via flutter_animate.
- Statistics Tracking – Automated tracking of Wins, Losses, and Matches.

## 🔐 Authentication Flow

### Sign Up
1. Fill in Username, Password, Confirm Password, and Email.
2. Tap **Send** to receive a 6-digit OTP code via email.
3. Enter the code and tap **Sign Up** to create your account.

### Forgot Password
1. **Step 1** — Enter your registered email address.
2. **Step 2** — Enter the 6-digit OTP code sent to your email.
3. **Step 3** — Set and confirm your new password.
4. Redirects back to Login upon success.

## 📂 Project Structure

```text
lib/
├── levels/
│   ├── game_screen_lvl_1.dart
│   ├── game_screen_lvl_2.dart
│   ├── game_screen_lvl_3.dart
│   ├── game_screen_lvl_4.dart
│   ├── game_screen_lvl_5.dart
│   ├── game_screen_lvl_6.dart
│   ├── game_screen_lvl_7.dart
│   ├── game_screen_lvl_8.dart
│   ├── game_screen_lvl_9.dart
│   └── game_screen_lvl_10.dart
├── models/
│   ├── arrow_model.dart
│   └── game_stats_model.dart
├── providers/
│   ├── auth_provider.dart
│   └── game_provider.dart
├── screens/
│   ├── about_screen.dart
│   ├── contact_screen.dart
│   ├── forgot_password_screen.dart
│   ├── game_screen.dart
│   ├── home_screen.dart
│   ├── level_select_screen.dart
│   ├── login_screen.dart
│   ├── policy_screen.dart
│   ├── records_screen.dart
│   ├── settings_screen.dart
│   ├── signup_screen.dart
│   ├── splash_screen.dart
│   └── terms_screen.dart
├── services/
│   ├── audio_service.dart
│   └── supabase_service.dart
├── utils/
│   ├── app_colors.dart
│   └── constants.dart
├── widgets/
│   ├── background_wrapper.dart
│   ├── game_over_overlay.dart
│   ├── gradient_button.dart
│   ├── gradient_input_field.dart
│   ├── life_indicator.dart
│   └── victory_overlay.dart
└── main.dart
```

## 🛠️ Technology Stack

- Framework: Flutter (Dart)
- Backend: Supabase
- State Management: Provider
- Animations: Flutter Animate
- Audio: Audioplayers
- Design: Figma & Canva

## 🏗️ Architecture & Logic

### State Management
The app utilizes the Provider Pattern to separate business logic from the UI. GameProvider handles the grid state and statistics, while AuthProvider manages the secure connection to Supabase.

### Data Persistence
- Cloud Storage: High scores and profiles are stored in Supabase.
- Local Storage: SharedPreferences is used for fast local session handling.

## 👨‍💻 About the Developer

Developed by a student of Urdaneta City University. This project is a practical application of advanced mobile development, emphasizing the philosophy: Sipag Lang (Hard Work Only).