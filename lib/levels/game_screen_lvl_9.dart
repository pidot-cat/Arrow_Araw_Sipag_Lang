import '../utils/app_colors.dart';
import '../models/arrow_model.dart';

/// Level 9 – Dense Puzzle (Master)
/// High-density grid packed with arrows.
/// Many blocking chains — requires careful analysis.
class Level9 {
  static const int gridSize = 13;
  static const String shapeName = 'Nonagon';

  static List<ArrowModel> getArrows() {
    return [
      // Top strip →
      ArrowModel(
          x: 0, y: 0, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 1, y: 0, direction: ArrowDirection.right, color: AppColors.yellow),
      ArrowModel(
          x: 2, y: 0, direction: ArrowDirection.right, color: AppColors.red),
      ArrowModel(
          x: 3, y: 0, direction: ArrowDirection.right, color: AppColors.green),
      ArrowModel(
          x: 4, y: 0, direction: ArrowDirection.right, color: AppColors.orange),
      ArrowModel(
          x: 5, y: 0, direction: ArrowDirection.right, color: AppColors.purple),
      ArrowModel(
          x: 6, y: 0, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 7, y: 0, direction: ArrowDirection.right, color: AppColors.yellow),
      ArrowModel(
          x: 8, y: 0, direction: ArrowDirection.right, color: AppColors.red),
      ArrowModel(
          x: 9, y: 0, direction: ArrowDirection.right, color: AppColors.green),
      ArrowModel(
          x: 10,
          y: 0,
          direction: ArrowDirection.right,
          color: AppColors.orange),
      ArrowModel(
          x: 11,
          y: 0,
          direction: ArrowDirection.right,
          color: AppColors.purple),
      ArrowModel(
          x: 12, y: 0, direction: ArrowDirection.right, color: AppColors.cyan),

      // Right strip ↓
      ArrowModel(
          x: 12, y: 1, direction: ArrowDirection.down, color: AppColors.yellow),
      ArrowModel(
          x: 12, y: 2, direction: ArrowDirection.down, color: AppColors.red),
      ArrowModel(
          x: 12, y: 3, direction: ArrowDirection.down, color: AppColors.green),
      ArrowModel(
          x: 12, y: 4, direction: ArrowDirection.down, color: AppColors.orange),
      ArrowModel(
          x: 12, y: 5, direction: ArrowDirection.down, color: AppColors.purple),
      ArrowModel(
          x: 12, y: 6, direction: ArrowDirection.down, color: AppColors.cyan),

      // Bottom strip ←
      ArrowModel(
          x: 12,
          y: 12,
          direction: ArrowDirection.left,
          color: AppColors.yellow),
      ArrowModel(
          x: 11, y: 12, direction: ArrowDirection.left, color: AppColors.red),
      ArrowModel(
          x: 10, y: 12, direction: ArrowDirection.left, color: AppColors.green),
      ArrowModel(
          x: 9, y: 12, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 8, y: 12, direction: ArrowDirection.left, color: AppColors.purple),
      ArrowModel(
          x: 7, y: 12, direction: ArrowDirection.left, color: AppColors.cyan),
      ArrowModel(
          x: 6, y: 12, direction: ArrowDirection.left, color: AppColors.yellow),
      ArrowModel(
          x: 5, y: 12, direction: ArrowDirection.left, color: AppColors.red),
      ArrowModel(
          x: 4, y: 12, direction: ArrowDirection.left, color: AppColors.green),
      ArrowModel(
          x: 3, y: 12, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 2, y: 12, direction: ArrowDirection.left, color: AppColors.purple),
      ArrowModel(
          x: 1, y: 12, direction: ArrowDirection.left, color: AppColors.cyan),
      ArrowModel(
          x: 0, y: 12, direction: ArrowDirection.left, color: AppColors.yellow),

      // Left strip ↑
      ArrowModel(
          x: 0, y: 11, direction: ArrowDirection.up, color: AppColors.red),
      ArrowModel(
          x: 0, y: 10, direction: ArrowDirection.up, color: AppColors.green),
      ArrowModel(
          x: 0, y: 9, direction: ArrowDirection.up, color: AppColors.orange),
      ArrowModel(
          x: 0, y: 8, direction: ArrowDirection.up, color: AppColors.purple),
      ArrowModel(
          x: 0, y: 7, direction: ArrowDirection.up, color: AppColors.cyan),
      ArrowModel(
          x: 0, y: 6, direction: ArrowDirection.up, color: AppColors.yellow),
      ArrowModel(
          x: 0, y: 5, direction: ArrowDirection.up, color: AppColors.red),
      ArrowModel(
          x: 0, y: 4, direction: ArrowDirection.up, color: AppColors.green),
      ArrowModel(
          x: 0, y: 3, direction: ArrowDirection.up, color: AppColors.orange),
      ArrowModel(
          x: 0, y: 2, direction: ArrowDirection.up, color: AppColors.purple),
      ArrowModel(
          x: 0, y: 1, direction: ArrowDirection.up, color: AppColors.cyan),

      // Middle horizontal bands
      ArrowModel(
          x: 2, y: 4, direction: ArrowDirection.right, color: AppColors.red),
      ArrowModel(
          x: 3, y: 4, direction: ArrowDirection.right, color: AppColors.green),
      ArrowModel(
          x: 4, y: 4, direction: ArrowDirection.right, color: AppColors.orange),
      ArrowModel(
          x: 5, y: 4, direction: ArrowDirection.right, color: AppColors.purple),
      ArrowModel(
          x: 6, y: 4, direction: ArrowDirection.right, color: AppColors.cyan),

      ArrowModel(
          x: 6, y: 8, direction: ArrowDirection.left, color: AppColors.yellow),
      ArrowModel(
          x: 7, y: 8, direction: ArrowDirection.left, color: AppColors.red),
      ArrowModel(
          x: 8, y: 8, direction: ArrowDirection.left, color: AppColors.green),
      ArrowModel(
          x: 9, y: 8, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 10, y: 8, direction: ArrowDirection.left, color: AppColors.purple),

      // Vertical connectors
      ArrowModel(
          x: 6, y: 2, direction: ArrowDirection.down, color: AppColors.cyan),
      ArrowModel(
          x: 6, y: 3, direction: ArrowDirection.down, color: AppColors.yellow),
      ArrowModel(
          x: 10, y: 5, direction: ArrowDirection.down, color: AppColors.red),
      ArrowModel(
          x: 10, y: 6, direction: ArrowDirection.down, color: AppColors.green),
      ArrowModel(
          x: 10, y: 7, direction: ArrowDirection.down, color: AppColors.orange),

      ArrowModel(
          x: 3, y: 9, direction: ArrowDirection.up, color: AppColors.purple),
      ArrowModel(
          x: 3, y: 10, direction: ArrowDirection.up, color: AppColors.cyan),
      ArrowModel(
          x: 3, y: 11, direction: ArrowDirection.up, color: AppColors.yellow),

      // Center cluster
      ArrowModel(
          x: 6, y: 6, direction: ArrowDirection.up, color: AppColors.red),
      ArrowModel(
          x: 6, y: 7, direction: ArrowDirection.down, color: AppColors.green),
      ArrowModel(
          x: 5, y: 6, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 7, y: 6, direction: ArrowDirection.right, color: AppColors.purple),
      ArrowModel(
          x: 6, y: 5, direction: ArrowDirection.up, color: AppColors.cyan),
    ];
  }
}
