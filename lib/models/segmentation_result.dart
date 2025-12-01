/// Lesion Segmentation Models
/// Pixel-level identification and delineation using U-Net with attention

import 'dart:typed_data';
import 'dart:ui';

class SegmentedLesion {
  /// Unique identifier for this lesion
  final String id;
  
  /// Bounding box coordinates [x, y, width, height]
  final Rect boundingBox;
  
  /// Pixel mask for precise segmentation
  final Uint8List? mask;
  
  /// Area in pixels
  final int areaPixels;
  
  /// Area as percentage of total image
  final double areaPercentage;
  
  /// Centroid coordinates
  final Offset centroid;
  
  /// Perimeter length in pixels
  final double perimeter;
  
  /// Circularity score (1.0 = perfect circle)
  final double circularity;
  
  /// Confidence score for this segmentation
  final double confidence;

  SegmentedLesion({
    required this.id,
    required this.boundingBox,
    this.mask,
    required this.areaPixels,
    required this.areaPercentage,
    required this.centroid,
    required this.perimeter,
    required this.circularity,
    required this.confidence,
  });

  /// Check if lesion overlaps with another (for confluence detection)
  bool overlapsWith(SegmentedLesion other, {double threshold = 0.1}) {
    if (!boundingBox.overlaps(other.boundingBox)) return false;
    
    Rect intersection = boundingBox.intersect(other.boundingBox);
    double intersectionArea = intersection.width * intersection.height;
    double unionArea = (boundingBox.width * boundingBox.height) +
        (other.boundingBox.width * other.boundingBox.height) -
        intersectionArea;
    
    return (intersectionArea / unionArea) >= threshold;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'boundingBox': {
      'left': boundingBox.left,
      'top': boundingBox.top,
      'width': boundingBox.width,
      'height': boundingBox.height,
    },
    'areaPixels': areaPixels,
    'areaPercentage': areaPercentage,
    'centroid': {'x': centroid.dx, 'y': centroid.dy},
    'perimeter': perimeter,
    'circularity': circularity,
    'confidence': confidence,
  };
}

enum BodyRegion {
  face,
  scalp,
  neck,
  chest,
  back,
  abdomen,
  upperArmLeft,
  upperArmRight,
  forearmLeft,
  forearmRight,
  handLeft,
  handRight,
  genital,
  buttocks,
  thighLeft,
  thighRight,
  lowerLegLeft,
  lowerLegRight,
  footLeft,
  footRight,
  oral,
  unknown,
}

extension BodyRegionExtension on BodyRegion {
  String get displayName {
    switch (this) {
      case BodyRegion.face: return 'Face';
      case BodyRegion.scalp: return 'Scalp';
      case BodyRegion.neck: return 'Neck';
      case BodyRegion.chest: return 'Chest';
      case BodyRegion.back: return 'Back';
      case BodyRegion.abdomen: return 'Abdomen';
      case BodyRegion.upperArmLeft: return 'Upper Arm (Left)';
      case BodyRegion.upperArmRight: return 'Upper Arm (Right)';
      case BodyRegion.forearmLeft: return 'Forearm (Left)';
      case BodyRegion.forearmRight: return 'Forearm (Right)';
      case BodyRegion.handLeft: return 'Hand (Left)';
      case BodyRegion.handRight: return 'Hand (Right)';
      case BodyRegion.genital: return 'Genital Area';
      case BodyRegion.buttocks: return 'Buttocks';
      case BodyRegion.thighLeft: return 'Thigh (Left)';
      case BodyRegion.thighRight: return 'Thigh (Right)';
      case BodyRegion.lowerLegLeft: return 'Lower Leg (Left)';
      case BodyRegion.lowerLegRight: return 'Lower Leg (Right)';
      case BodyRegion.footLeft: return 'Foot (Left)';
      case BodyRegion.footRight: return 'Foot (Right)';
      case BodyRegion.oral: return 'Oral/Mucosal';
      case BodyRegion.unknown: return 'Unknown';
    }
  }

  bool get isMucosal => this == BodyRegion.oral || this == BodyRegion.genital;
}

class SegmentationResult {
  /// List of all segmented lesions
  final List<SegmentedLesion> lesions;
  
  /// Full segmentation mask for the image
  final Uint8List? fullMask;
  
  /// Original image dimensions
  final Size imageSize;
  
  /// Total lesion count
  final int lesionCount;
  
  /// Lesions grouped by detected region
  final Map<BodyRegion, List<SegmentedLesion>> lesionsByRegion;
  
  /// Confluence score (0.0 - 1.0)
  final double confluenceScore;
  
  /// Number of confluent lesion groups
  final int confluentGroups;
  
  /// Total affected area percentage
  final double totalAffectedAreaPercent;
  
  /// Processing timestamp
  final DateTime timestamp;
  
  /// Model version used
  final String? modelVersion;

  SegmentationResult({
    required this.lesions,
    this.fullMask,
    required this.imageSize,
    required this.lesionCount,
    required this.lesionsByRegion,
    required this.confluenceScore,
    required this.confluentGroups,
    required this.totalAffectedAreaPercent,
    required this.timestamp,
    this.modelVersion,
  });

  /// Get lesions sorted by area (largest first)
  List<SegmentedLesion> get lesionsBySize {
    var sorted = List<SegmentedLesion>.from(lesions);
    sorted.sort((a, b) => b.areaPixels.compareTo(a.areaPixels));
    return sorted;
  }

  /// Get count per region
  Map<BodyRegion, int> get countByRegion {
    return lesionsByRegion.map((k, v) => MapEntry(k, v.length));
  }

  /// Check if mucosal involvement is present
  bool get hasMucosalInvolvement {
    return lesionsByRegion.keys.any((region) => region.isMucosal);
  }

  /// Calculate distribution score across body regions
  double get distributionScore {
    int regionsAffected = lesionsByRegion.length;
    int totalRegions = BodyRegion.values.length - 1; // Exclude unknown
    return regionsAffected / totalRegions;
  }

  Map<String, dynamic> toJson() => {
    'lesions': lesions.map((l) => l.toJson()).toList(),
    'imageSize': {'width': imageSize.width, 'height': imageSize.height},
    'lesionCount': lesionCount,
    'lesionsByRegion': lesionsByRegion.map(
      (k, v) => MapEntry(k.name, v.map((l) => l.id).toList()),
    ),
    'confluenceScore': confluenceScore,
    'confluentGroups': confluentGroups,
    'totalAffectedAreaPercent': totalAffectedAreaPercent,
    'timestamp': timestamp.toIso8601String(),
    'modelVersion': modelVersion,
  };
}
