class Prediction {
  final String label;
  final double confidence;
  final DateTime timestamp;

  Prediction({
    required this.label,
    required this.confidence,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'Prediction(label: $label, confidence: ${(confidence * 100).toStringAsFixed(1)}%, timestamp: $timestamp)';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Create a copy with modified values
  Prediction copyWith({
    String? label,
    double? confidence,
    DateTime? timestamp,
  }) {
    return Prediction(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Check if this prediction has a valid result
  bool get isValid =>
      confidence > 0.0 &&
      label.isNotEmpty &&
      label != 'Unknown' &&
      label != 'Error';

  /// Get confidence as percentage string
  String get confidencePercentage =>
      '${(confidence * 100).toStringAsFixed(1)}%';

  /// Check if prediction is recent (within last 5 minutes)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inMinutes <= 5;
  }

  /// Get formatted timestamp string
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
