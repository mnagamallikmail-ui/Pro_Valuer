class TemplateModel {
  final int templateId;
  final String bankName;
  final String templateName;
  final String templateFileName;
  final String templateVersion;
  final String parsedStatus;
  final String isActive;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? placeholderCount;

  TemplateModel({
    required this.templateId,
    required this.bankName,
    required this.templateName,
    required this.templateFileName,
    required this.templateVersion,
    required this.parsedStatus,
    required this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.placeholderCount,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      templateId: _parseInt(json['templateId']) ?? 0,
      bankName: json['bankName'] ?? '',
      templateName: json['templateName'] ?? '',
      templateFileName: json['templateFileName'] ?? '',
      templateVersion: json['templateVersion'] ?? '1.0',
      parsedStatus: json['parsedStatus'] ?? 'PENDING',
      isActive: json['isActive'] ?? 'Y',
      createdBy: json['createdBy'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      placeholderCount: _parseInt(json['placeholderCount']),
    );
  }

  bool get isConfirmed => parsedStatus == 'CONFIRMED';
  bool get isParsed => parsedStatus == 'PARSED' || parsedStatus == 'CONFIRMED';
}

class PlaceholderModel {
  final int placeholderId;
  final int templateId;
  final String placeholderKey;
  final String placeholderPrefix;
  String displayLabel;
  String questionText;
  String fieldType;
  String isRequired;
  final String? sectionName;
  final int? displayOrder;
  final String? tableContext;
  final String? col1Header;
  final String? col2Header;
  final String isConfirmed;
  final double? widthInches;
  final double? heightInches;
  final String? pagePosition;

  PlaceholderModel({
    required this.placeholderId,
    required this.templateId,
    required this.placeholderKey,
    required this.placeholderPrefix,
    required this.displayLabel,
    required this.questionText,
    required this.fieldType,
    required this.isRequired,
    this.sectionName,
    this.displayOrder,
    this.tableContext,
    this.col1Header,
    this.col2Header,
    required this.isConfirmed,
    this.widthInches,
    this.heightInches,
    this.pagePosition,
  });

  factory PlaceholderModel.fromJson(Map<String, dynamic> json) {
    return PlaceholderModel(
      placeholderId: _parseInt(json['placeholderId']) ?? 0,
      templateId: _parseInt(json['templateId']) ?? 0,
      placeholderKey: json['placeholderKey'] ?? '',
      placeholderPrefix: json['placeholderPrefix'] ?? 'TEXT',
      displayLabel: json['displayLabel'] ?? '',
      questionText: json['questionText'] ?? '',
      fieldType: json['fieldType'] ?? 'TEXT',
      isRequired: json['isRequired'] ?? 'Y',
      sectionName: json['sectionName'],
      displayOrder: _parseInt(json['displayOrder']),
      tableContext: json['tableContext'],
      col1Header: json['col1Header'],
      col2Header: json['col2Header'],
      isConfirmed: json['isConfirmed'] ?? 'N',
      widthInches: _parseDouble(json['widthInches']),
      heightInches: _parseDouble(json['heightInches']),
      pagePosition: json['pagePosition'],
    );
  }

  bool get isImage => placeholderPrefix == 'IMG';
  bool get isDate => placeholderPrefix == 'DATE';
  bool get isInTable => tableContext != null && tableContext!.isNotEmpty;
}

class ParsedTemplateResponse {
  final int templateId;
  final String bankName;
  final String templateName;
  final String parsedStatus;
  final List<PlaceholderModel> placeholders;
  final int totalPlaceholders;
  final int textCount;
  final int dateCount;
  final int imageCount;

  ParsedTemplateResponse({
    required this.templateId,
    required this.bankName,
    required this.templateName,
    required this.parsedStatus,
    required this.placeholders,
    required this.totalPlaceholders,
    required this.textCount,
    required this.dateCount,
    required this.imageCount,
  });

  factory ParsedTemplateResponse.fromJson(Map<String, dynamic> json) {
    return ParsedTemplateResponse(
      templateId: _parseInt(json['templateId']) ?? 0,
      bankName: json['bankName'] ?? '',
      templateName: json['templateName'] ?? '',
      parsedStatus: json['parsedStatus'] ?? 'PARSED',
      placeholders: (json['placeholders'] as List? ?? [])
          .map((p) => PlaceholderModel.fromJson(p))
          .toList(),
      totalPlaceholders: _parseInt(json['totalPlaceholders']) ?? 0,
      textCount: _parseInt(json['textCount']) ?? 0,
      dateCount: _parseInt(json['dateCount']) ?? 0,
      imageCount: _parseInt(json['imageCount']) ?? 0,
    );
  }
}

int? _parseInt(dynamic raw) {
  if (raw == null) return null;
  return raw is int ? raw : int.tryParse(raw.toString());
}

double? _parseDouble(dynamic raw) {
  if (raw == null) return null;
  if (raw is double) return raw;
  if (raw is int) return raw.toDouble();
  return double.tryParse(raw.toString());
}
