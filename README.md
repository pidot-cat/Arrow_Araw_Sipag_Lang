# 🏹 Arrow Araw: Sipag Lang
A vibrant arrow puzzle escape mobile game built with Flutter.

## ✨ Features

### 📱 Application Screens

- **Splash Screen** — Animated app entry with the official Main Logo.
- **Login Screen** — Secure user authentication via Supabase.
- **Sign Up Screen** — New user registration with OTP email verification.
- **Forgot Password Screen** — 3-step account recovery via OTP email verification.
- **Home Screen** — The main navigation hub with Welcome message.
- **Level Select Screen** — Dynamic map featuring 10 difficulty tiers with lock/unlock animations.

#### 🎮 Game Levels

| Level | Grid  | Shape    | Arrows | Difficulty |
|-------|-------|----------|--------|------------|
| 1     | 5×5   | Heart    |   13   | Easy       |
| 2     | 6×6   | Circle   |   20   | Easy       |
| 3     | 7×7   | Triangle |   25   | Normal     |
| 4     | 8×8   | Square   |   30   | Normal     |
| 5     | 9×9   | Pentagon |   38   | Hard       |
| 6     | 10×10 | Hexagon  |   45   | Hard       |
| 7     | 11×11 | Heptagon |   55   | Expert     |
| 8     | 12×12 | Shield   |   62   | Expert     |
| 9     | 13×13 | Nonagon  |   70   | Master     |
| 10    | 14×14 | Cross    |   66   | Master     |

#### ⚙️ Other Screens

- **Settings Screen** — Audio toggles (Music / Sound FX), account management, support navigation.
- **Records Screen** — Real-time statistics (Wins/Losses/Matches/Win Rate/Days Active) synced from the cloud. Compact 60dp max-height rows.
- **About Screen** — Development mission and version info (v1.0.0).
- **Contact Screen** — Support channel → sends email to arrowarawsipaglang@gmail.com via EmailJS.
- **Privacy Policy Screen** — Data protection and Supabase storage terms.
- **Terms of Service Screen** — User guidelines and app rules.

---

## 🎯 Core Gameplay Mechanics

- **Bent Arrow Puzzle** — Each arrow follows an L-shaped or straight path through the grid. Tap arrows in the correct order to slide them off the board.
- **Solve Order** — Arrows are numbered 0→N and must be cleared in sequence. Tapping the wrong one costs a life.
- **Escape Direction** — Each arrow has an `escape` direction (up/down/left/right). It can only slide out if its path is unblocked by remaining arrows.
- **Lives System** — 3 lives per level. Wrong taps or blocked moves deduct 1 life each. Timer expiry ends the game immediately.
- **Sound Logic** — Wrong-move sound (`Wrong Move-Sound.mp3`) plays on every bad tap. Game-over sound (`Lose-Sound.mp3`) plays **only** when lives reach zero.
- **60-Second Timer** — Complete every level within 60 seconds. The HUD shows a linear depleting progress bar.
- **HUD Layout** — `[Back ←] [Level N] · · · [♥♥♥] [Xs] [Progress Bar]`

### 🔒 Level Locking & Progression

- New accounts unlock **Level 1 only**.
- Levels 2–10 display a lock icon until unlocked.
- Clearing a level triggers an **unlock animation** for the next level.
- Clearing **all 10 levels** permanently unlocks free selection across all levels (**Master Unlock**).
- Progress is dual-stored: SharedPreferences (local/instant) + Supabase `level_progress` table (remote/cross-device).

---

## 🔊 Audio System

| Sound File | Trigger |
|---|---|
| `assets/sounds/Lobby-Music.mp3` | Menu / lobby background music (loops) |
| `assets/sounds/Ingame-Music.mp3` | In-game background music (loops) |
| `assets/sounds/Arrow-Sound.mp3` | Correct arrow tap — slides out |
| `assets/sounds/Wrong Move-Sound.mp3` | Wrong tap / blocked arrow — life deducted |
| `assets/sounds/Win-Sound.mp3` | Level victory |
| `assets/sounds/Lose-Sound.mp3` | Game over (lives = 0 **only**) |

