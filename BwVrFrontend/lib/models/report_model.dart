class ReportModel {
  final int reportId;
  final String referenceNumber;
  final int templateId;
  final String? templateName;
  final String reportTitle;
  final String? vendorName;
  final String? location;
  final String? bankName;
  final String reportStatus;
  final DateTime? generatedAt;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? valuesCount;
  final int? totalPlaceholders;
  final bool hasGeneratedFile;

  ReportModel({
    required this.reportId,
    required this.referenceNumber,
    required this.templateId,
    this.templateName,
    required this.reportTitle,
    this.vendorName,
    this.location,
    this.bankName,
    required this.reportStatus,
    this.generatedAt,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.valuesCount,
    this.totalPlaceholders,
    this.hasGeneratedFile = false,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      reportId: _parseInt(json['reportId']) ?? 0,
      referenceNumber: json['referenceNumber'] ?? '',
      templateId: _parseInt(json['templateId']) ?? 0,
      templateName: json['templateName'],
      reportTitle: json['reportTitle'] ?? '',
      vendorName: json['vendorName'],
      location: json['location'],
      bankName: json['bankName'],
      reportStatus: json['reportStatus'] ?? 'DRAFT',
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : null,
      createdBy: json['createdBy'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      valuesCount: _parseInt(json['valuesCount']),
      totalPlaceholders: _parseInt(json['totalPlaceholders']),
      hasGeneratedFile: json['hasGeneratedFile'] ?? false,
    );
  }

  int get completionPercentage {
    if (totalPlaceholders == null || totalPlaceholders == 0) return 0;
    final filled = valuesCount ?? 0;
    return ((filled / totalPlaceholders!) * 100).round().clamp(0, 100);
  }
}

class ReportValueModel {
  final int? valueId;
  final int placeholderId;
  final String hiddenInternalKey;
  final String questionText;
  final String inputType;
  final String? sectionName;
  String? textValue;
  String? imageFilePath;
  String? imageOriginalName;
  final int? displayOrder;
  final String? tableContext;
  final String? col1Header;
  final String? col2Header;
  final bool hasImageData;
  final bool isUserVisible;

  ReportValueModel({
    this.valueId,
    required this.placeholderId,
    required this.hiddenInternalKey,
    required this.questionText,
    required this.inputType,
    this.sectionName,
    this.textValue,
    this.imageFilePath,
    this.imageOriginalName,
    this.displayOrder,
    this.tableContext,
    this.col1Header,
    this.col2Header,
    this.hasImageData = false,
    this.isUserVisible = true,
  });

  factory ReportValueModel.fromJson(Map<String, dynamic> json) {
    return ReportValueModel(
      valueId: _parseInt(json['valueId']),
      placeholderId: _parseInt(json['placeholderId']) ?? 0,
      hiddenInternalKey: json['hiddenInternalKey'] ?? '',
      questionText: json['questionText'] ?? '',
      inputType: json['inputType'] ?? 'TEXT',
      sectionName: json['sectionName'],
      textValue: json['textValue'],
      imageFilePath: json['imageFilePath'],
      imageOriginalName: json['imageOriginalName'],
      displayOrder: _parseInt(json['displayOrder']),
      tableContext: json['tableContext'],
      col1Header: json['col1Header'],
      col2Header: json['col2Header'],
      hasImageData: json['hasImageData'] ?? false,
      isUserVisible: json['isUserVisible'] ?? true,
    );
  }

  bool get hasValue =>
      (textValue != null && textValue!.isNotEmpty) ||
      imageFilePath != null ||
      hasImageData;
  bool get isImage => inputType.toUpperCase() == 'IMAGE';
  bool get isDate => inputType.toUpperCase() == 'DATE';
  bool get isInTable => tableContext != null && tableContext!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'placeholderId': placeholderId,
        'placeholderKey': hiddenInternalKey,
        'textValue': textValue,
        'imageFilePath': imageFilePath,
        'imageOriginalName': imageOriginalName,
        'hasImageData': hasImageData,
      };
}

class ReportDetailModel extends ReportModel {
  final List<ReportValueModel> values;
  final String? templateFileName;
  final String? updatedBy;

  ReportDetailModel({
    required super.reportId,
    required super.referenceNumber,
    required super.templateId,
    super.templateName,
    required super.reportTitle,
    super.vendorName,
    super.location,
    super.bankName,
    required super.reportStatus,
    super.generatedAt,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
    super.valuesCount,
    super.totalPlaceholders,
    super.hasGeneratedFile,
    required this.values,
    this.templateFileName,
    this.updatedBy,
  });

  factory ReportDetailModel.fromJson(Map<String, dynamic> json) {
    return ReportDetailModel(
      reportId: _parseInt(json['reportId']) ?? 0,
      referenceNumber: json['referenceNumber'] ?? '',
      templateId: _parseInt(json['templateId']) ?? 0,
      templateName: json['templateName'],
      reportTitle: json['reportTitle'] ?? '',
      vendorName: json['vendorName'],
      location: json['location'],
      bankName: json['bankName'],
      reportStatus: json['reportStatus'] ?? 'DRAFT',
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : null,
      createdBy: json['createdBy'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      valuesCount: _parseInt(json['valuesCount']),
      totalPlaceholders: _parseInt(json['totalPlaceholders']),
      hasGeneratedFile: json['hasGeneratedFile'] ?? false,
      values: (json['values'] as List? ?? [])
          .map((v) => ReportValueModel.fromJson(v))
          .toList(),
      templateFileName: json['templateFileName'],
      updatedBy: json['updatedBy'],
    );
  }

  @override
  int get completionPercentage {
    if (values.isEmpty) return super.completionPercentage;
    final visibleValues = values.where((v) => v.isUserVisible).toList();
    if (visibleValues.isEmpty) return 100;
    final filled = visibleValues.where((v) => v.hasValue).length;
    return ((filled / visibleValues.length) * 100).round().clamp(0, 100);
  }
}

class DashboardStats {
  final int totalReports;
  final int reportsThisMonth;
  final int activeTemplates;
  final int distinctBanks;

  DashboardStats({
    required this.totalReports,
    required this.reportsThisMonth,
    required this.activeTemplates,
    required this.distinctBanks,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalReports: _parseInt(json['totalReports']) ?? 0,
      reportsThisMonth: _parseInt(json['reportsThisMonth']) ?? 0,
      activeTemplates: _parseInt(json['activeTemplates']) ?? 0,
      distinctBanks: _parseInt(json['distinctBanks']) ?? 0,
    );
  }
}

int? _parseInt(dynamic raw) {
  if (raw == null) return null;
  return raw is int ? raw : int.tryParse(raw.toString());
}
