import 'dart:io';

class FoodEntry {
  final String id;
  final String name;
  final String quantity;
  final int calories;
  final DateTime timestamp;
  final File? image;

  FoodEntry({
    required this.id,
    required this.name,
    required this.quantity,
    required this.calories,
    required this.timestamp,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'calories': calories,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'imagePath': image?.path,
    };
  }

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      calories: json['calories'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      image: json['imagePath'] != null ? File(json['imagePath']) : null,
    );
  }
}