import 'package:cloud_firestore/cloud_firestore.dart';

/// A named set of measurements stored at
/// `users/{uid}/measurements/{profileId}` — e.g. "My measurements", "Father".
class MeasurementProfile {
  const MeasurementProfile({
    required this.id,
    required this.label,
    this.values = const {},
    this.notes = '',
    this.updatedAt,
  });

  final String id;

  /// Display label, e.g. "Wedding measurements".
  final String label;

  /// Keyed by [MeasurementField] name; values in centimeters (kg for weight).
  final Map<String, double> values;
  final String notes;
  final DateTime? updatedAt;

  factory MeasurementProfile.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const {};
    return MeasurementProfile(
      id: doc.id,
      label: d['label'] as String? ?? '',
      values: (d['values'] as Map<String, dynamic>? ?? const {})
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      notes: d['notes'] as String? ?? '',
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'label': label,
        'values': values,
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

/// The standard measurement fields captured in the measurement module.
enum MeasurementField {
  height,
  weight,
  chest,
  waist,
  hip,
  shoulder,
  sleeve,
  neck,
  armLength,
  thigh,
  knee,
  ankle,
}

extension MeasurementFieldX on MeasurementField {
  String get label => switch (this) {
        MeasurementField.height => 'Height',
        MeasurementField.weight => 'Weight',
        MeasurementField.chest => 'Chest',
        MeasurementField.waist => 'Waist',
        MeasurementField.hip => 'Hip',
        MeasurementField.shoulder => 'Shoulder',
        MeasurementField.sleeve => 'Sleeve',
        MeasurementField.neck => 'Neck',
        MeasurementField.armLength => 'Arm length',
        MeasurementField.thigh => 'Thigh',
        MeasurementField.knee => 'Knee',
        MeasurementField.ankle => 'Ankle',
      };

  String get unit => this == MeasurementField.weight ? 'kg' : 'cm';
}
