import '../utils/app_colors.dart';
import '../models/arrow_model.dart';

/// Level 8 – Complex Loops (Expert)
/// Three interlocking loop shapes. Each loop must be
/// fully cleared before the next becomes accessible.
class Level8 {
  static const int gridSize = 12;
  static const String shapeName = 'Octagon';

  static List<ArrowModel> getArrows() {
    return [
      // Loop 1 (top-left, 4x4) ─────────────────────
      ArrowModel(
          x: 0, y: 0, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 1, y: 0, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 2, y: 0, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 3, y: 0, direction: ArrowDirection.down, color: AppColors.cyan),
      ArrowModel(
          x: 3, y: 1, direction: ArrowDirection.down, color: AppColors.yellow),
      ArrowModel(
          x: 3, y: 2, direction: ArrowDirection.down, color: AppColors.yellow),
      ArrowModel(
          x: 3, y: 3, direction: ArrowDirection.left, color: AppColors.yellow),
      ArrowModel(
          x: 2, y: 3, direction: ArrowDirection.left, color: AppColors.yellow),
      ArrowModel(
          x: 1, y: 3, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 0, y: 3, direction: ArrowDirection.up, color: AppColors.orange),
      ArrowModel(
          x: 0, y: 2, direction: ArrowDirection.up, color: AppColors.orange),
      ArrowModel(
          x: 0, y: 1, direction: ArrowDirection.up, color: AppColors.orange),

      // Loop 2 (top-right, 4x4) ─────────────────────
      ArrowModel(
          x: 8, y: 0, direction: ArrowDirection.right, color: AppColors.red),
      ArrowModel(
          x: 9, y: 0, direction: ArrowDirection.right, color: AppColors.red),
      ArrowModel(
          x: 10, y: 0, direction: ArrowDirection.right, color: AppColors.red),
      ArrowModel(
          x: 11, y: 0, direction: ArrowDirection.down, color: AppColors.red),
      ArrowModel(
          x: 11, y: 1, direction: ArrowDirection.down, color: AppColors.purple),
      ArrowModel(
          x: 11, y: 2, direction: ArrowDirection.down, color: AppColors.purple),
      ArrowModel(
          x: 11, y: 3, direction: ArrowDirection.left, color: AppColors.purple),
      ArrowModel(
          x: 10, y: 3, direction: ArrowDirection.left, color: AppColors.purple),
      ArrowModel(
          x: 9, y: 3, direction: ArrowDirection.left, color: AppColors.green),
      ArrowModel(
          x: 8, y: 3, direction: ArrowDirection.up, color: AppColors.green),
      ArrowModel(
          x: 8, y: 2, direction: ArrowDirection.up, color: AppColors.green),
      ArrowModel(
          x: 8, y: 1, direction: ArrowDirection.up, color: AppColors.green),

      // Loop 3 (bottom-center, 4x4) ─────────────────
      ArrowModel(
          x: 4, y: 8, direction: ArrowDirection.right, color: AppColors.yellow),
      ArrowModel(
          x: 5, y: 8, direction: ArrowDirection.right, color: AppColors.yellow),
      ArrowModel(
          x: 6, y: 8, direction: ArrowDirection.right, color: AppColors.yellow),
      ArrowModel(
          x: 7, y: 8, direction: ArrowDirection.down, color: AppColors.cyan),
      ArrowModel(
          x: 7, y: 9, direction: ArrowDirection.down, color: AppColors.cyan),
      ArrowModel(
          x: 7, y: 10, direction: ArrowDirection.down, color: AppColors.cyan),
      ArrowModel(
          x: 7, y: 11, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 6, y: 11, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 5, y: 11, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 4, y: 11, direction: ArrowDirection.up, color: AppColors.red),
      ArrowModel(
          x: 4, y: 10, direction: ArrowDirection.up, color: AppColors.red),
      ArrowModel(
          x: 4, y: 9, direction: ArrowDirection.up, color: AppColors.red),

      // Connectors between loops
      ArrowModel(
          x: 5, y: 1, direction: ArrowDirection.right, color: AppColors.purple),
      ArrowModel(
          x: 6, y: 1, direction: ArrowDirection.right, color: AppColors.purple),
      ArrowModel(
          x: 5, y: 5, direction: ArrowDirection.down, color: AppColors.green),
      ArrowModel(
          x: 6, y: 5, direction: ArrowDirection.down, color: AppColors.cyan),
    ];
  }
}