**Settings Modal** (in Settings Screen) provides functional toggles for:
- 🎵 **Background Music** — pause/resume `Lobby-Music` & `Ingame-Music`
- 🔊 **Sound FX** — mute/unmute all SFX (Arrow, Wrong Move, Win, Lose)

---

## 🔐 Authentication Flow

### Sign Up
1. Fill in Username, Password, Confirm Password, and Email.
2. Tap **Send** to receive a 6-digit OTP code via email.
3. Enter the code and tap **Sign Up** to create your account.
4. New accounts start at **Level 1** with zero stats.

### Forgot Password
1. **Step 1** — Enter your registered email address.
2. **Step 2** — Enter the 6-digit OTP code sent to your email.
3. **Step 3** — Set and confirm your new password.
4. Redirects back to Login upon success.

### Account Deletion (Hard Delete)
- Permanently removes the user from **Supabase Auth** (via `delete_user` RPC) AND all public tables (`game_stats`, `level_progress`, `records`, `history`).
- Local SharedPreferences are wiped.
- Re-registering with the same email **starts as a completely fresh user** (Level 1, zero stats).

---

## 📊 Records Screen

Displays accurate stats synced from Supabase:

| Stat | Description |
|---|---|
| Wins | Total levels successfully cleared |
| Losses | Total game-overs (lives = 0 or timer expired) |
| Matches | Total games played (Wins + Losses) |
| Win Rate % | `(Wins / Matches) × 100` |
| Days Active | Calendar days the app has been used |

All stat rows are compact (**max-height: 60dp**) with reduced padding for a professional look.

---

## 📂 Project Structure

```text
lib/
├── levels/
│   ├── level_base.dart          ← Shared painter, mixins, HUD, arrow models
│   ├── game_screen_lvl_1.dart   ← Heart    5×5  13 arrows
│   ├── game_screen_lvl_2.dart   ← Circle   6×6  20 arrows
│   ├── game_screen_lvl_3.dart   ← Triangle 7×7  25 arrows
│   ├── game_screen_lvl_4.dart   ← Square   8×8  30 arrows
│   ├── game_screen_lvl_5.dart   ← Pentagon 9×9  38 arrows
│   ├── game_screen_lvl_6.dart   ← Hexagon  10×10 45 arrows
│   ├── game_screen_lvl_7.dart   ← Heptagon 11×11 55 arrows
│   ├── game_screen_lvl_8.dart   ← Shield   12×12 62 arrows
│   ├── game_screen_lvl_9.dart   ← Nonagon  13×13 70 arrows
│   └── game_screen_lvl_10.dart  ← Cross    14×14 66 arrows
├── models/
│   ├── arrow_model.dart
│   └── game_stats_model.dart
├── providers/
│   ├── auth_provider.dart
│   └── game_provider.dart       ← Added recordLevelLoss()
├── screens/
│   ├── about_screen.dart
│   ├── contact_screen.dart      ← EmailJS → arrowarawsipaglang@gmail.com
│   ├── forgot_password_screen.dart
│   ├── game_screen.dart
│   ├── home_screen.dart
│   ├── level_select_screen.dart ← Lock/unlock animations
│   ├── login_screen.dart
│   ├── policy_screen.dart
│   ├── records_screen.dart      ← Compact 60dp rows, accurate stats
│   ├── settings_screen.dart     ← Audio modal (Music + SFX toggles)
│   ├── signup_screen.dart
│   ├── splash_screen.dart
│   └── terms_screen.dart
├── services/
│   ├── audio_service.dart       ← Fixed music paths, playWrongSound(), playGameOverSound()
│   ├── level_unlock_service.dart ← Added unlockAll() for master unlock
│   └── supabase_service.dart    ← Hard delete via delete_user RPC
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

assets/
├── images/
│   ├── LOGO.png
│   ├── background.png
│   ├── Game Over.png
│   ├── Victory.png
│   ├── heart icon Red.png
│   └── heart icon Black.png
└── sounds/
    ├── Lobby-Music.mp3          ← Menu background music
    ├── Ingame-Music.mp3         ← In-game background music
    ├── Arrow-Sound.mp3          ← Correct tap SFX
    ├── Wrong Move-Sound.mp3     ← Wrong tap / blocked SFX
    ├── Win-Sound.mp3            ← Victory SFX
    └── Lose-Sound.mp3           ← Game-over SFX (lives = 0 only)
```

