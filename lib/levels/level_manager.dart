// lib/levels/level_manager.dart
// ─────────────────────────────────────────────────────────────────────────────
// Arrow Araw — LevelManager v5  (FINAL RECTIFICATION)
//
// Arrow counts:  L1:10 | L2:20 | L3:30 | L4:40 | L5:50
//                L6:60 | L7:70 | L8:80 | L9:90 | L10:100
//
// Arrow shapes:  STRAIGHT LINES ONLY (Horizontal or Vertical).
//                Lengths cycle 2-3-4-5 grid cells. No L-shapes.
//
// Grid sizes:
//   L1: 8×8   L2:10×10  L3:11×11  L4:12×12  L5:13×13
//   L6:14×14  L7:15×15  L8:16×16  L9:17×17  L10:18×18
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'level_base.dart';

final _colors = <Color>[
  AppColors.arrowRed, AppColors.arrowOrange, AppColors.arrowYellow,
  AppColors.arrowGreen, AppColors.arrowCyan, AppColors.arrowBlue,
  AppColors.arrowPurple, AppColors.arrowPink,
];
Color _c(int i) => _colors[i % _colors.length];

// ── Core generator ────────────────────────────────────────────────────────────
// Produces exactly N non-overlapping straight (H or V) arrows.
// Lengths cycle [2,3,4,5,2,3,2,4,3,5] for visual variety.

List<BentArrowData> _gen(int rows, int cols, int n,
    {int minLen = 2, int maxLen = 5}) {
  final list   = <BentArrowData>[];
  final used   = <(int, int)>{};
  int id       = 0;
  const lens   = [2, 3, 4, 5, 2, 3, 2, 4, 3, 5];
  int lIdx     = 0;

  bool canH(int r, int c, int len) {
    if (c + len > cols) return false;
    for (int i = 0; i < len; i++) { if (used.contains((r, c + i))) return false; }
    return true;
  }

  bool canV(int r, int c, int len) {
    if (r + len > rows) return false;
    for (int i = 0; i < len; i++) { if (used.contains((r + i, c))) return false; }
    return true;
  }

  void markH(int r, int c, int len) {
    for (int i = 0; i < len; i++) { used.add((r, c + i)); }
  }

  void markV(int r, int c, int len) {
    for (int i = 0; i < len; i++) { used.add((r + i, c)); }
  }

  ArrowDir dirH(int r, int c, int len) {
    if (c == 0) return ArrowDir.left;
    if (c + len == cols) return ArrowDir.right;
    return r <= rows ~/ 2 ? ArrowDir.right : ArrowDir.left;
  }

  ArrowDir dirV(int r, int c, int len) {
    if (r == 0) return ArrowDir.up;
    if (r + len == rows) return ArrowDir.down;
    return c <= cols ~/ 2 ? ArrowDir.up : ArrowDir.down;
  }

  // Pass 1 — scan every cell, try H then V
  for (int r = 0; r < rows && list.length < n; r++) {
    for (int c = 0; c < cols && list.length < n; c++) {
      if (used.contains((r, c))) continue;
      final len = lens[lIdx % lens.length].clamp(minLen, maxLen);
      lIdx++;
      if (canH(r, c, len)) {
        list.add(BentArrowData(
          id: id++,
          segs: List.generate(len, (i) => BentCell(r, c + i)),
          escape: dirH(r, c, len), color: _c(id - 1)));
        markH(r, c, len);
      } else if (canV(r, c, len)) {
        list.add(BentArrowData(
          id: id++,
          segs: List.generate(len, (i) => BentCell(r + i, c)),
          escape: dirV(r, c, len), color: _c(id - 1)));
        markV(r, c, len);
      }
    }
  }

  // Pass 2 — fill with len-2 H
  for (int r = 0; r < rows && list.length < n; r++) {
    for (int c = 0; c < cols - 1 && list.length < n; c++) {
      if (canH(r, c, 2)) {
        list.add(BentArrowData(
          id: id++, segs: [BentCell(r, c), BentCell(r, c + 1)],
          escape: dirH(r, c, 2), color: _c(id - 1)));
        markH(r, c, 2);
      }
    }
  }

  // Pass 3 — fill with len-2 V
  for (int r = 0; r < rows - 1 && list.length < n; r++) {
    for (int c = 0; c < cols && list.length < n; c++) {
      if (canV(r, c, 2)) {
        list.add(BentArrowData(
          id: id++, segs: [BentCell(r, c), BentCell(r + 1, c)],
          escape: dirV(r, c, 2), color: _c(id - 1)));
        markV(r, c, 2);
      }
    }
  }

  return list;
}

// ── Level Managers ────────────────────────────────────────────────────────────

class Level1Manager {
  static const int rows = 8,  cols = 8;
  static List<BentArrowData> build() => _gen(rows, cols, 10,  minLen: 2, maxLen: 3);
}

class Level2Manager {
  static const int rows = 10, cols = 10;
  static List<BentArrowData> build() => _gen(rows, cols, 20,  minLen: 2, maxLen: 3);
}

class Level3Manager {
  static const int rows = 11, cols = 11;
  static List<BentArrowData> build() => _gen(rows, cols, 30,  minLen: 2, maxLen: 4);
}

class Level4Manager {
  static const int rows = 12, cols = 12;
  static List<BentArrowData> build() => _gen(rows, cols, 40,  minLen: 2, maxLen: 4);
}

class Level5Manager {
  static const int rows = 13, cols = 13;
  static List<BentArrowData> build() => _gen(rows, cols, 50,  minLen: 2, maxLen: 4);
}

class Level6Manager {
  static const int rows = 14, cols = 14;
  static List<BentArrowData> build() => _gen(rows, cols, 60,  minLen: 2, maxLen: 5);
}

class Level7Manager {
  static const int rows = 15, cols = 15;
  static List<BentArrowData> build() => _gen(rows, cols, 70,  minLen: 2, maxLen: 5);
}

class Level8Manager {
  static const int rows = 16, cols = 16;
  static List<BentArrowData> build() => _gen(rows, cols, 80,  minLen: 2, maxLen: 5);
}

class Level9Manager {
  static const int rows = 17, cols = 17;
  static List<BentArrowData> build() => _gen(rows, cols, 90,  minLen: 2, maxLen: 5);
}

class Level10Manager {
  static const int rows = 18, cols = 18;
  static List<BentArrowData> build() => _gen(rows, cols, 100, minLen: 2, maxLen: 5);
}
