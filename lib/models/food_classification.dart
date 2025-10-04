class FoodClassification {
  final String label;
  final double confidence;

  FoodClassification({required this.label, required this.confidence});

  @override
  String toString() {
    return 'FoodClassification(label: $label, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'label': label, 'confidence': confidence};
  }

  /// Create from JSON
  factory FoodClassification.fromJson(Map<String, dynamic> json) {
    return FoodClassification(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  /// Create a copy with modified values
  FoodClassification copyWith({String? label, double? confidence}) {
    return FoodClassification(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
    );
  }

  /// Check if this classification has a valid result
  bool get isValid =>
      confidence > 0.0 &&
      label.isNotEmpty &&
      label != 'Unknown' &&
      label != 'Error';

  /// Get confidence as percentage string
  String get confidencePercentage =>
      '${(confidence * 100).toStringAsFixed(1)}%';
}
