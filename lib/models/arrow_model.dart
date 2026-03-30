import 'package:flutter/material.dart';

enum ArrowDirection { up, down, left, right, white }

class ArrowModel {
  final int x;
  final int y;
  final ArrowDirection direction;
  final Color color;
  bool isEscaping;
  bool isRemoved;

  ArrowModel({
    required this.x,
    required this.y,
    required this.direction,
    required this.color,
    this.isEscaping = false,
    this.isRemoved = false,
  });

  ArrowModel copyWith({
    int? x,
    int? y,
    ArrowDirection? direction,
    Color? color,
    bool? isEscaping,
    bool? isRemoved,
  }) {
    return ArrowModel(
      x: x ?? this.x,
      y: y ?? this.y,
      direction: direction ?? this.direction,
      color: color ?? this.color,
      isEscaping: isEscaping ?? this.isEscaping,
      isRemoved: isRemoved ?? this.isRemoved,
    );
  }
}
