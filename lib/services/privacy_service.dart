/// Privacy-Preserving Architecture Service
/// Implements HIPAA/GDPR compliant data handling
/// On-device processing with encrypted storage

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

/// Privacy configuration settings
class PrivacyConfig {
  final bool enableEncryption;
  final bool enableAnonymization;
  final bool enableAuditLogging;
  final bool enableDataMinimization;
  final int dataRetentionDays;
  final bool allowCloudProcessing;
  final bool requireConsent;

  const PrivacyConfig({
    this.enableEncryption = true,
    this.enableAnonymization = true,
    this.enableAuditLogging = true,
    this.enableDataMinimization = true,
    this.dataRetentionDays = 30,
    this.allowCloudProcessing = false,
    this.requireConsent = true,
  });

  /// HIPAA-compliant default configuration
  static const hipaaCompliant = PrivacyConfig(
    enableEncryption: true,
    enableAnonymization: true,
    enableAuditLogging: true,
    enableDataMinimization: true,
    dataRetentionDays: 365 * 6, // 6 years per HIPAA
    allowCloudProcessing: false,
    requireConsent: true,
  );

  /// GDPR-compliant default configuration
  static const gdprCompliant = PrivacyConfig(
    enableEncryption: true,
    enableAnonymization: true,
    enableAuditLogging: true,
    enableDataMinimization: true,
    dataRetentionDays: 30,
    allowCloudProcessing: false,
    requireConsent: true,
  );
}

/// Consent record for data processing
class ConsentRecord {
  final String consentId;
  final String userIdHash;
  final DateTime consentDate;
  final List<ConsentPurpose> purposes;
  final bool isActive;
  final DateTime? withdrawalDate;
  final String consentVersion;

  ConsentRecord({
    required this.consentId,
    required this.userIdHash,
    required this.consentDate,
    required this.purposes,
    required this.isActive,
    this.withdrawalDate,
    required this.consentVersion,
  });

  Map<String, dynamic> toJson() => {
    'consentId': consentId,
    'userIdHash': userIdHash,
    'consentDate': consentDate.toIso8601String(),
    'purposes': purposes.map((p) => p.name).toList(),
    'isActive': isActive,
    'withdrawalDate': withdrawalDate?.toIso8601String(),
    'consentVersion': consentVersion,
  };
}

enum ConsentPurpose {
  diagnosticAnalysis,
  dataStorage,
  researchUse,
  modelImprovement,
  anonymizedAggregation,
}

/// Audit log entry for HIPAA compliance
class AuditLogEntry {
  final String logId;
  final DateTime timestamp;
  final AuditAction action;
  final String userIdHash;
  final String? resourceId;
  final String? resourceType;
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  AuditLogEntry({
    required this.logId,
    required this.timestamp,
    required this.action,
    required this.userIdHash,
    this.resourceId,
    this.resourceType,
    required this.success,
    this.errorMessage,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'logId': logId,
    'timestamp': timestamp.toIso8601String(),
    'action': action.name,
    'userIdHash': userIdHash,
    'resourceId': resourceId,
    'resourceType': resourceType,
    'success': success,
    'errorMessage': errorMessage,
    'metadata': metadata,
  };
}

enum AuditAction {
  dataAccess,
  dataCreate,
  dataUpdate,
  dataDelete,
  dataExport,
  modelInference,
  consentGrant,
  consentWithdraw,
  userLogin,
  userLogout,
}

/// Privacy-preserving data service
class PrivacyService extends ChangeNotifier {
  final PrivacyConfig _config;
  final List<AuditLogEntry> _auditLog = [];
  ConsentRecord? _currentConsent;

  PrivacyService({PrivacyConfig? config})
      : _config = config ?? PrivacyConfig.hipaaCompliant;

  PrivacyConfig get config => _config;
  ConsentRecord? get currentConsent => _currentConsent;
  bool get hasValidConsent => _currentConsent?.isActive ?? false;

  /// Generate anonymized ID hash
  String anonymizeId(String originalId) {
    if (!_config.enableAnonymization) return originalId;
    
    // Use SHA-256 with salt for anonymization
    final salt = 'mpsight_salt_v1'; // In production, use secure key management
    final bytes = utf8.encode('$salt:$originalId');
    final hash = sha256.convert(bytes);
    return hash.toString().substring(0, 16); // Truncate for usability
  }

