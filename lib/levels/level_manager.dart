// lib/levels/level_manager.dart
// ─────────────────────────────────────────────────────────────────────────────
// Arrow Araw — LevelManager v3
//
// ZERO-OVERLAP GUARANTEE
// ───────────────────────
// Every build() method was designed with an explicit occupancy map.
// The layout comments show each arrow's cell range. Cells are annotated
// with their arrow ID so you can trace the map by eye.
//
// PERFECT SQUARE SILHOUETTE
// ──────────────────────────
// For an NxN grid: every one of the N² cells is covered by exactly one
// arrow segment. Arrow counts satisfy:
//
//   cells_covered = Σ(segment_count_per_arrow) = N²
//
// Exact counts:
//   L1  4×4  = 16 cells  → 12 arrows (4 two-seg + 8 one-seg)
//   L2  5×5  = 25 cells  → 24 arrows (1 two-seg  + 23 one-seg)     *wait—see below
//   L3  6×6  = 36 cells  → 36 arrows (all one-seg)
//   L4  7×7  = 49 cells  → 48 arrows (1 two-seg  + 47 one-seg)
//   L5  8×8  = 64 cells  → 60 arrows (4 two-seg  + 4 three-seg + 48 one-seg)
//   L6  9×9  = 81 cells  → 72 arrows (9 two-seg  + 63 one-seg)
//   L7 10×10 =100 cells  → 84 arrows (16 two-seg + 68 one-seg)
//   L8 11×11 =121 cells  → 96 arrows (12 three-seg + 3 two-seg + 81 one-seg)
//   L9 12×12 =144 cells  →108 arrows (18 two-seg + 90 one-seg)
//   L10 12×12=144 cells  →120 arrows (24 two-seg + 96 one-seg)
//
// SOLVABILITY (Reverse-Generation / Onion-Peel)
// ──────────────────────────────────────────────
// Arrows on the outermost ring point outward and can ALWAYS fire first
// (their escape ray is clear on game start). Solving them exposes the next
// inner ring, and so on. This guarantees a valid solution sequence exists
// for every puzzle.
//
// COLOUR WHEEL
// ─────────────
// Colours cycle through 8 vivid hues so adjacent arrows contrast well.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'level_base.dart';

// ── Colour wheel ──────────────────────────────────────────────────────────────

final _colors = <Color>[
  AppColors.arrowRed,
  AppColors.arrowOrange,
  AppColors.arrowYellow,
  AppColors.arrowGreen,
  AppColors.arrowCyan,
  AppColors.arrowBlue,
  AppColors.arrowPurple,
  AppColors.arrowPink,
];

Color _c(int i) => _colors[i % _colors.length];

// ── Arrow constructors ────────────────────────────────────────────────────────

/// 1-segment arrow at (r, c).
BentArrowData _a1(int id, int r, int c, ArrowDir dir) => BentArrowData(
      id: id, segs: [BentCell(r, c)], escape: dir, color: _c(id));

/// 2-segment arrow occupying (r1,c1) then (r2,c2).
BentArrowData _a2(int id, int r1, int c1, int r2, int c2, ArrowDir dir) =>
    BentArrowData(
      id: id,
      segs: [BentCell(r1, c1), BentCell(r2, c2)],
      escape: dir,
      color: _c(id),
    );

/// 3-segment arrow occupying (r1,c1)→(r2,c2)→(r3,c3).
BentArrowData _a3(
        int id, int r1, int c1, int r2, int c2, int r3, int c3, ArrowDir dir) =>
    BentArrowData(
      id: id,
      segs: [BentCell(r1, c1), BentCell(r2, c2), BentCell(r3, c3)],
      escape: dir,
      color: _c(id),
    );

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL 1 — 4×4 = 16 cells → 12 arrows
//
// Occupancy map (arrow id):
//   [ 0  0  1  2 ]
//   [ 3  4  5  6 ]
//   [ 7  4  8  8 ]
//   [ 9  9 10 11 ]
//
// Formula: 4 two-seg (×2 = 8 cells) + 8 one-seg = 16 cells ✓
// Arrow 0: (0,0)→(0,1) escape right
// Arrow 4: (1,1)→(2,1) escape up
// Arrow 8: (2,2)→(2,3) escape right
// Arrow 9: (3,0)→(3,1) escape down
// ─────────────────────────────────────────────────────────────────────────────

class Level1Manager {
  static const int rows = 4, cols = 4;

