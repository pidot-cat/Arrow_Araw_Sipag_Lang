import '../utils/app_colors.dart';
import '../models/arrow_model.dart';

/// Level 5 – Circle (Hard)
/// Arrows arranged in a circular pattern.
/// Tangential arrows must be cleared in clockwise order.
class Level5 {
  static const int gridSize = 9;
  static const String shapeName = 'Pentagon';

  static List<ArrowModel> getArrows() {
    return [
      // Top arc →
      ArrowModel(
          x: 2, y: 0, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 3, y: 0, direction: ArrowDirection.right, color: AppColors.yellow),
      ArrowModel(
          x: 4, y: 0, direction: ArrowDirection.right, color: AppColors.red),
      ArrowModel(
          x: 5, y: 0, direction: ArrowDirection.right, color: AppColors.green),
      ArrowModel(
          x: 6, y: 0, direction: ArrowDirection.right, color: AppColors.orange),

      // Top-right corner ↓
      ArrowModel(
          x: 7, y: 1, direction: ArrowDirection.down, color: AppColors.purple),
      ArrowModel(
          x: 8, y: 2, direction: ArrowDirection.down, color: AppColors.cyan),

      // Right arc ↓
      ArrowModel(
          x: 8, y: 3, direction: ArrowDirection.down, color: AppColors.yellow),
      ArrowModel(
          x: 8, y: 4, direction: ArrowDirection.down, color: AppColors.red),
      ArrowModel(
          x: 8, y: 5, direction: ArrowDirection.down, color: AppColors.green),

      // Bottom-right corner ←
      ArrowModel(
          x: 8, y: 6, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 7, y: 7, direction: ArrowDirection.left, color: AppColors.purple),

      // Bottom arc ←
      ArrowModel(
          x: 6, y: 8, direction: ArrowDirection.left, color: AppColors.cyan),
      ArrowModel(
          x: 5, y: 8, direction: ArrowDirection.left, color: AppColors.yellow),
      ArrowModel(
          x: 4, y: 8, direction: ArrowDirection.left, color: AppColors.red),
      ArrowModel(
          x: 3, y: 8, direction: ArrowDirection.left, color: AppColors.green),
      ArrowModel(
          x: 2, y: 8, direction: ArrowDirection.left, color: AppColors.orange),

      // Bottom-left corner ↑
      ArrowModel(
          x: 1, y: 7, direction: ArrowDirection.up, color: AppColors.purple),
      ArrowModel(
          x: 0, y: 6, direction: ArrowDirection.up, color: AppColors.cyan),

      // Left arc ↑
      ArrowModel(
          x: 0, y: 5, direction: ArrowDirection.up, color: AppColors.yellow),
      ArrowModel(
          x: 0, y: 4, direction: ArrowDirection.up, color: AppColors.red),
      ArrowModel(
          x: 0, y: 3, direction: ArrowDirection.up, color: AppColors.green),

      // Top-left corner →
      ArrowModel(
          x: 0, y: 2, direction: ArrowDirection.right, color: AppColors.orange),
      ArrowModel(
          x: 1, y: 1, direction: ArrowDirection.right, color: AppColors.purple),

      // Center cluster
      ArrowModel(
          x: 4, y: 4, direction: ArrowDirection.up, color: AppColors.cyan),
      ArrowModel(
          x: 4, y: 5, direction: ArrowDirection.down, color: AppColors.yellow),
      ArrowModel(
          x: 3, y: 4, direction: ArrowDirection.left, color: AppColors.red),
      ArrowModel(
          x: 5, y: 4, direction: ArrowDirection.right, color: AppColors.green),
    ];
  }
}