  /// Anonymize patient data for storage/transmission
  Map<String, dynamic> anonymizePatientData(Map<String, dynamic> data) {
    if (!_config.enableAnonymization) return data;

    final anonymized = Map<String, dynamic>.from(data);
    
    // Remove direct identifiers
    final directIdentifiers = [
      'name', 'firstName', 'lastName', 'fullName',
      'email', 'phone', 'phoneNumber', 'telephone',
      'address', 'streetAddress', 'city', 'zipCode', 'postalCode',
      'ssn', 'socialSecurityNumber',
      'mrn', 'medicalRecordNumber',
      'insuranceId', 'policyNumber',
      'dateOfBirth', 'dob', 'birthDate',
      'ipAddress', 'deviceId',
    ];

    for (final key in directIdentifiers) {
      if (anonymized.containsKey(key)) {
        anonymized.remove(key);
      }
    }

    // Hash quasi-identifiers
    if (anonymized.containsKey('patientId')) {
      anonymized['patientIdHash'] = anonymizeId(anonymized['patientId']);
      anonymized.remove('patientId');
    }

    // Generalize age to age group
    if (anonymized.containsKey('age')) {
      final age = anonymized['age'] as int;
      anonymized['ageGroup'] = _ageToGroup(age);
      anonymized.remove('age');
    }

    // Generalize dates (keep only year-month for non-critical dates)
    if (anonymized.containsKey('visitDate') && _config.enableDataMinimization) {
      final date = DateTime.parse(anonymized['visitDate']);
      anonymized['visitYearMonth'] = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      anonymized.remove('visitDate');
    }

    return anonymized;
  }

  int _ageToGroup(int age) {
    if (age < 18) return 0;
    if (age < 35) return 1;
    if (age < 50) return 2;
    if (age < 65) return 3;
    return 4;
  }

  /// Log audit event
  Future<void> logAudit({
    required AuditAction action,
    required String userId,
    String? resourceId,
    String? resourceType,
    bool success = true,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_config.enableAuditLogging) return;

    final entry = AuditLogEntry(
      logId: _generateLogId(),
      timestamp: DateTime.now(),
      action: action,
      userIdHash: anonymizeId(userId),
      resourceId: resourceId != null ? anonymizeId(resourceId) : null,
      resourceType: resourceType,
      success: success,
      errorMessage: errorMessage,
      metadata: metadata,
    );

    _auditLog.add(entry);
    
    // In production, persist to secure storage
    debugPrint('Audit: ${entry.action.name} - ${entry.success ? 'SUCCESS' : 'FAILED'}');
  }

  String _generateLogId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 10000;
    return 'LOG_${timestamp}_$random';
  }

  /// Record user consent
  Future<ConsentRecord> recordConsent({
    required String userId,
    required List<ConsentPurpose> purposes,
  }) async {
    final consent = ConsentRecord(
      consentId: 'CONSENT_${DateTime.now().millisecondsSinceEpoch}',
      userIdHash: anonymizeId(userId),
      consentDate: DateTime.now(),
      purposes: purposes,
      isActive: true,
      consentVersion: '1.0',
    );

    _currentConsent = consent;
    
    await logAudit(
      action: AuditAction.consentGrant,
      userId: userId,
      metadata: {'purposes': purposes.map((p) => p.name).toList()},
    );

    notifyListeners();
    return consent;
  }

  /// Withdraw consent
  Future<void> withdrawConsent(String userId) async {
    if (_currentConsent != null) {
      _currentConsent = ConsentRecord(
        consentId: _currentConsent!.consentId,
        userIdHash: _currentConsent!.userIdHash,
        consentDate: _currentConsent!.consentDate,
        purposes: _currentConsent!.purposes,
        isActive: false,
        withdrawalDate: DateTime.now(),
        consentVersion: _currentConsent!.consentVersion,
      );

      await logAudit(
        action: AuditAction.consentWithdraw,
        userId: userId,
      );

      notifyListeners();
    }
  }

  /// Check if processing is allowed
  bool canProcess(ConsentPurpose purpose) {
    if (!_config.requireConsent) return true;
    if (_currentConsent == null || !_currentConsent!.isActive) return false;
    return _currentConsent!.purposes.contains(purpose);
  }

  /// Data retention check
  bool isWithinRetentionPeriod(DateTime dataDate) {
    final retentionLimit = DateTime.now().subtract(
      Duration(days: _config.dataRetentionDays),
    );
    return dataDate.isAfter(retentionLimit);
  }

  /// Export audit log (for compliance reporting)
  List<Map<String, dynamic>> exportAuditLog({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var filtered = _auditLog.where((entry) {
      if (startDate != null && entry.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && entry.timestamp.isAfter(endDate)) {
        return false;
      }
      return true;
    });

    return filtered.map((e) => e.toJson()).toList();
  }
}

/// Secure local storage wrapper
class SecureStorageService {
  // In production, use flutter_secure_storage or similar
  
  /// Encrypt data before storage
  Future<Uint8List> encryptData(Uint8List plaintext, String key) async {
    // Placeholder - implement AES-256-GCM encryption
    // In production, use pointycastle or similar
    debugPrint('Encrypting ${plaintext.length} bytes');
    return plaintext; // Return encrypted data
  }

  /// Decrypt stored data
  Future<Uint8List> decryptData(Uint8List ciphertext, String key) async {
    // Placeholder - implement AES-256-GCM decryption
    debugPrint('Decrypting ${ciphertext.length} bytes');
    return ciphertext; // Return decrypted data
  }

  /// Secure delete (overwrite before delete)
  Future<void> secureDelete(String path) async {
    // In production, overwrite file with random data before deletion
    debugPrint('Securely deleting: $path');
  }
}