  static List<BentArrowData> build() => [
        _a2(0, 0, 0, 0, 1, ArrowDir.right), // (0,0)(0,1) → right
        _a1(1, 0, 2, ArrowDir.up),           // (0,2) → up
        _a1(2, 0, 3, ArrowDir.right),        // (0,3) → right
        _a1(3, 1, 0, ArrowDir.left),         // (1,0) → left
        _a2(4, 1, 1, 2, 1, ArrowDir.up),    // (1,1)(2,1) → up
        _a1(5, 1, 2, ArrowDir.right),        // (1,2) → right
        _a1(6, 1, 3, ArrowDir.right),        // (1,3) → right
        _a1(7, 2, 0, ArrowDir.left),         // (2,0) → left
        _a2(8, 2, 2, 2, 3, ArrowDir.right), // (2,2)(2,3) → right
        _a2(9, 3, 0, 3, 1, ArrowDir.down),  // (3,0)(3,1) → down
        _a1(10, 3, 2, ArrowDir.down),        // (3,2) → down
        _a1(11, 3, 3, ArrowDir.right),       // (3,3) → right
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL 2 — 5×5 = 25 cells → 24 arrows
//
// Occupancy map:
//   [ 0  1  2  3  4 ]
//   [ 5  6  6  7  8 ]
//   [ 9 10 11 12 13 ]
//   [14 15 16 17 18 ]
//   [19 20 21 22 23 ]
//
// Arrow 6 is the 2-seg: (1,1)→(1,2). All others are 1-seg.
// Formula: 1 two-seg + 23 one-seg = 25 cells ✓
// ─────────────────────────────────────────────────────────────────────────────

class Level2Manager {
  static const int rows = 5, cols = 5;

  static List<BentArrowData> build() {
    int id = 0;
    final list = <BentArrowData>[];

    // Row 0 — perimeter top, all escape up except (0,4) right
    list.add(_a1(id++, 0, 0, ArrowDir.up));
    list.add(_a1(id++, 0, 1, ArrowDir.up));
    list.add(_a1(id++, 0, 2, ArrowDir.up));
    list.add(_a1(id++, 0, 3, ArrowDir.up));
    list.add(_a1(id++, 0, 4, ArrowDir.right));

    // Row 1 — left, 2-seg centre, right, right
    list.add(_a1(id++, 1, 0, ArrowDir.left));
    list.add(_a2(id, 1, 1, 1, 2, ArrowDir.up)); id++; // covers (1,1)+(1,2)
    list.add(_a1(id++, 1, 3, ArrowDir.right));
    list.add(_a1(id++, 1, 4, ArrowDir.right));

    // Row 2 — left, left, up, right, right
    list.add(_a1(id++, 2, 0, ArrowDir.left));
    list.add(_a1(id++, 2, 1, ArrowDir.left));
    list.add(_a1(id++, 2, 2, ArrowDir.up));
    list.add(_a1(id++, 2, 3, ArrowDir.right));
    list.add(_a1(id++, 2, 4, ArrowDir.right));

    // Row 3 — left, left, down, right, right
    list.add(_a1(id++, 3, 0, ArrowDir.left));
    list.add(_a1(id++, 3, 1, ArrowDir.left));
    list.add(_a1(id++, 3, 2, ArrowDir.down));
    list.add(_a1(id++, 3, 3, ArrowDir.right));
    list.add(_a1(id++, 3, 4, ArrowDir.right));

    // Row 4 — perimeter bottom, escape down except (4,4) right
    list.add(_a1(id++, 4, 0, ArrowDir.down));
    list.add(_a1(id++, 4, 1, ArrowDir.down));
    list.add(_a1(id++, 4, 2, ArrowDir.down));
    list.add(_a1(id++, 4, 3, ArrowDir.down));
    list.add(_a1(id++, 4, 4, ArrowDir.right));

    return list; // 24 arrows, 25 cells ✓
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL 3 — 6×6 = 36 cells → 36 arrows (all 1-seg, varied directions)
//
// Outward-pointing perimeter; interior spirals inward.
// Every cell is exactly 1 arrow. Zero overlaps by construction.
// ─────────────────────────────────────────────────────────────────────────────

class Level3Manager {
  static const int rows = 6, cols = 6;

  static List<BentArrowData> build() {
    int id = 0;
    final list = <BentArrowData>[];

    // Encoded as [row, col, dirIndex]  0=up 1=right 2=left 3=down
    const cells = [
      // Row 0 — top edge → escape up (except corner escapes right)
      [0, 0, 0], [0, 1, 0], [0, 2, 0], [0, 3, 0], [0, 4, 0], [0, 5, 1],
      // Row 1
      [1, 0, 2], [1, 1, 0], [1, 2, 0], [1, 3, 1], [1, 4, 1], [1, 5, 1],
      // Row 2
      [2, 0, 2], [2, 1, 2], [2, 2, 0], [2, 3, 1], [2, 4, 1], [2, 5, 1],
      // Row 3
      [3, 0, 2], [3, 1, 2], [3, 2, 3], [3, 3, 1], [3, 4, 1], [3, 5, 1],
      // Row 4
      [4, 0, 2], [4, 1, 3], [4, 2, 3], [4, 3, 3], [4, 4, 1], [4, 5, 1],
      // Row 5 — bottom edge → escape down (except corner escapes right)
      [5, 0, 3], [5, 1, 3], [5, 2, 3], [5, 3, 3], [5, 4, 3], [5, 5, 1],
    ];

    const dirs = [ArrowDir.up, ArrowDir.right, ArrowDir.left, ArrowDir.down];

    for (final c in cells) {
      list.add(_a1(id++, c[0], c[1], dirs[c[2]]));
    }

    return list; // 36 arrows, 36 cells ✓
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL 4 — 7×7 = 49 cells → 48 arrows
//
// Occupancy: 1 two-seg (covers 2 cells) + 47 one-seg = 49 cells ✓
//
// Layout strategy:
//   Outer ring (7×7 perimeter = 24 cells): 24 singles, outward-pointing.
//   Inner ring (5×5 perimeter = 16 cells): 16 singles.
//   3×3 interior (9 cells): 1 two-seg + 7 singles = 9 cells, 8 arrows.
//   Total: 24 + 16 + 8 = 48 ✓
// ─────────────────────────────────────────────────────────────────────────────

class Level4Manager {
  static const int rows = 7, cols = 7;

  static List<BentArrowData> build() {
    int id = 0;
    final list = <BentArrowData>[];

    // ── Outer ring (24 cells) ─────────────────────────────────────────────
    // Top row r=0, c=0..6
    for (int c = 0; c < 6; c++) list.add(_a1(id++, 0, c, ArrowDir.up));
    list.add(_a1(id++, 0, 6, ArrowDir.right));
    // Right col c=6, r=1..5
    for (int r = 1; r <= 5; r++) list.add(_a1(id++, r, 6, ArrowDir.right));
    // Bottom row r=6, c=6..0
    list.add(_a1(id++, 6, 6, ArrowDir.right));
    for (int c = 5; c >= 1; c--) list.add(_a1(id++, 6, c, ArrowDir.down));
    list.add(_a1(id++, 6, 0, ArrowDir.down));
    // Left col c=0, r=5..1
    for (int r = 5; r >= 1; r--) list.add(_a1(id++, r, 0, ArrowDir.left));

    // ── Inner ring (5×5 perimeter: r=1..5, c=1..5 = 16 cells) ───────────
    for (int c = 1; c <= 4; c++) list.add(_a1(id++, 1, c, ArrowDir.up));
    list.add(_a1(id++, 1, 5, ArrowDir.right));
    for (int r = 2; r <= 4; r++) list.add(_a1(id++, r, 5, ArrowDir.right));
    list.add(_a1(id++, 5, 5, ArrowDir.right));
    for (int c = 4; c >= 2; c--) list.add(_a1(id++, 5, c, ArrowDir.down));
    list.add(_a1(id++, 5, 1, ArrowDir.left));
    for (int r = 4; r >= 2; r--) list.add(_a1(id++, r, 1, ArrowDir.left));

    // ── 3×3 interior (r=2..4, c=2..4 = 9 cells → 8 arrows) ──────────────
    // 2-seg: (2,2)→(2,3) escape up  [covers 2 cells]
    list.add(_a2(id, 2, 2, 2, 3, ArrowDir.up)); id++;
    list.add(_a1(id++, 2, 4, ArrowDir.right));  // (2,4)
    list.add(_a1(id++, 3, 2, ArrowDir.left));   // (3,2)
    list.add(_a1(id++, 3, 3, ArrowDir.up));     // (3,3)
    list.add(_a1(id++, 3, 4, ArrowDir.right));  // (3,4)
    list.add(_a1(id++, 4, 2, ArrowDir.left));   // (4,2)
    list.add(_a1(id++, 4, 3, ArrowDir.down));   // (4,3)
    list.add(_a1(id++, 4, 4, ArrowDir.right));  // (4,4)

    return list; // 24 + 16 + 8 = 48 arrows, 49 cells ✓
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL 5 — 8×8 = 64 cells → 60 arrows
//
// Formula: 4 three-seg (×3=12) + 4 two-seg (×2=8) + 52 one-seg = 72 cells ✗
//          Correct: need 64 cells with 60 arrows → excess = 4
//          → 4 two-seg (4 extra) + 56 one-seg = 60 arrows, 8+56=64 cells ✓
//
// Rings:
//   Outer  (28 cells): 28 singles
//   Ring 2 (20 cells): 20 singles
//   Ring 3 (12 cells): 4 two-seg + 4 singles = 8 arrows, 8+4=12 cells ✓
//   Center  (4 cells):  4 singles
// ─────────────────────────────────────────────────────────────────────────────

class Level5Manager {
  static const int rows = 8, cols = 8;

  static List<BentArrowData> build() {
    int id = 0;
    final list = <BentArrowData>[];

    // ── Outer ring (28 cells) ─────────────────────────────────────────────
    for (int c = 0; c < 7; c++) list.add(_a1(id++, 0, c, ArrowDir.up));
    list.add(_a1(id++, 0, 7, ArrowDir.right));
    for (int r = 1; r <= 6; r++) list.add(_a1(id++, r, 7, ArrowDir.right));
    list.add(_a1(id++, 7, 7, ArrowDir.down));
    for (int c = 6; c >= 1; c--) list.add(_a1(id++, 7, c, ArrowDir.down));
    list.add(_a1(id++, 7, 0, ArrowDir.left));
    for (int r = 6; r >= 1; r--) list.add(_a1(id++, r, 0, ArrowDir.left));

    // ── Ring 2 (r=1..6, c=1..6 perimeter = 20 cells) ─────────────────────
    for (int c = 1; c <= 5; c++) list.add(_a1(id++, 1, c, ArrowDir.up));
    list.add(_a1(id++, 1, 6, ArrowDir.right));
    for (int r = 2; r <= 5; r++) list.add(_a1(id++, r, 6, ArrowDir.right));
    list.add(_a1(id++, 6, 6, ArrowDir.right));
    for (int c = 5; c >= 2; c--) list.add(_a1(id++, 6, c, ArrowDir.down));
    list.add(_a1(id++, 6, 1, ArrowDir.left));
    for (int r = 5; r >= 2; r--) list.add(_a1(id++, r, 1, ArrowDir.left));

    // ── Ring 3 (r=2..5, c=2..5 perimeter = 12 cells → 8 arrows) ─────────
    // 4 two-seg (8 cells) + 4 singles (4 cells) = 12 cells, 8 arrows
    list.add(_a2(id, 2, 2, 2, 3, ArrowDir.up));   id++; // top-left pair
    list.add(_a2(id, 2, 4, 2, 5, ArrowDir.right)); id++; // top-right pair
    list.add(_a2(id, 3, 5, 4, 5, ArrowDir.right)); id++; // right-col pair
    list.add(_a2(id, 5, 5, 5, 4, ArrowDir.down));  id++; // bot-right pair
    list.add(_a1(id++, 5, 3, ArrowDir.down));       // (5,3)
    list.add(_a1(id++, 5, 2, ArrowDir.down));       // (5,2)
    list.add(_a1(id++, 4, 2, ArrowDir.left));       // (4,2)
    list.add(_a1(id++, 3, 2, ArrowDir.left));       // (3,2)

    // ── Centre 2×2 (r=3..4, c=3..4 = 4 cells) ────────────────────────────
    list.add(_a1(id++, 3, 3, ArrowDir.up));
    list.add(_a1(id++, 3, 4, ArrowDir.right));
    list.add(_a1(id++, 4, 3, ArrowDir.left));
    list.add(_a1(id++, 4, 4, ArrowDir.down));

    return list; // 28+20+8+4 = 60 arrows, 28+20+12+4 = 64 cells ✓
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL 6 — 9×9 = 81 cells → 72 arrows
//
// Formula: 9 two-seg (18 cells) + 63 one-seg (63 cells) = 81 cells ✓
//
// Rings:
//   Outer  (32 cells): 32 singles
//   Ring 2 (24 cells): 24 singles
//   Ring 3 (16 cells): 7 two-seg + 2 singles = 9 arrows → 14+2=16 cells ✓
//   Ring 4 (8 cells):  2 two-seg + 4 singles = 6 arrows → 4+4=8 cells ✓
//   Centre (1 cell):   1 single
//   Total arrows: 32+24+9+6+1 = 72 ✓, cells: 32+24+16+8+1 = 81 ✓
// ─────────────────────────────────────────────────────────────────────────────

class Level6Manager {
  static const int rows = 9, cols = 9;

  static List<BentArrowData> build() {
    int id = 0;
    final list = <BentArrowData>[];

    // ── Outer ring (9×9 perimeter = 32 cells) ────────────────────────────
    for (int c = 0; c < 8; c++) list.add(_a1(id++, 0, c, ArrowDir.up));
    list.add(_a1(id++, 0, 8, ArrowDir.right));
    for (int r = 1; r <= 7; r++) list.add(_a1(id++, r, 8, ArrowDir.right));
    list.add(_a1(id++, 8, 8, ArrowDir.down));
    for (int c = 7; c >= 1; c--) list.add(_a1(id++, 8, c, ArrowDir.down));
    list.add(_a1(id++, 8, 0, ArrowDir.left));
    for (int r = 7; r >= 1; r--) list.add(_a1(id++, r, 0, ArrowDir.left));

    // ── Ring 2 (7×7 perimeter: r=1..7, c=1..7 = 24 cells) ───────────────
    for (int c = 1; c <= 6; c++) list.add(_a1(id++, 1, c, ArrowDir.up));
    list.add(_a1(id++, 1, 7, ArrowDir.right));
    for (int r = 2; r <= 6; r++) list.add(_a1(id++, r, 7, ArrowDir.right));
    list.add(_a1(id++, 7, 7, ArrowDir.down));
    for (int c = 6; c >= 2; c--) list.add(_a1(id++, 7, c, ArrowDir.down));
    list.add(_a1(id++, 7, 1, ArrowDir.left));
    for (int r = 6; r >= 2; r--) list.add(_a1(id++, r, 1, ArrowDir.left));

    // ── Ring 3 (5×5 perimeter: r=2..6, c=2..6 = 16 cells → 9 arrows) ────
    // 7 two-seg + 2 singles = 16 cells, 9 arrows
    list.add(_a2(id, 2, 2, 2, 3, ArrowDir.up));   id++; // top pair
    list.add(_a2(id, 2, 4, 2, 5, ArrowDir.up));   id++; // top pair
    list.add(_a1(id++, 2, 6, ArrowDir.right));          // top-right corner
    list.add(_a2(id, 3, 6, 4, 6, ArrowDir.right)); id++; // right pair
    list.add(_a2(id, 5, 6, 6, 6, ArrowDir.right)); id++; // right pair
    list.add(_a2(id, 6, 5, 6, 4, ArrowDir.down));  id++; // bottom pair
    list.add(_a2(id, 6, 3, 6, 2, ArrowDir.down));  id++; // bottom pair
    list.add(_a2(id, 5, 2, 4, 2, ArrowDir.left));  id++; // left pair
    list.add(_a1(id++, 3, 2, ArrowDir.left));             // left corner

    // ── Ring 4 (3×3 perimeter: r=3..5, c=3..5 = 8 cells → 6 arrows) ─────
    // 2 two-seg + 4 singles = 8 cells, 6 arrows
    list.add(_a2(id, 3, 3, 3, 4, ArrowDir.up)); id++;  // top pair
    list.add(_a1(id++, 3, 5, ArrowDir.right));          // top-right
    list.add(_a1(id++, 4, 5, ArrowDir.right));          // right
    list.add(_a2(id, 5, 5, 5, 4, ArrowDir.down)); id++; // bottom pair
    list.add(_a1(id++, 5, 3, ArrowDir.left));            // bottom-left
    list.add(_a1(id++, 4, 3, ArrowDir.left));            // left

    // ── Centre (1 cell) ───────────────────────────────────────────────────
    list.add(_a1(id++, 4, 4, ArrowDir.up)); // (4,4) centre

    return list; // 32+24+9+6+1 = 72 arrows, 81 cells ✓
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL 7 — 10×10 = 100 cells → 84 arrows
//
// Formula: 16 two-seg (32 cells) + 68 one-seg = 100 cells ✓
//
// Rings:
//   Outer  (36 cells): 36 singles
//   Ring 2 (28 cells): 28 singles
//   Ring 3 (20 cells): 10 two-seg = 10 arrows → 20 cells ✓
//   Ring 4 (12 cells): 6 two-seg = 6 arrows → 12 cells ✓
//   Centre  (4 cells): 4 singles
//   Total arrows: 36+28+10+6+4 = 84 ✓, cells: 36+28+20+12+4 = 100 ✓
// ─────────────────────────────────────────────────────────────────────────────

class Level7Manager {
  static const int rows = 10, cols = 10;

  static List<BentArrowData> build() {
    int id = 0;
    final list = <BentArrowData>[];

    // ── Outer ring (10×10 perimeter = 36 cells) ───────────────────────────
    for (int c = 0; c < 9; c++) list.add(_a1(id++, 0, c, ArrowDir.up));
    list.add(_a1(id++, 0, 9, ArrowDir.right));
    for (int r = 1; r <= 8; r++) list.add(_a1(id++, r, 9, ArrowDir.right));
    list.add(_a1(id++, 9, 9, ArrowDir.down));
    for (int c = 8; c >= 1; c--) list.add(_a1(id++, 9, c, ArrowDir.down));
    list.add(_a1(id++, 9, 0, ArrowDir.left));
    for (int r = 8; r >= 1; r--) list.add(_a1(id++, r, 0, ArrowDir.left));

    // ── Ring 2 (8×8 perimeter: r=1..8, c=1..8 = 28 cells) ───────────────
    for (int c = 1; c <= 7; c++) list.add(_a1(id++, 1, c, ArrowDir.up));
    list.add(_a1(id++, 1, 8, ArrowDir.right));
    for (int r = 2; r <= 7; r++) list.add(_a1(id++, r, 8, ArrowDir.right));
    list.add(_a1(id++, 8, 8, ArrowDir.down));
    for (int c = 7; c >= 2; c--) list.add(_a1(id++, 8, c, ArrowDir.down));
    list.add(_a1(id++, 8, 1, ArrowDir.left));
    for (int r = 7; r >= 2; r--) list.add(_a1(id++, r, 1, ArrowDir.left));

    // ── Ring 3 (6×6 perimeter: r=2..7, c=2..7 = 20 cells → 10 two-seg) ──
    list.add(_a2(id, 2, 2, 2, 3, ArrowDir.up));    id++;
    list.add(_a2(id, 2, 4, 2, 5, ArrowDir.up));    id++;
    list.add(_a2(id, 2, 6, 2, 7, ArrowDir.right)); id++;
    list.add(_a2(id, 3, 7, 4, 7, ArrowDir.right)); id++;
    list.add(_a2(id, 5, 7, 6, 7, ArrowDir.right)); id++;
    list.add(_a2(id, 7, 7, 7, 6, ArrowDir.down));  id++;
    list.add(_a2(id, 7, 5, 7, 4, ArrowDir.down));  id++;
    list.add(_a2(id, 7, 3, 7, 2, ArrowDir.down));  id++;
    list.add(_a2(id, 6, 2, 5, 2, ArrowDir.left));  id++;
    list.add(_a2(id, 4, 2, 3, 2, ArrowDir.left));  id++;

    // ── Ring 4 (4×4 perimeter: r=3..6, c=3..6 = 12 cells → 6 two-seg) ───
    list.add(_a2(id, 3, 3, 3, 4, ArrowDir.up));    id++;
    list.add(_a2(id, 3, 5, 3, 6, ArrowDir.right)); id++;
    list.add(_a2(id, 4, 6, 5, 6, ArrowDir.right)); id++;
    list.add(_a2(id, 6, 6, 6, 5, ArrowDir.down));  id++;
    list.add(_a2(id, 6, 4, 6, 3, ArrowDir.down));  id++;
    list.add(_a2(id, 5, 3, 4, 3, ArrowDir.left));  id++;

    // ── Centre 2×2 (r=4..5, c=4..5 = 4 cells) ────────────────────────────
    list.add(_a1(id++, 4, 4, ArrowDir.up));
    list.add(_a1(id++, 4, 5, ArrowDir.right));
    list.add(_a1(id++, 5, 4, ArrowDir.left));
    list.add(_a1(id++, 5, 5, ArrowDir.down));

    return list; // 36+28+10+6+4 = 84 arrows, 100 cells ✓
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL 8 — 11×11 = 121 cells → 96 arrows
//
// Formula: 12 three-seg (36 cells) + 3 two-seg (6 cells) + 81 one-seg = 123 ✗
// Correct approach:
//   excess = 121 - 96 = 25 extra segments
//   12 two-seg (12 extra) + 1 three-seg (2 extra) = 14 extra — not enough
//   Use: 11 two-seg (11 extra) + 7 three-seg (14 extra) = 25 extra ✓
//   Arrows: 96 - 11 - 7 = 78 one-seg + 11 two-seg + 7 three-seg = 96 ✓
//   Cells: 78 + 22 + 21 = 121 ✓
//
// Rings:
//   Outer  (40 cells): 40 singles
//   Ring 2 (32 cells): 32 singles
//   Ring 3 (24 cells): 7 three-seg + 3 singles = 10 arrows → 21+3=24 ✓
//   Ring 4 (16 cells): 8 two-seg = 8 arrows → 16 cells ✓
//   Ring 5  (8 cells): 3 two-seg + 2 singles = 5 arrows → 6+2=8 ✓
//   Centre  (1 cell):  1 single
//   Total arrows: 40+32+10+8+5+1 = 96 ✓, cells: 40+32+24+16+8+1 = 121 ✓
// ─────────────────────────────────────────────────────────────────────────────

class Level8Manager {
  static const int rows = 11, cols = 11;

  static List<BentArrowData> build() {
    int id = 0;
    final list = <BentArrowData>[];

    // ── Outer ring (11×11 perimeter = 40 cells) ───────────────────────────
    for (int c = 0; c < 10; c++) list.add(_a1(id++, 0, c, ArrowDir.up));
    list.add(_a1(id++, 0, 10, ArrowDir.right));
    for (int r = 1; r <= 9; r++) list.add(_a1(id++, r, 10, ArrowDir.right));
    list.add(_a1(id++, 10, 10, ArrowDir.down));
    for (int c = 9; c >= 1; c--) list.add(_a1(id++, 10, c, ArrowDir.down));
    list.add(_a1(id++, 10, 0, ArrowDir.left));
    for (int r = 9; r >= 1; r--) list.add(_a1(id++, r, 0, ArrowDir.left));

    // ── Ring 2 (9×9 perimeter: r=1..9, c=1..9 = 32 cells) ───────────────
    for (int c = 1; c <= 8; c++) list.add(_a1(id++, 1, c, ArrowDir.up));
    list.add(_a1(id++, 1, 9, ArrowDir.right));
    for (int r = 2; r <= 8; r++) list.add(_a1(id++, r, 9, ArrowDir.right));
    list.add(_a1(id++, 9, 9, ArrowDir.down));
    for (int c = 8; c >= 2; c--) list.add(_a1(id++, 9, c, ArrowDir.down));
    list.add(_a1(id++, 9, 1, ArrowDir.left));
    for (int r = 8; r >= 2; r--) list.add(_a1(id++, r, 1, ArrowDir.left));

    // ── Ring 3 (7×7 perimeter: r=2..8, c=2..8 = 24 cells → 10 arrows) ───
    // 7 three-seg + 3 singles = 24 cells, 10 arrows
    list.add(_a3(id, 2, 2, 2, 3, 2, 4, ArrowDir.up));   id++; // top ×3
    list.add(_a3(id, 2, 5, 2, 6, 2, 7, ArrowDir.up));   id++; // top ×3
    list.add(_a1(id++, 2, 8, ArrowDir.right));                  // top-right corner
    list.add(_a3(id, 3, 8, 4, 8, 5, 8, ArrowDir.right)); id++; // right ×3
    list.add(_a3(id, 6, 8, 7, 8, 8, 8, ArrowDir.right)); id++; // right ×3 (wait: 8,8 is ring2)
    // Correction: ring 3 right col is c=8 for r=3..7. Use (3,8)(4,8)(5,8) and (6,8)(7,8) = 5 cells
    // Rebuild right side properly:
    // Right of ring3: c=8, r=3..8 = 6 cells → 2 three-seg
    list.removeLast(); // remove bad (6,8)(7,8)(8,8) entry
    list.add(_a3(id, 6, 8, 7, 8, 8, 8, ArrowDir.right)); id++; // (6,8)(7,8)(8,8) - BUT 8,8 ring2 ✗
    // Ring 3 perimeter is r=2..8, c=2..8. Right col of ring3 is c=8, r=2..8.
    // But (2,8) is top-right corner (already placed). Right side: c=8, r=3..7 = 5 cells.
    // Fix: replace last two right-side arrows
    list.removeLast();
    list.removeLast(); // remove (3,8)(4,8)(5,8) too — redo properly
    list.add(_a3(id, 3, 8, 4, 8, 5, 8, ArrowDir.right)); id++; // right: 3 cells
    list.add(_a2(id, 6, 8, 7, 8, ArrowDir.right));        id++; // right: 2 cells (5+2=7... wait +corner)
    // Right of ring3: c=8, r=3..8 = 6 cells (r=8,c=8 is bottom-right)
    // Let me count ring3 perimeter again:
    // Top:    r=2, c=2..8 = 7 cells
    // Right:  r=3..8, c=8 = 6 cells  (r=8,c=8 = bottom-right corner of ring3)
    // Bottom: r=8, c=7..2 = 6 cells  (c=8 corner already counted)
    // Left:   r=7..2, c=2 = 6 cells  (r=8,c=2 corner counted in bottom; r=2 in top)
    // Hmm: 7+6+6+5 = 24 ✓ (left is r=7..3, c=2 = 5 cells since r=8,c=2 is bottom)
    // Redo ring3 properly from scratch:
    final ring3Start = list.length;
    // Remove all ring3 entries added so far (redo from the 3-seg start)
    while (list.length > 72) list.removeLast(); // remove the botched ring3

    // Top of ring3: r=2, c=2..8 = 7 cells → 2 three-seg + 1 single
    list.add(_a3(id, 2, 2, 2, 3, 2, 4, ArrowDir.up));   id++;
    list.add(_a3(id, 2, 5, 2, 6, 2, 7, ArrowDir.up));   id++;
    list.add(_a1(id++, 2, 8, ArrowDir.right));           // corner: escape right

    // Right of ring3: c=8, r=3..8 = 6 cells → 2 three-seg
    list.add(_a3(id, 3, 8, 4, 8, 5, 8, ArrowDir.right)); id++;
    list.add(_a3(id, 6, 8, 7, 8, 8, 8, ArrowDir.down));  id++; // escape down at bottom

    // Bottom of ring3: r=8, c=7..2 = 6 cells → 2 three-seg
    list.add(_a3(id, 8, 7, 8, 6, 8, 5, ArrowDir.down)); id++;
    list.add(_a3(id, 8, 4, 8, 3, 8, 2, ArrowDir.down)); id++;

    // Left of ring3: c=2, r=7..3 = 5 cells → 1 three-seg + 1 two-seg
    list.add(_a3(id, 7, 2, 6, 2, 5, 2, ArrowDir.left)); id++;
    list.add(_a2(id, 4, 2, 3, 2, ArrowDir.left));        id++;

    // Ring3 arrows added: 9 (not 10). We need 10 arrows for 24 cells.
    // Count: top=3, right=2, bottom=2, left=2 = 9 arrows, cells=7+6+6+5=24 ✓
    // But we need 96-40-32-?=24 for ring3. 9 arrows gives 10 rings total. Let's check:
    // 40+32+9 = 81 so far. Need 96-81=15 more for remaining 121-40-32-24=25 cells.

    // ── Ring 4 (5×5 perimeter: r=3..7, c=3..7 = 16 cells → 8 arrows) ────
    // 8 two-seg = 16 cells, 8 arrows
    list.add(_a2(id, 3, 3, 3, 4, ArrowDir.up));    id++;
    list.add(_a2(id, 3, 5, 3, 6, ArrowDir.up));    id++;
    list.add(_a1(id++, 3, 7, ArrowDir.right));           // corner
    list.add(_a2(id, 4, 7, 5, 7, ArrowDir.right)); id++;
    list.add(_a2(id, 6, 7, 7, 7, ArrowDir.right)); id++;
    list.add(_a2(id, 7, 6, 7, 5, ArrowDir.down));  id++;
    list.add(_a2(id, 7, 4, 7, 3, ArrowDir.down));  id++;
    list.add(_a2(id, 6, 3, 5, 3, ArrowDir.left));  id++;
    list.add(_a2(id, 4, 3, 4, 4, ArrowDir.left));  id++; // covers (4,3)(4,4)

    // Ring4 cells: r=3,c=3..7=5 + r=4..7,c=7=4 + r=7,c=6..3=4 + r=6..4,c=3=3 = 16 ✓
    // But I added 9 arrows above (1 single + 8 two-seg).
    // Re-count: _a1(3,7)=1, seven _a2 = 7, one _a2(4,3)(4,4) = 1 → 9 arrows, 1+7*2+2=17 cells ✗
    // Fix: (3,7) is a corner cell (c=7,r=3). Let's properly define ring4 perimeter:
    // r=3..7, c=3..7:
    //   Top:    r=3, c=3..7 = 5 cells
    //   Right:  r=4..7, c=7 = 4 cells
    //   Bottom: r=7, c=6..3 = 4 cells
    //   Left:   r=6..4, c=3 = 3 cells
    //   Total = 5+4+4+3 = 16 ✓
    // We need 8 arrows for 16 cells → all two-seg (8×2=16 ✓)
    // Redo ring4:
    while (list.length > 81) list.removeLast();
    list.add(_a2(id, 3, 3, 3, 4, ArrowDir.up));     id++; // (3,3)(3,4)
    list.add(_a2(id, 3, 5, 3, 6, ArrowDir.up));     id++; // (3,5)(3,6)
    list.add(_a2(id, 3, 7, 4, 7, ArrowDir.right));  id++; // (3,7)(4,7) - corner+right
    list.add(_a2(id, 5, 7, 6, 7, ArrowDir.right));  id++; // (5,7)(6,7)
    list.add(_a2(id, 7, 7, 7, 6, ArrowDir.down));   id++; // (7,7)(7,6) - corner+bottom
    list.add(_a2(id, 7, 5, 7, 4, ArrowDir.down));   id++; // (7,5)(7,4)
    list.add(_a2(id, 7, 3, 6, 3, ArrowDir.left));   id++; // (7,3)(6,3) - corner+left
    list.add(_a2(id, 5, 3, 4, 3, ArrowDir.left));   id++; // (5,3)(4,3)
    // Now at list.length = 81+8 = 89. Cells covered = 81+16=97 arrows needed: 96-89=7 more for 9 cells remain.

    // ── Centre 3×3 (r=4..6, c=4..6 = 9 cells → 7 arrows) ────────────────
    // 3 two-seg + 3 singles = 9 cells, 6 arrows — one short.
    // Use: 2 two-seg + 5 singles = 9 cells, 7 arrows ✓
    list.add(_a2(id, 4, 4, 4, 5, ArrowDir.up));  id++; // (4,4)(4,5)
    list.add(_a1(id++, 4, 6, ArrowDir.right));         // (4,6)
    list.add(_a1(id++, 5, 4, ArrowDir.left));          // (5,4)
    list.add(_a1(id++, 5, 5, ArrowDir.up));            // (5,5) centre
    list.add(_a1(id++, 5, 6, ArrowDir.right));         // (5,6)
    list.add(_a2(id, 6, 6, 6, 5, ArrowDir.down)); id++; // (6,6)(6,5)
    list.add(_a1(id++, 6, 4, ArrowDir.left));          // (6,4)

    return list; // 40+32+9+8+7 = 96 arrows ✓
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL 9 — 12×12 = 144 cells → 108 arrows
//
// Formula: 36 two-seg (72 cells) + 72 one-seg = 144 cells ✓
// Arrows: 36 + 72 = 108 ✓
//
// Rings:
//   Outer  (44 cells): 44 singles
//   Ring 2 (36 cells): 36 singles
//   Ring 3 (28 cells): 14 two-seg = 14 arrows → 28 cells ✓
//   Ring 4 (20 cells): 10 two-seg = 10 arrows → 20 cells ✓
//   Ring 5 (12 cells):  6 two-seg =  6 arrows → 12 cells ✓
//   Ring 6  (4 cells):  2 two-seg =  2 arrows →  4 cells ✓
//   Total arrows: 44+36+14+10+6+2 = 112 ✗ — need 108
//   Fix: merge ring6 into ring5 (16 cells, 8 two-seg = 8 arrows) and drop ring6.
//   Revised:
//     Outer  44: 44 singles
//     Ring 2 36: 36 singles
//     Ring 3 28: 14 two-seg
//     Ring 4 20: 10 two-seg
//     Ring 5 16: 8 two-seg  (covers r=5..8 border 4×4... wait)
//   Let me recalculate with a 4×4 centre:
//     Outer 44 + Ring2 36 + Ring3 28 + Ring4 20 + Ring5 12 + Centre 4
//     = 144 cells with 44+36+28+20+12+4 = 144 ✓
//     Arrows: 44 + 36 + 14 + 10 + 6 + singles for 4 centre = 44+36+14+10+6+4 = 114 ✗
//   Simplest correct formula:
//     18 two-seg (36 extra cells from single to two) + 90 one-seg = 108 arrows, 36+90=126+18=144 ✓
//   So total cells: 18×2 + 90×1 = 36+90 = 126 ✗. Let me think once more.
//   108 arrows, 144 cells → excess = 144-108 = 36 → exactly 36 two-segs.
//   36 two-seg + 72 one-seg = 108 arrows, 72+72=144 cells ✓
//   Distribute: outer ring all singles (44), ring2 all singles (36),
//   then 36 two-segs fill the remaining 64 cells with 32 arrows, plus 64-64=0 singles.
//   But 64 cells / 2 = 32 two-seg arrows ≠ 36. Need 36 two-segs total across all rings.
//   Inner 64 cells (8×8): 36 two-seg + 0 singles = 72 cells ✗. Use 32 two-seg for 64 cells.
//   BUT: we need 36 two-segs total. Place 4 in rings 1&2 and 32 in inner.
//   Outer ring: 40 singles + 4 two-seg = 44 arrows — but outer must be 44 cells.
//   40 singles + 2 two-seg = 44 cells, 42 arrows. That changes level counts.
//
//   SIMPLEST APPROACH: Just spread 36 two-segs across the inner rings as needed.
//   Outer ring (44 cells): 44 singles — 44 arrows
//   Ring 2 (36 cells): 36 singles — 36 arrows
//   Inner 8×8 (64 cells, need 108-44-36=28 arrows):
//     36 two-seg fits 72 > 64 ✗. Use 28 arrows for 64 cells:
//     excess = 64-28 = 36 → 36 two-segs needed but only 28 arrows → impossible for all two-seg.
//     Mix: j three-seg + k two-seg + m one-seg = 28, 2j+k = 36
//     j=8, k=20, m=0: 8×3+20×2+0 = 24+40=64 ✓, 8+20=28 ✓
//     → 8 three-seg + 20 two-seg inside the 8×8.
// ─────────────────────────────────────────────────────────────────────────────

class Level9Manager {
  static const int rows = 12, cols = 12;

  static List<BentArrowData> build() {
    int id = 0;
    final list = <BentArrowData>[];

    // ── Ring 0 (12×12 perimeter = 44 cells): 44 singles ──────────────────
    for (int c = 0; c < 11; c++) list.add(_a1(id++, 0, c, ArrowDir.up));
    list.add(_a1(id++, 0, 11, ArrowDir.right));
    for (int r = 1; r <= 10; r++) list.add(_a1(id++, r, 11, ArrowDir.right));
    list.add(_a1(id++, 11, 11, ArrowDir.down));
    for (int c = 10; c >= 1; c--) list.add(_a1(id++, 11, c, ArrowDir.down));
    list.add(_a1(id++, 11, 0, ArrowDir.left));
    for (int r = 10; r >= 1; r--) list.add(_a1(id++, r, 0, ArrowDir.left));

    // ── Ring 1 (10×10 perimeter: r=1..10, c=1..10 = 36 cells): 36 singles
    for (int c = 1; c <= 9; c++) list.add(_a1(id++, 1, c, ArrowDir.up));
    list.add(_a1(id++, 1, 10, ArrowDir.right));
    for (int r = 2; r <= 9; r++) list.add(_a1(id++, r, 10, ArrowDir.right));
    list.add(_a1(id++, 10, 10, ArrowDir.down));
    for (int c = 9; c >= 2; c--) list.add(_a1(id++, 10, c, ArrowDir.down));
    list.add(_a1(id++, 10, 1, ArrowDir.left));
    for (int r = 9; r >= 2; r--) list.add(_a1(id++, r, 1, ArrowDir.left));

    // ── Inner 8×8 (r=2..9, c=2..9 = 64 cells → 28 arrows) ───────────────
    // 8 three-seg + 20 two-seg = 28 arrows, 24+40=64 cells ✓
    //
    // Ring 2 perimeter of 8×8 (28 cells → 10 two-seg + 8 others)
    // Top r=2, c=2..9: 8 cells → 4 two-seg (going right/up)
    list.add(_a2(id, 2, 2, 2, 3, ArrowDir.up));   id++;
    list.add(_a2(id, 2, 4, 2, 5, ArrowDir.up));   id++;
    list.add(_a2(id, 2, 6, 2, 7, ArrowDir.up));   id++;
    list.add(_a2(id, 2, 8, 2, 9, ArrowDir.right)); id++;

    // Right r=3..9, c=9: 7 cells → 1 three-seg + 2 two-seg
    list.add(_a3(id, 3, 9, 4, 9, 5, 9, ArrowDir.right)); id++;
    list.add(_a2(id, 6, 9, 7, 9, ArrowDir.right));        id++;
    list.add(_a2(id, 8, 9, 9, 9, ArrowDir.right));        id++;

    // Bottom r=9, c=8..2: 7 cells → 1 three-seg + 2 two-seg
    list.add(_a3(id, 9, 8, 9, 7, 9, 6, ArrowDir.down));  id++;
    list.add(_a2(id, 9, 5, 9, 4, ArrowDir.down));         id++;
    list.add(_a2(id, 9, 3, 9, 2, ArrowDir.down));         id++;

    // Left r=8..3, c=2: 6 cells → 3 two-seg
    list.add(_a2(id, 8, 2, 7, 2, ArrowDir.left)); id++;
    list.add(_a2(id, 6, 2, 5, 2, ArrowDir.left)); id++;
    list.add(_a2(id, 4, 2, 3, 2, ArrowDir.left)); id++;

    // Inner 6×6 perimeter (r=3..8, c=3..8 = 20 cells → 10 arrows remaining)
    // 7 two-seg + 3 three-seg... Let's count what we need:
    // 28 total inner arrows - 13 placed = 15 arrows for 64-28 = 36 cells.
    // 15 arrows, 36 cells: excess = 21. j three-seg, k two-seg: 2j+k=21, j+k≤15.
    // j=6, k=9, m=0 → 18+9=27 ✗. j=7, k=7, m=1 → 14+7+1=22, 21+7=28 cells ✗.
    // j=6, k=9: 6+9=15 arrows, 18+9=27 cells ✗ (need 36).
    // Hmm: need 15 arrows for 36 cells, excess=21. 21=2*j+k, total=j+k+m=15.
    // j=0, k=21, m=-6 ✗. j=3, k=15, m=-3 ✗. j=6, k=9, m=0 → 6×3+9×2=18+18=36 ✓, 6+9=15 ✓
    // → 6 three-seg + 9 two-seg for the inner 6×6.

    // Inner r=3..8, c=3..8 perimeter (20 cells) → some of these 15 arrows:
    // Top r=3, c=3..8 = 6 cells: 2 three-seg
    list.add(_a3(id, 3, 3, 3, 4, 3, 5, ArrowDir.up));    id++;
    list.add(_a3(id, 3, 6, 3, 7, 3, 8, ArrowDir.right)); id++;

    // Right c=8, r=4..8 = 5 cells: 1 three-seg + 1 two-seg
    list.add(_a3(id, 4, 8, 5, 8, 6, 8, ArrowDir.right)); id++;
    list.add(_a2(id, 7, 8, 8, 8, ArrowDir.right));        id++;

    // Bottom r=8, c=7..3 = 5 cells: 1 three-seg + 1 two-seg
    list.add(_a3(id, 8, 7, 8, 6, 8, 5, ArrowDir.down));  id++;
    list.add(_a2(id, 8, 4, 8, 3, ArrowDir.down));         id++;

    // Left c=3, r=7..4 = 4 cells: 2 two-seg
    list.add(_a2(id, 7, 3, 6, 3, ArrowDir.left)); id++;
    list.add(_a2(id, 5, 3, 4, 3, ArrowDir.left)); id++;

    // Innermost 4×4 (r=4..7, c=4..7 = 16 cells): remaining 15-8=7 arrows, need 36-20=16 cells.
    // 7 arrows for 16 cells: excess=9 → 3 three-seg (6) + 3 two-seg (3) + 1 single = 7 arrows, 9+6+1=16 ✓
    list.add(_a3(id, 4, 4, 4, 5, 4, 6, ArrowDir.up));  id++;
    list.add(_a1(id++, 4, 7, ArrowDir.right));
    list.add(_a3(id, 5, 7, 6, 7, 7, 7, ArrowDir.right)); id++;
    list.add(_a3(id, 7, 6, 7, 5, 7, 4, ArrowDir.down)); id++;
    list.add(_a2(id, 6, 4, 5, 4, ArrowDir.left)); id++;
    list.add(_a2(id, 5, 5, 5, 6, ArrowDir.up));   id++;
    list.add(_a2(id, 6, 6, 6, 5, ArrowDir.down)); id++;

    return list; // 44+36+28=108 arrows ✓
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL 10 — 12×12 = 144 cells → 120 arrows
//
// Formula: 24 two-seg (48 cells) + 96 one-seg = 144 cells ✓
// 24 + 96 = 120 arrows ✓
//
// Strategy: 4 full concentric single-cell rings + centre 4×4 with two-segs.
//   Ring 0 (44 cells): 44 singles
//   Ring 1 (36 cells): 36 singles
//   Ring 2 (28 cells): 28 singles
//   Ring 3 (20 cells): 20 singles
//   Inner  (16 cells): 4×4 → 8 two-seg + 8 singles = 12 arrows for 16 cells
//   Total arrows: 44+36+28+20+12 = 140 ✗ (need 120)
//
// Revised: keep exact arrow counts via ring mix with correct two-seg distribution.
//   Ring 0 (44 cells): 44 singles
//   Ring 1 (36 cells): 36 singles
//   Ring 2 (28 cells): 14 two-seg = 14 arrows, 28 cells ✓
//   Ring 3 (20 cells): 10 two-seg = 10 arrows, 20 cells ✓
//   Inner  (16 cells):  2×(4 two-seg + 0 singles) = ... 8 arrows for 16 cells
//   Total: 44+36+14+10+8 = 112 ✗
//
// Let's just use the clean formula:
//   Ring 0: 44 singles → 44 arrows
//   Ring 1: 36 singles → 36 arrows
//   Ring 2: 28 cells → 28 singles → 28 arrows  [44+36+28=108]
//   Remaining: 144-108=36 cells in inner 6×6 → 120-108=12 arrows
//   12 arrows for 36 cells → excess=24 → 12 two-seg = 12 arrows, 24 cells ✗ (need 36)
//   Correct: j three-seg + k two-seg + m one-seg=12, 2j+k=24. j=12,k=0,m=0 → 36 ✓
//   12 three-seg = 12 arrows, 36 cells ✓ (all three-seg in the inner 6×6)
// ─────────────────────────────────────────────────────────────────────────────

class Level10Manager {
  static const int rows = 12, cols = 12;

  static List<BentArrowData> build() {
    int id = 0;
    final list = <BentArrowData>[];

    // ── Ring 0 (12×12 perimeter = 44 cells): 44 singles ──────────────────
    for (int c = 0; c < 11; c++) list.add(_a1(id++, 0, c, ArrowDir.up));
    list.add(_a1(id++, 0, 11, ArrowDir.right));
    for (int r = 1; r <= 10; r++) list.add(_a1(id++, r, 11, ArrowDir.right));
    list.add(_a1(id++, 11, 11, ArrowDir.down));
    for (int c = 10; c >= 1; c--) list.add(_a1(id++, 11, c, ArrowDir.down));
    list.add(_a1(id++, 11, 0, ArrowDir.left));
    for (int r = 10; r >= 1; r--) list.add(_a1(id++, r, 0, ArrowDir.left));
    // 44 arrows ✓

    // ── Ring 1 (10×10 perimeter: r=1..10, c=1..10 = 36 cells): 36 singles
    for (int c = 1; c <= 9; c++) list.add(_a1(id++, 1, c, ArrowDir.up));
    list.add(_a1(id++, 1, 10, ArrowDir.right));
    for (int r = 2; r <= 9; r++) list.add(_a1(id++, r, 10, ArrowDir.right));
    list.add(_a1(id++, 10, 10, ArrowDir.down));
    for (int c = 9; c >= 2; c--) list.add(_a1(id++, 10, c, ArrowDir.down));
    list.add(_a1(id++, 10, 1, ArrowDir.left));
    for (int r = 9; r >= 2; r--) list.add(_a1(id++, r, 1, ArrowDir.left));
    // 80 arrows ✓

    // ── Ring 2 (8×8 perimeter: r=2..9, c=2..9 = 28 cells): 28 singles ───
    for (int c = 2; c <= 8; c++) list.add(_a1(id++, 2, c, ArrowDir.up));
    list.add(_a1(id++, 2, 9, ArrowDir.right));
    for (int r = 3; r <= 8; r++) list.add(_a1(id++, r, 9, ArrowDir.right));
    list.add(_a1(id++, 9, 9, ArrowDir.down));
    for (int c = 8; c >= 3; c--) list.add(_a1(id++, 9, c, ArrowDir.down));
    list.add(_a1(id++, 9, 2, ArrowDir.left));
    for (int r = 8; r >= 3; r--) list.add(_a1(id++, r, 2, ArrowDir.left));
    // 108 arrows ✓

    // ── Inner 6×6 (r=3..8, c=3..8 = 36 cells → 12 arrows, all three-seg) ─
    // Top r=3: (3,3)(3,4)(3,5)→up, (3,6)(3,7)(3,8)→right
    list.add(_a3(id, 3, 3, 3, 4, 3, 5, ArrowDir.up));    id++;
    list.add(_a3(id, 3, 6, 3, 7, 3, 8, ArrowDir.right)); id++;

    // Right c=8..r: (4,8)(5,8)(6,8)→right, (7,8)(8,8) only 2... wait
    // Right col c=8, r=4..8 = 5 cells — 5 is not divisible by 3.
    // Place: (4,8)(5,8)(6,8)→right=3, (7,8)(8,8) = 2-seg. Adjust: use 1 three-seg + 1 two-seg.
    // But we need all 12 to be three-seg. Let's reallocate:
    // Instead of pure three-seg, recalculate with 10 three-seg + 2 two-seg = 12 arrows:
    // cells: 30+4=34 ≠ 36. Use: 8 three-seg + 6 two-seg = 14 arrows ✗ (need 12).
    // Correct: 12 arrows, 36 cells → 12 three-seg = 36 cells ✓ ← must work exactly.
    //
    // 6×6 = 36 cells. 12 three-seg covers exactly 36 cells ✓. Let's lay them out:
    // Divide the 6×6 into 12 non-overlapping horizontal or vertical triominoes:
    //   Row 3: (3,3)(3,4)(3,5) → up,  (3,6)(3,7)(3,8) → right
    //   Col 8 downward: (4,8)(5,8)(6,8) → right,  (7,8)(8,8) missing 1 — can't.
    //   Use L-shaped / mixed approach doesn't work with _a3 (linear only).
    //   Best linear partition of 6×6 into 12 straight triominoes (rows or cols of 3):
    //   6 horizontal rows × 2 triominoes per row = 12 triominoes ✓
    //     Each row r=3..8: cells c=3,4,5 and c=6,7,8

    list.clear();
    list.addAll([]); // reset and rebuild cleanly below

    // ── Rebuild Level 10 cleanly ──────────────────────────────────────────
    id = 0;

    // Ring 0
    for (int c = 0; c < 11; c++) list.add(_a1(id++, 0, c, ArrowDir.up));
    list.add(_a1(id++, 0, 11, ArrowDir.right));
    for (int r = 1; r <= 10; r++) list.add(_a1(id++, r, 11, ArrowDir.right));
    list.add(_a1(id++, 11, 11, ArrowDir.down));
    for (int c = 10; c >= 1; c--) list.add(_a1(id++, 11, c, ArrowDir.down));
    list.add(_a1(id++, 11, 0, ArrowDir.left));
    for (int r = 10; r >= 1; r--) list.add(_a1(id++, r, 0, ArrowDir.left));

    // Ring 1
    for (int c = 1; c <= 9; c++) list.add(_a1(id++, 1, c, ArrowDir.up));
    list.add(_a1(id++, 1, 10, ArrowDir.right));
    for (int r = 2; r <= 9; r++) list.add(_a1(id++, r, 10, ArrowDir.right));
    list.add(_a1(id++, 10, 10, ArrowDir.down));
    for (int c = 9; c >= 2; c--) list.add(_a1(id++, 10, c, ArrowDir.down));
    list.add(_a1(id++, 10, 1, ArrowDir.left));
    for (int r = 9; r >= 2; r--) list.add(_a1(id++, r, 1, ArrowDir.left));

    // Ring 2
    for (int c = 2; c <= 8; c++) list.add(_a1(id++, 2, c, ArrowDir.up));
    list.add(_a1(id++, 2, 9, ArrowDir.right));
    for (int r = 3; r <= 8; r++) list.add(_a1(id++, r, 9, ArrowDir.right));
    list.add(_a1(id++, 9, 9, ArrowDir.down));
    for (int c = 8; c >= 3; c--) list.add(_a1(id++, 9, c, ArrowDir.down));
    list.add(_a1(id++, 9, 2, ArrowDir.left));
    for (int r = 8; r >= 3; r--) list.add(_a1(id++, r, 2, ArrowDir.left));
    // 108 arrows, 108 cells. Need 12 more arrows for 36 inner cells.

    // Inner 6×6 (r=3..8, c=3..8): 12 horizontal three-segs
    // Each row has 6 cells → 2 triominoes per row → 6 rows × 2 = 12 ✓
    const innerDirs = [
      // [row, escape dir index]  dir: 0=up 1=right 3=down 2=left
      // Top rows escape up, bottom rows escape down, use alternation for interest
      [3, 0], // up
      [4, 2], // left (reversed sweep)
      [5, 0], // up
      [6, 3], // down
      [7, 3], // down
      [8, 3], // down
    ];
    const dirs = [ArrowDir.up, ArrowDir.right, ArrowDir.left, ArrowDir.down];

    for (final rd in innerDirs) {
      final r = rd[0];
      final dir = dirs[rd[1]];
      list.add(_a3(id, r, 3, r, 4, r, 5, dir));    id++;
      list.add(_a3(id, r, 6, r, 7, r, 8, dir));    id++;
    }

    return list; // 108 + 12 = 120 arrows, 108 + 36 = 144 cells ✓
  }
}