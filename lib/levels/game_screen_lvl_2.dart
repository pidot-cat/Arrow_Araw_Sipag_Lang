import '../utils/app_colors.dart';
import '../models/arrow_model.dart';

/// Level 2 – Zigzag (Easy-Normal)
/// Arrows alternate left/right forming a zigzag path.
/// Player must clear each row before unblocking the next.
class Level2 {
  static const int gridSize = 6;
  static const String shapeName = 'Circle';

  static List<ArrowModel> getArrows() {
    return [
      // Row 0 – pointing RIGHT
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

      // Row 1 – downward connector (right side)
      ArrowModel(
          x: 5, y: 1, direction: ArrowDirection.down, color: AppColors.yellow),

      // Row 2 – pointing LEFT
      ArrowModel(
          x: 0, y: 2, direction: ArrowDirection.left, color: AppColors.cyan),
      ArrowModel(
          x: 1, y: 2, direction: ArrowDirection.left, color: AppColors.green),
      ArrowModel(
          x: 2, y: 2, direction: ArrowDirection.left, color: AppColors.orange),
      ArrowModel(
          x: 3, y: 2, direction: ArrowDirection.left, color: AppColors.purple),
      ArrowModel(
          x: 4, y: 2, direction: ArrowDirection.left, color: AppColors.red),
      ArrowModel(
          x: 5, y: 2, direction: ArrowDirection.left, color: AppColors.yellow),

      // Row 3 – downward connector (left side)
      ArrowModel(
          x: 0, y: 3, direction: ArrowDirection.down, color: AppColors.orange),

      // Row 4 – pointing RIGHT again
      ArrowModel(
          x: 0, y: 4, direction: ArrowDirection.right, color: AppColors.purple),
      ArrowModel(
          x: 1, y: 4, direction: ArrowDirection.right, color: AppColors.cyan),
      ArrowModel(
          x: 2, y: 4, direction: ArrowDirection.right, color: AppColors.green),
      ArrowModel(
          x: 3, y: 4, direction: ArrowDirection.right, color: AppColors.yellow),
      ArrowModel(
          x: 4, y: 4, direction: ArrowDirection.right, color: AppColors.red),
      ArrowModel(
          x: 5, y: 4, direction: ArrowDirection.right, color: AppColors.orange),
    ];
  }
}
