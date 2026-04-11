# 🏹 Arrow Araw: Sipag Lang
A vibrant arrow puzzle escape mobile game built with Flutter.

## ✨ Features

### 📱 Application Screens

- Splash Screen - Animated app entry with the official Main Logo.
- Login Screen - Secure user authentication via Supabase.
- Sign Up Screen - New user registration with OTP email verification.
- Forgot Password Screen - 3-step account recovery via OTP email verification.
- Home Screen - The main navigation hub with Welcome message.
- Level Select Screen - Dynamic map featuring 10 difficulty tiers.

#### 🎮 Game Levels

| Level | Grid  |  Shape   | Arrows |
|-------|-------|----------|--------|
|   1   | 5×5   | Heart    |   13   |
|   2   | 6×6   | Circle   |   20   |
|   3   | 7×7   | Triangle |   25   |
|   4   | 8×8   | Square   |   30   |
|   5   | 9×9   | Pentagon |   38   |
|   6   | 10×10 | Hexagon  |   45   |
|   7   | 11×11 | Heptagon |   55   |
|   8   | 12×12 | Shield   |   62   |
|   9   | 13×13 | Nonagon  |   70   |
|   10  | 14×14 | Cross    |   66   |

#### ⚙️ Other Screens

- Settings Screen - App configuration and account management.
- Records Screen - Real-time statistics (Wins/Losses) synced from the cloud.
- About Screen - Development mission and version info (v1.0.0).
- Contact Screen - Support channel for user inquiries.
- Privacy Policy Screen - Data protection and Supabase storage terms.
- Terms of Service Screen - User guidelines and app rules.

## 🎯 Core Gameplay Mechanics

- **Bent Arrow Puzzle** – Each arrow follows an L-shaped or straight path through the grid. Tap arrows in the correct order to slide them off the board.
- **Solve Order** – Arrows are numbered 0→N and must be cleared in sequence. Tapping the wrong one costs a life.
- **Escape Direction** – Each arrow has an `escape` direction (up/down/left/right). It can only slide out if its path is unblocked by remaining arrows.
- **Lives System** – 3 lives per level. Wrong taps or time expiry end the game.
- **60-Second Timer** – Complete every level within 60 seconds.
- **Supabase Integration** – Real-time database for user records and cloud-based authentication.
- **OTP Email Verification** – 6-digit code sent to email for Sign Up and Forgot Password flows.
- **Immersive Audio** – Menu music and in-game sound effects using audioplayers.
- **Advanced Animations** – Smooth slide-out animations and UI transitions via flutter_animate.
- **Statistics Tracking** – Automated tracking of Wins, Losses, and Matches.

## 🖼️ Visual Design Notes

- **Grid cells** only display a background highlight on cells that currently have an unsolved arrow — empty cells render transparently, keeping the grid clean.
- **Arrow shafts** render as smooth L-bends (right-angle turns) when connecting two cells that differ in both row and column, using the painter's horizontal-first L-bend logic.
- **No tail dot** — single-point arrows skip the dot fallback; all arrows render shaft + arrowhead only.

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
│   ├── level_base.dart          ← Shared painter, mixins, arrow models
│   ├── game_screen_lvl_1.dart
│   ├── game_screen_lvl_2.dart
│   ├── game_screen_lvl_3.dart
│   ├── game_screen_lvl_4.dart
│   ├── game_screen_lvl_5.dart
│   ├── game_screen_lvl_6.dart
│   ├── game_screen_lvl_7.dart
│   ├── game_screen_lvl_8.dart   ← Shield shape, 12×12, 62 arrows
│   ├── game_screen_lvl_9.dart
│   └── game_screen_lvl_10.dart  ← Cross shape, 14×14, 66 arrows
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

## 🏗️ Architecture & Logic

### Arrow Data Models
- **`ArrowData`** — Legacy straight-line arrows (used by earlier levels).
- **`BentArrowData`** — Multi-segment bent arrows. Each arrow holds an ordered list of `BentCell` grid positions and an `escape` direction.

### Painter Logic (`BentArrowPainter`)
- Draws the arrow shaft as a polyline through cell centers.
- **L-bend rendering**: When consecutive cells differ in both row and column, the painter inserts a right-angle corner (horizontal-first) instead of a diagonal line.
- No tail dot — single-point fallback removed for a clean look.

### Grid Rendering
- Cell backgrounds are drawn **only** on cells occupied by an unsolved arrow.
- As arrows are cleared, their cells fade out of the grid automatically.

### State Management
The app uses the Provider Pattern. `GameProvider` handles grid state and statistics; `AuthProvider` manages Supabase authentication.

### Data Persistence
- **Cloud**: High scores and profiles stored in Supabase.
- **Local**: SharedPreferences for fast local session handling.

## 🛠️ Technology Stack

- Framework: Flutter (Dart)
- Backend: Supabase
- State Management: Provider
- Animations: Flutter Animate
- Audio: Audioplayers
- Design: Figma & Canva

## 👨‍💻 About the Developer

Developed by a student of Urdaneta City University. This project is a practical application of advanced mobile development, emphasizing the philosophy: **Sipag Lang** (Hard Work Only).
