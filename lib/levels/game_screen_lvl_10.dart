import '../utils/app_colors.dart';
import '../models/arrow_model.dart';

/// Level 10 – Hard Final Pattern (Master)
/// The ultimate challenge: a star pattern with
/// densely packed inner corridors and multiple
/// interdependent chains. Good luck!
class Level10 {
  static const int gridSize = 14;
  static const String shapeName = 'Decagon';

  static List<ArrowModel> getArrows() {
    return [
      // ── Star point: TOP ↑ ─────────────────────────
      ArrowModel(
          x: 6, y: 0, direction: ArrowDirection.up, color: AppColors.red),
      ArrowModel(
          x: 7, y: 0, direction: ArrowDirection.up, color: AppColors.red),
      ArrowModel(
          x: 6, y: 1, direction: ArrowDirection.up, color: AppColors.orange),
      ArrowModel(
          x: 7, y: 1, direction: ArrowDirection.up, color: AppColors.orange),

      // ── Star point: BOTTOM ↓ ──────────────────────
      ArrowModel(
          x: 6, y: 13, direction: ArrowDirection.down, color: AppColors.red),
      ArrowModel(
          x: 7, y: 13, direction: ArrowDirection.down, color: AppColors.red),
      ArrowModel(
          x: 6, y: 12, direction: ArrowDirection.down, color: AppColors.orange),
      ArrowModel(
          x: 7, y: 12, direction: ArrowDirection.down, color: AppColors.orange),

      // ── Star point: LEFT ← ────────────────────────
      ArrowModel(
          x: 0, y: 6, direction: ArrowDirection.left, color: AppColors.cyan),
      ArrowModel(
          x: 0, y: 7, direction: ArrowDirection.left, color: AppColors.cyan),
      ArrowModel(
          x: 1, y: 6, direction: ArrowDirection.left, color: AppColors.yellow),
      ArrowModel(
          x: 1, y: 7, direction: ArrowDirection.left, color: AppColors.yellow),

      // ── Star point: RIGHT → ───────────────────────
      ArrowModel(
          x: 13, y: 6, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 13, y: 7, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 12,
          y: 6,
          direction: ArrowDirection.right,
          color: AppColors.yellow),
      ArrowModel(
          x: 12,
          y: 7,
          direction: ArrowDirection.right,
          color: AppColors.yellow),

      // ── Diagonal arms (top-left) ──────────────────
      ArrowModel(
          x: 2, y: 2, direction: ArrowDirection.up, color: AppColors.green),
      ArrowModel(
          x: 3, y: 3, direction: ArrowDirection.left, color: AppColors.green),
      ArrowModel(
          x: 2, y: 3, direction: ArrowDirection.up, color: AppColors.purple),

      // ── Diagonal arms (top-right) ─────────────────
      ArrowModel(
          x: 11, y: 2, direction: ArrowDirection.up, color: AppColors.green),
      ArrowModel(
          x: 10, y: 3, direction: ArrowDirection.right, color: AppColors.green),
      ArrowModel(
          x: 11, y: 3, direction: ArrowDirection.up, color: AppColors.purple),

      // ── Diagonal arms (bottom-left) ───────────────
      ArrowModel(
          x: 2, y: 11, direction: ArrowDirection.down, color: AppColors.green),
      ArrowModel(
          x: 3, y: 10, direction: ArrowDirection.left, color: AppColors.green),
      ArrowModel(
          x: 2, y: 10, direction: ArrowDirection.down, color: AppColors.purple),

      // ── Diagonal arms (bottom-right) ──────────────
      ArrowModel(
          x: 11, y: 11, direction: ArrowDirection.down, color: AppColors.green),
      ArrowModel(
          x: 10,
          y: 10,
          direction: ArrowDirection.right,
          color: AppColors.green),
      ArrowModel(
          x: 11,
          y: 10,
          direction: ArrowDirection.down,
          color: AppColors.purple),

      // ── Outer ring top →  ─────────────────────────
      ArrowModel(
          x: 4, y: 3, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 5, y: 3, direction: ArrowDirection.right, color: AppColors.yellow),
      ArrowModel(
          x: 8, y: 3, direction: ArrowDirection.right, color: AppColors.red),
      ArrowModel(
          x: 9, y: 3, direction: ArrowDirection.right, color: AppColors.orange),

      // ── Outer ring bottom ← ───────────────────────
      ArrowModel(
          x: 4, y: 10, direction: ArrowDirection.left, color: AppColors.cyan),
      ArrowModel(
          x: 5, y: 10, direction: ArrowDirection.left, color: AppColors.yellow),
      ArrowModel(
          x: 8, y: 10, direction: ArrowDirection.left, color: AppColors.red),
      ArrowModel(
          x: 9, y: 10, direction: ArrowDirection.left, color: AppColors.orange),

      // ── Outer ring left ↑ ─────────────────────────
      ArrowModel(
          x: 3, y: 4, direction: ArrowDirection.up, color: AppColors.purple),
      ArrowModel(
          x: 3, y: 5, direction: ArrowDirection.up, color: AppColors.green),
      ArrowModel(
          x: 3, y: 8, direction: ArrowDirection.up, color: AppColors.purple),
      ArrowModel(
          x: 3, y: 9, direction: ArrowDirection.up, color: AppColors.green),

      // ── Outer ring right ↓ ────────────────────────
      ArrowModel(
          x: 10, y: 4, direction: ArrowDirection.down, color: AppColors.purple),
      ArrowModel(
          x: 10, y: 5, direction: ArrowDirection.down, color: AppColors.green),
      ArrowModel(
          x: 10, y: 8, direction: ArrowDirection.down, color: AppColors.purple),
      ArrowModel(
          x: 10, y: 9, direction: ArrowDirection.down, color: AppColors.green),

      // ── Inner ring ───────────────────────────────
      ArrowModel(
          x: 5, y: 5, direction: ArrowDirection.right, color: AppColors.red),
      ArrowModel(
          x: 6, y: 5, direction: ArrowDirection.right, color: AppColors.orange),
      ArrowModel(
          x: 7, y: 5, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 8, y: 5, direction: ArrowDirection.down, color: AppColors.yellow),
      ArrowModel(
          x: 8, y: 6, direction: ArrowDirection.down, color: AppColors.green),
      ArrowModel(
          x: 8, y: 7, direction: ArrowDirection.down, color: AppColors.purple),
      ArrowModel(
          x: 8, y: 8, direction: ArrowDirection.left, color: AppColors.red),
      ArrowModel(
          x: 7, y: 8, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 6, y: 8, direction: ArrowDirection.left, color: AppColors.cyan),
      ArrowModel(
          x: 5, y: 8, direction: ArrowDirection.up, color: AppColors.yellow),
      ArrowModel(
          x: 5, y: 7, direction: ArrowDirection.up, color: AppColors.green),
      ArrowModel(
          x: 5, y: 6, direction: ArrowDirection.up, color: AppColors.purple),

      // ── Core center ───────────────────────────────
      ArrowModel(
          x: 6, y: 6, direction: ArrowDirection.right, color: AppColors.red),
      ArrowModel(
          x: 7, y: 6, direction: ArrowDirection.down, color: AppColors.orange),
      ArrowModel(
          x: 7, y: 7, direction: ArrowDirection.left, color: AppColors.cyan),
      ArrowModel(
          x: 6, y: 7, direction: ArrowDirection.up, color: AppColors.yellow),
    ];
  }
}
