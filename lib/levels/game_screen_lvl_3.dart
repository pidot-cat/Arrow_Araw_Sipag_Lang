import '../utils/app_colors.dart';
import '../models/arrow_model.dart';

/// Level 3 – Spiral (Normal)
/// Arrows spiral inward. Must clear outer ring first,
/// then middle ring, then center.
class Level3 {
  static const int gridSize = 7;
  static const String shapeName = 'Triangle';

  static List<ArrowModel> getArrows() {
    return [
      // Outer ring – top row →
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

      // Outer ring – right col ↓
      ArrowModel(
          x: 6, y: 1, direction: ArrowDirection.down, color: AppColors.yellow),
      ArrowModel(
          x: 6, y: 2, direction: ArrowDirection.down, color: AppColors.red),
      ArrowModel(
          x: 6, y: 3, direction: ArrowDirection.down, color: AppColors.green),
      ArrowModel(
          x: 6, y: 4, direction: ArrowDirection.down, color: AppColors.orange),
      ArrowModel(
          x: 6, y: 5, direction: ArrowDirection.down, color: AppColors.purple),
      ArrowModel(
          x: 6, y: 6, direction: ArrowDirection.down, color: AppColors.cyan),

      // Outer ring – bottom row ←
      ArrowModel(
          x: 5, y: 6, direction: ArrowDirection.left, color: AppColors.yellow),
      ArrowModel(
          x: 4, y: 6, direction: ArrowDirection.left, color: AppColors.red),
      ArrowModel(
          x: 3, y: 6, direction: ArrowDirection.left, color: AppColors.green),
      ArrowModel(
          x: 2, y: 6, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 1, y: 6, direction: ArrowDirection.left, color: AppColors.purple),
      ArrowModel(
          x: 0, y: 6, direction: ArrowDirection.left, color: AppColors.cyan),

      // Outer ring – left col ↑
      ArrowModel(
          x: 0, y: 5, direction: ArrowDirection.up, color: AppColors.yellow),
      ArrowModel(
          x: 0, y: 4, direction: ArrowDirection.up, color: AppColors.red),
      ArrowModel(
          x: 0, y: 3, direction: ArrowDirection.up, color: AppColors.green),
      ArrowModel(
          x: 0, y: 2, direction: ArrowDirection.up, color: AppColors.orange),
      ArrowModel(
          x: 0, y: 1, direction: ArrowDirection.up, color: AppColors.purple),

      // Inner ring – top →
      ArrowModel(
          x: 2, y: 2, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 3, y: 2, direction: ArrowDirection.right, color: AppColors.yellow),
      ArrowModel(
          x: 4, y: 2, direction: ArrowDirection.right, color: AppColors.red),

      // Inner ring – right ↓
      ArrowModel(
          x: 4, y: 3, direction: ArrowDirection.down, color: AppColors.green),
      ArrowModel(
          x: 4, y: 4, direction: ArrowDirection.down, color: AppColors.orange),

      // Inner ring – bottom ←
      ArrowModel(
          x: 3, y: 4, direction: ArrowDirection.left, color: AppColors.purple),
      ArrowModel(
          x: 2, y: 4, direction: ArrowDirection.left, color: AppColors.cyan),

      // Inner ring – left ↑
      ArrowModel(
          x: 2, y: 3, direction: ArrowDirection.up, color: AppColors.yellow),

      // Center
      ArrowModel(
          x: 3, y: 3, direction: ArrowDirection.up, color: AppColors.red),
    ];
  }
}
