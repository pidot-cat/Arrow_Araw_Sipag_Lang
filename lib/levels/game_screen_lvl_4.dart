import '../utils/app_colors.dart';
import '../models/arrow_model.dart';

/// Level 4 – Square (Normal)
/// Two concentric squares. Outer square clears first,
/// inner square second. Cross-shaped blocker in center.
class Level4 {
  static const int gridSize = 8;
  static const String shapeName = 'Square';

  static List<ArrowModel> getArrows() {
    return [
      // Outer square – top row →
      ArrowModel(
          x: 0, y: 0, direction: ArrowDirection.right, color: AppColors.yellow),
      ArrowModel(
          x: 1, y: 0, direction: ArrowDirection.right, color: AppColors.orange),
      ArrowModel(
          x: 2, y: 0, direction: ArrowDirection.right, color: AppColors.red),
      ArrowModel(
          x: 3, y: 0, direction: ArrowDirection.right, color: AppColors.purple),
      ArrowModel(
          x: 4, y: 0, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 5, y: 0, direction: ArrowDirection.right, color: AppColors.green),
      ArrowModel(
          x: 6, y: 0, direction: ArrowDirection.right, color: AppColors.yellow),
      ArrowModel(
          x: 7, y: 0, direction: ArrowDirection.right, color: AppColors.orange),

      // Outer square – right col ↓
      ArrowModel(
          x: 7, y: 1, direction: ArrowDirection.down, color: AppColors.red),
      ArrowModel(
          x: 7, y: 2, direction: ArrowDirection.down, color: AppColors.purple),
      ArrowModel(
          x: 7, y: 3, direction: ArrowDirection.down, color: AppColors.cyan),
      ArrowModel(
          x: 7, y: 4, direction: ArrowDirection.down, color: AppColors.green),
      ArrowModel(
          x: 7, y: 5, direction: ArrowDirection.down, color: AppColors.yellow),
      ArrowModel(
          x: 7, y: 6, direction: ArrowDirection.down, color: AppColors.orange),
      ArrowModel(
          x: 7, y: 7, direction: ArrowDirection.down, color: AppColors.red),

      // Outer square – bottom row ←
      ArrowModel(
          x: 6, y: 7, direction: ArrowDirection.left, color: AppColors.purple),
      ArrowModel(
          x: 5, y: 7, direction: ArrowDirection.left, color: AppColors.cyan),
      ArrowModel(
          x: 4, y: 7, direction: ArrowDirection.left, color: AppColors.green),
      ArrowModel(
          x: 3, y: 7, direction: ArrowDirection.left, color: AppColors.yellow),
      ArrowModel(
          x: 2, y: 7, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 1, y: 7, direction: ArrowDirection.left, color: AppColors.red),
      ArrowModel(
          x: 0, y: 7, direction: ArrowDirection.left, color: AppColors.purple),

      // Outer square – left col ↑
      ArrowModel(
          x: 0, y: 6, direction: ArrowDirection.up, color: AppColors.cyan),
      ArrowModel(
          x: 0, y: 5, direction: ArrowDirection.up, color: AppColors.green),
      ArrowModel(
          x: 0, y: 4, direction: ArrowDirection.up, color: AppColors.yellow),
      ArrowModel(
          x: 0, y: 3, direction: ArrowDirection.up, color: AppColors.orange),
      ArrowModel(
          x: 0, y: 2, direction: ArrowDirection.up, color: AppColors.red),
      ArrowModel(
          x: 0, y: 1, direction: ArrowDirection.up, color: AppColors.purple),

      // Inner square – top →
      ArrowModel(
          x: 2, y: 2, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 3, y: 2, direction: ArrowDirection.right, color: AppColors.green),
      ArrowModel(
          x: 4, y: 2, direction: ArrowDirection.right, color: AppColors.yellow),
      ArrowModel(
          x: 5, y: 2, direction: ArrowDirection.right, color: AppColors.orange),

      // Inner square – right ↓
      ArrowModel(
          x: 5, y: 3, direction: ArrowDirection.down, color: AppColors.red),
      ArrowModel(
          x: 5, y: 4, direction: ArrowDirection.down, color: AppColors.purple),
      ArrowModel(
          x: 5, y: 5, direction: ArrowDirection.down, color: AppColors.cyan),

      // Inner square – bottom ←
      ArrowModel(
          x: 4, y: 5, direction: ArrowDirection.left, color: AppColors.green),
      ArrowModel(
          x: 3, y: 5, direction: ArrowDirection.left, color: AppColors.yellow),
      ArrowModel(
          x: 2, y: 5, direction: ArrowDirection.left, color: AppColors.orange),

      // Inner square – left ↑
      ArrowModel(
          x: 2, y: 4, direction: ArrowDirection.up, color: AppColors.red),
      ArrowModel(
          x: 2, y: 3, direction: ArrowDirection.up, color: AppColors.purple),
    ];
  }
}
