import '../utils/app_colors.dart';
import '../models/arrow_model.dart';

/// Level 1 – Simple Path (Easy)
/// Layout: Arrows along the 4 edges of a 5x5 grid
/// pointing outward — easy to read, good intro level.
class Level1 {
  static const int gridSize = 5;
  static const String shapeName = 'Heart';

  static List<ArrowModel> getArrows() {
    return [
      // Top row pointing UP (can escape immediately)
      ArrowModel(
          x: 0, y: 0, direction: ArrowDirection.up, color: AppColors.yellow),
      ArrowModel(
          x: 1, y: 0, direction: ArrowDirection.up, color: AppColors.cyan),
      ArrowModel(
          x: 2, y: 0, direction: ArrowDirection.up, color: AppColors.red),
      ArrowModel(
          x: 3, y: 0, direction: ArrowDirection.up, color: AppColors.green),
      ArrowModel(
          x: 4, y: 0, direction: ArrowDirection.up, color: AppColors.orange),

      // Bottom row pointing DOWN
      ArrowModel(
          x: 0, y: 4, direction: ArrowDirection.down, color: AppColors.purple),
      ArrowModel(
          x: 1, y: 4, direction: ArrowDirection.down, color: AppColors.yellow),
      ArrowModel(
          x: 2, y: 4, direction: ArrowDirection.down, color: AppColors.cyan),
      ArrowModel(
          x: 3, y: 4, direction: ArrowDirection.down, color: AppColors.red),
      ArrowModel(
          x: 4, y: 4, direction: ArrowDirection.down, color: AppColors.green),

      // Left column pointing LEFT
      ArrowModel(
          x: 0, y: 1, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 0, y: 2, direction: ArrowDirection.left, color: AppColors.purple),
      ArrowModel(
          x: 0, y: 3, direction: ArrowDirection.left, color: AppColors.yellow),

      // Right column pointing RIGHT
      ArrowModel(
          x: 4, y: 1, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 4, y: 2, direction: ArrowDirection.right, color: AppColors.red),
      ArrowModel(
          x: 4, y: 3, direction: ArrowDirection.right, color: AppColors.green),
    ];
  }
}