---

## 🏗️ Architecture & Logic

### Arrow Data Models
- **`ArrowData`** — Legacy straight-line arrows (kept for backward compatibility).
- **`BentArrowData`** — Multi-segment bent arrows. Each arrow holds an ordered list of `BentCell` grid positions and an `escape` direction.

### HUD (Head-Up Display)
```
[← Back]  Level N          ♥ ♥ ♥   XXs
[════════════════ progress bar ════]
```
- Back button exits to Level Select.
- Hearts show remaining lives (red = alive, outline = lost).
- Timer digit turns red when ≤ 10 seconds remain.
- Linear progress bar depletes from full to empty over 60 seconds.

### Collision Detection
On tap, the engine:
1. Checks if the tapped arrow is the **next expected ID** in sequence.
2. Scans the escape path for blocking arrows.
3. **If blocked** → deduct 1 life, play `Wrong Move-Sound.mp3`. If lives = 0 → game over (plays `Lose-Sound.mp3`).
4. **If clear** → trigger slide-out animation, play `Arrow-Sound.mp3`. Zero life penalty.

### Painter Logic (`BentArrowPainter`)
- Draws the arrow shaft as a polyline through cell centers.
- **L-bend rendering**: consecutive cells differing in both row and column get a right-angle corner (horizontal-first).
- No tail dot — single-point fallback removed for a clean look.

### State Management
Provider pattern. `GameProvider` handles grid state and statistics; `AuthProvider` manages Supabase authentication.

### Data Persistence
- **Cloud**: High scores and profiles stored in Supabase (`game_stats`, `level_progress` tables).
- **Local**: SharedPreferences for fast local session handling and offline progress.

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Backend | Supabase (Auth + PostgreSQL) |
| State Management | Provider |
| Animations | flutter_animate |
| Audio | audioplayers |
| Email (Contact) | EmailJS REST API |
| Design | Figma & Canva |

---

## 🗄️ Supabase Schema

### Required Tables

```sql
-- Game statistics
create table game_stats (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  total_wins int default 0,
  total_losses int default 0,
  total_matches int default 0,
  total_days int default 1,
  updated_at timestamptz default now()
);

-- Level progress (unlock state)
create table level_progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  highest_unlocked_level int default 1,
  updated_at timestamptz default now()
);
```

### Required RPC (for hard account delete)

```sql
create or replace function delete_user()
returns void language plpgsql security definer as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$;
```

---

## 👨‍💻 About the Developer

Developed by a student of Urdaneta City University. This project is a practical application of advanced mobile development, emphasizing the philosophy: **Sipag Lang** (Hard Work Only).

---

## 📋 Changelog

### v1.1.0 — Latest
- ✅ All 10 levels rewritten with precise shapes and exact arrow counts per spec
- ✅ HUD redesigned: Back Button · Level Label · Hearts · Timer + Linear Progress Bar
- ✅ Audio fixed: `Wrong Move-Sound.mp3` on bad tap; `Lose-Sound.mp3` only on zero lives
- ✅ Music paths corrected: `Lobby-Music.mp3` (menu) · `Ingame-Music.mp3` (game)
- ✅ Settings screen: Audio modal with Music and SFX toggles
- ✅ Records screen: Compact 60dp rows, accurate Wins/Losses/Matches/Win Rate/Days Active
- ✅ Master Unlock: clearing Level 10 permanently unlocks all levels for free replay
- ✅ Hard delete: account deletion removes user from Supabase Auth + all public tables
- ✅ `recordLevelLoss()` added to GameProvider — losses now accurately tracked
- ✅ Contact screen: EmailJS sends to arrowarawsipaglang@gmail.com with validation

### v1.0.0 — Initial Release
- Core gameplay with 10 levels
- Supabase auth + stats sync
- OTP email verification
