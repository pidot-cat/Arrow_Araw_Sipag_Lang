import '../utils/app_colors.dart';
import '../models/arrow_model.dart';

/// Level 7 – Maze Style (Expert)
/// Walls of arrows create corridors.
/// Player must find the correct order to clear each corridor.
class Level7 {
  static const int gridSize = 11;
  static const String shapeName = 'Heptagon';

  static List<ArrowModel> getArrows() {
    return [
      // Top border →
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

      // Right border ↓
      ArrowModel(
          x: 10, y: 1, direction: ArrowDirection.down, color: AppColors.purple),
      ArrowModel(
          x: 10, y: 2, direction: ArrowDirection.down, color: AppColors.cyan),
      ArrowModel(
          x: 10, y: 3, direction: ArrowDirection.down, color: AppColors.yellow),
      ArrowModel(
          x: 10, y: 4, direction: ArrowDirection.down, color: AppColors.red),
      ArrowModel(
          x: 10, y: 5, direction: ArrowDirection.down, color: AppColors.green),

      // Left border ↑
      ArrowModel(
          x: 0, y: 10, direction: ArrowDirection.up, color: AppColors.orange),
      ArrowModel(
          x: 0, y: 9, direction: ArrowDirection.up, color: AppColors.purple),
      ArrowModel(
          x: 0, y: 8, direction: ArrowDirection.up, color: AppColors.cyan),
      ArrowModel(
          x: 0, y: 7, direction: ArrowDirection.up, color: AppColors.yellow),
      ArrowModel(
          x: 0, y: 6, direction: ArrowDirection.up, color: AppColors.red),
      ArrowModel(
          x: 0, y: 5, direction: ArrowDirection.up, color: AppColors.green),

      // Bottom border ←
      ArrowModel(
          x: 10,
          y: 10,
          direction: ArrowDirection.left,
          color: AppColors.orange),
      ArrowModel(
          x: 9, y: 10, direction: ArrowDirection.left, color: AppColors.purple),
      ArrowModel(
          x: 8, y: 10, direction: ArrowDirection.left, color: AppColors.cyan),
      ArrowModel(
          x: 7, y: 10, direction: ArrowDirection.left, color: AppColors.yellow),
      ArrowModel(
          x: 6, y: 10, direction: ArrowDirection.left, color: AppColors.red),
      ArrowModel(
          x: 5, y: 10, direction: ArrowDirection.left, color: AppColors.green),
      ArrowModel(
          x: 4, y: 10, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 3, y: 10, direction: ArrowDirection.left, color: AppColors.purple),
      ArrowModel(
          x: 2, y: 10, direction: ArrowDirection.left, color: AppColors.cyan),
      ArrowModel(
          x: 1, y: 10, direction: ArrowDirection.left, color: AppColors.yellow),

      // Inner wall 1 – vertical ↓
      ArrowModel(
          x: 3, y: 2, direction: ArrowDirection.down, color: AppColors.red),
      ArrowModel(
          x: 3, y: 3, direction: ArrowDirection.down, color: AppColors.green),
      ArrowModel(
          x: 3, y: 4, direction: ArrowDirection.down, color: AppColors.orange),
      ArrowModel(
          x: 3, y: 5, direction: ArrowDirection.down, color: AppColors.purple),

      // Inner wall 2 – horizontal →
      ArrowModel(
          x: 5, y: 3, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 6, y: 3, direction: ArrowDirection.right, color: AppColors.yellow),
      ArrowModel(
          x: 7, y: 3, direction: ArrowDirection.right, color: AppColors.red),

      // Inner wall 3 – vertical ↑
      ArrowModel(
          x: 7, y: 5, direction: ArrowDirection.up, color: AppColors.green),
      ArrowModel(
          x: 7, y: 6, direction: ArrowDirection.up, color: AppColors.orange),
      ArrowModel(
          x: 7, y: 7, direction: ArrowDirection.up, color: AppColors.purple),

      // Inner wall 4 – horizontal ←
      ArrowModel(
          x: 4, y: 7, direction: ArrowDirection.left, color: AppColors.cyan),
      ArrowModel(
          x: 5, y: 7, direction: ArrowDirection.left, color: AppColors.yellow),
      ArrowModel(
          x: 6, y: 7, direction: ArrowDirection.left, color: AppColors.red),

      // Center
      ArrowModel(
          x: 5, y: 5, direction: ArrowDirection.up, color: AppColors.green),
    ];
  }
}
