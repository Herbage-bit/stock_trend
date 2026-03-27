class AssetRecord {
  String date;
  double sinoStockPv, sinoStockCost, sinoBondPv, sinoBondCost;
  double skisStockPv, skisStockCost, skisBondPv, skisBondCost;
  double totalCash;

  AssetRecord({
    required this.date,
    this.sinoStockPv = 0,
    this.sinoStockCost = 0,
    this.sinoBondPv = 0,
    this.sinoBondCost = 0,
    this.skisStockPv = 0,
    this.skisStockCost = 0,
    this.skisBondPv = 0,
    this.skisBondCost = 0,
    this.totalCash = 0,
  });

  factory AssetRecord.fromJson(Map<String, dynamic> json) {
    return AssetRecord(
      date: json['date'] as String? ?? '',
      sinoStockPv: (json['sinoStockPv'] ?? 0).toDouble(),
      sinoStockCost: (json['sinoStockCost'] ?? 0).toDouble(),
      sinoBondPv: (json['sinoBondPv'] ?? 0).toDouble(),
      sinoBondCost: (json['sinoBondCost'] ?? 0).toDouble(),
      skisStockPv: (json['skisStockPv'] ?? 0).toDouble(),
      skisStockCost: (json['skisStockCost'] ?? 0).toDouble(),
      skisBondPv: (json['skisBondPv'] ?? 0).toDouble(),
      skisBondCost: (json['skisBondCost'] ?? 0).toDouble(),
      totalCash: (json['totalCash'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'sinoStockPv': sinoStockPv,
      'sinoStockCost': sinoStockCost,
      'sinoBondPv': sinoBondPv,
      'sinoBondCost': sinoBondCost,
      'skisStockPv': skisStockPv,
      'skisStockCost': skisStockCost,
      'skisBondPv': skisBondPv,
      'skisBondCost': skisBondCost,
      'totalCash': totalCash,
    };
  }

  AssetRecord copyWith({
    String? date,
    double? sinoStockPv, double? sinoStockCost, double? sinoBondPv, double? sinoBondCost,
    double? skisStockPv, double? skisStockCost, double? skisBondPv, double? skisBondCost,
    double? totalCash,
  }) {
    return AssetRecord(
      date: date ?? this.date,
      sinoStockPv: sinoStockPv ?? this.sinoStockPv,
      sinoStockCost: sinoStockCost ?? this.sinoStockCost,
      sinoBondPv: sinoBondPv ?? this.sinoBondPv,
      sinoBondCost: sinoBondCost ?? this.sinoBondCost,
      skisStockPv: skisStockPv ?? this.skisStockPv,
      skisStockCost: skisStockCost ?? this.skisStockCost,
      skisBondPv: skisBondPv ?? this.skisBondPv,
      skisBondCost: skisBondCost ?? this.skisBondCost,
      totalCash: totalCash ?? this.totalCash,
    );
  }

  double get totalPv => sinoStockPv + skisStockPv + sinoBondPv + skisBondPv + totalCash;
  double get totalCost => sinoStockCost + skisStockCost + sinoBondCost + skisBondCost + totalCash;
}
