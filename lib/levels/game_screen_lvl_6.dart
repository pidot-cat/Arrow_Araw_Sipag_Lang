import '../utils/app_colors.dart';
import '../models/arrow_model.dart';

/// Level 6 – Heart Shape (Hard)
/// Arrows trace a heart. Must clear symmetrically
/// from tip upward, then outer lobes.
class Level6 {
  static const int gridSize = 10;
  static const String shapeName = 'Hexagon';

  static List<ArrowModel> getArrows() {
    return [
      // Bottom tip pointing DOWN
      ArrowModel(
          x: 4, y: 9, direction: ArrowDirection.down, color: AppColors.red),
      ArrowModel(
          x: 5, y: 9, direction: ArrowDirection.down, color: AppColors.red),

      // Lower-left diagonal ←
      ArrowModel(
          x: 1, y: 7, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 2, y: 8, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 3, y: 8, direction: ArrowDirection.left, color: AppColors.yellow),

      // Lower-right diagonal →
      ArrowModel(
          x: 8, y: 7, direction: ArrowDirection.right, color: AppColors.orange),
      ArrowModel(
          x: 7, y: 8, direction: ArrowDirection.right, color: AppColors.orange),
      ArrowModel(
          x: 6, y: 8, direction: ArrowDirection.right, color: AppColors.yellow),

      // Left side ↑
      ArrowModel(
          x: 0, y: 6, direction: ArrowDirection.up, color: AppColors.purple),
      ArrowModel(
          x: 0, y: 5, direction: ArrowDirection.up, color: AppColors.purple),
      ArrowModel(
          x: 0, y: 4, direction: ArrowDirection.up, color: AppColors.cyan),

      // Right side ↑
      ArrowModel(
          x: 9, y: 6, direction: ArrowDirection.up, color: AppColors.purple),
      ArrowModel(
          x: 9, y: 5, direction: ArrowDirection.up, color: AppColors.purple),
      ArrowModel(
          x: 9, y: 4, direction: ArrowDirection.up, color: AppColors.cyan),

      // Left lobe – outer top →
      ArrowModel(
          x: 1, y: 3, direction: ArrowDirection.right, color: AppColors.green),
      ArrowModel(
          x: 2, y: 2, direction: ArrowDirection.right, color: AppColors.green),

      // Right lobe – outer top ←
      ArrowModel(
          x: 8, y: 3, direction: ArrowDirection.left, color: AppColors.green),
      ArrowModel(
          x: 7, y: 2, direction: ArrowDirection.left, color: AppColors.green),

      // Left lobe top ↑
      ArrowModel(
          x: 1, y: 1, direction: ArrowDirection.up, color: AppColors.cyan),
      ArrowModel(
          x: 2, y: 0, direction: ArrowDirection.up, color: AppColors.yellow),
      ArrowModel(
          x: 3, y: 0, direction: ArrowDirection.up, color: AppColors.red),

      // Right lobe top ↑
      ArrowModel(
          x: 8, y: 1, direction: ArrowDirection.up, color: AppColors.cyan),
      ArrowModel(
          x: 7, y: 0, direction: ArrowDirection.up, color: AppColors.yellow),
      ArrowModel(
          x: 6, y: 0, direction: ArrowDirection.up, color: AppColors.red),

      // Center top – the dip of the heart ↓
      ArrowModel(
          x: 4, y: 2, direction: ArrowDirection.down, color: AppColors.orange),
      ArrowModel(
          x: 5, y: 2, direction: ArrowDirection.down, color: AppColors.orange),
    ];
  }
}
