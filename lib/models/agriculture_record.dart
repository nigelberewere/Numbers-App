enum AgricultureType {
  animalHusbandry,
  cropProduction,
  horticulture,
}

enum AnimalType {
  cattle,
  goats,
  sheep,
  poultry,
  pigs,
  rabbits,
  fish,
  other,
}

enum CropType {
  maize,
  wheat,
  rice,
  beans,
  cassava,
  potato,
  vegetables,
  other,
}

class AgricultureRecord {
  final String id;
  final AgricultureType type;
  final String name;
  final DateTime startDate;
  final DateTime? harvestDate;
  final double area; // in acres/hectares
  final String? location;
  final double investmentCost;
  final double? revenue;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  AgricultureRecord({
    required this.id,
    required this.type,
    required this.name,
    required this.startDate,
    this.harvestDate,
    required this.area,
    this.location,
    required this.investmentCost,
    this.revenue,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  double get profit => (revenue ?? 0) - investmentCost;
  double get roi => investmentCost > 0 ? ((profit / investmentCost) * 100) : 0;

  String get typeName {
    switch (type) {
      case AgricultureType.animalHusbandry:
        return 'Animal Husbandry';
      case AgricultureType.cropProduction:
        return 'Crop Production';
      case AgricultureType.horticulture:
        return 'Horticulture';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'harvestDate': harvestDate?.toIso8601String(),
      'area': area,
      'location': location,
      'investmentCost': investmentCost,
      'revenue': revenue,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory AgricultureRecord.fromMap(Map<String, dynamic> map) {
    return AgricultureRecord(
      id: map['id'],
      type: AgricultureType.values[map['type']],
      name: map['name'],
      startDate: DateTime.parse(map['startDate']),
      harvestDate: map['harvestDate'] != null 
          ? DateTime.parse(map['harvestDate']) 
          : null,
      area: map['area'],
      location: map['location'],
      investmentCost: map['investmentCost'],
      revenue: map['revenue'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
      isActive: map['isActive'] == 1,
    );
  }

  AgricultureRecord copyWith({
    String? id,
    AgricultureType? type,
    String? name,
    DateTime? startDate,
    DateTime? harvestDate,
    double? area,
    String? location,
    double? investmentCost,
    double? revenue,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return AgricultureRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      harvestDate: harvestDate ?? this.harvestDate,
      area: area ?? this.area,
      location: location ?? this.location,
      investmentCost: investmentCost ?? this.investmentCost,
      revenue: revenue ?? this.revenue,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'AgricultureRecord{id: $id, name: $name, type: $typeName, profit: $profit}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgricultureRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Animal-specific record
class LivestockRecord {
  final String id;
  final AnimalType animalType;
  final int quantity;
  final double unitPrice;
  final DateTime purchaseDate;
  final DateTime? saleDate;
  final double? salePrice;
  final String? healthStatus;
  final String? notes;
  final DateTime createdAt;

  LivestockRecord({
    required this.id,
    required this.animalType,
    required this.quantity,
    required this.unitPrice,
    required this.purchaseDate,
    this.saleDate,
    this.salePrice,
    this.healthStatus,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalInvestment => quantity * unitPrice;
  double get totalRevenue => salePrice ?? 0;
  double get profit => totalRevenue - totalInvestment;

  String get animalTypeName {
    switch (animalType) {
      case AnimalType.cattle:
        return 'Cattle';
      case AnimalType.goats:
        return 'Goats';
      case AnimalType.sheep:
        return 'Sheep';
      case AnimalType.poultry:
        return 'Poultry';
      case AnimalType.pigs:
        return 'Pigs';
      case AnimalType.rabbits:
        return 'Rabbits';
      case AnimalType.fish:
        return 'Fish';
      case AnimalType.other:
        return 'Other';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalType': animalType.index,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'purchaseDate': purchaseDate.toIso8601String(),
      'saleDate': saleDate?.toIso8601String(),
      'salePrice': salePrice,
      'healthStatus': healthStatus,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LivestockRecord.fromMap(Map<String, dynamic> map) {
    return LivestockRecord(
      id: map['id'],
      animalType: AnimalType.values[map['animalType']],
      quantity: map['quantity'],
      unitPrice: map['unitPrice'],
      purchaseDate: DateTime.parse(map['purchaseDate']),
      saleDate: map['saleDate'] != null 
          ? DateTime.parse(map['saleDate']) 
          : null,
      salePrice: map['salePrice'],
      healthStatus: map['healthStatus'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

// Crop-specific record
class CropRecord {
  final String id;
  final CropType cropType;
  final String cropName;
  final double area; // acres/hectares
  final DateTime plantingDate;
  final DateTime? harvestDate;
  final double expectedYield;
  final double? actualYield;
  final String? yieldUnit; // kg, tons, bags
  final double seedCost;
  final double fertilizerCost;
  final double laborCost;
  final double? sellingPrice;
  final String? notes;
  final DateTime createdAt;

  CropRecord({
    required this.id,
    required this.cropType,
    required this.cropName,
    required this.area,
    required this.plantingDate,
    this.harvestDate,
    required this.expectedYield,
    this.actualYield,
    this.yieldUnit,
    required this.seedCost,
    required this.fertilizerCost,
    required this.laborCost,
    this.sellingPrice,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalCost => seedCost + fertilizerCost + laborCost;
  double get totalRevenue => (actualYield ?? 0) * (sellingPrice ?? 0);
  double get profit => totalRevenue - totalCost;

  String get cropTypeName {
    switch (cropType) {
      case CropType.maize:
        return 'Maize';
      case CropType.wheat:
        return 'Wheat';
      case CropType.rice:
        return 'Rice';
      case CropType.beans:
        return 'Beans';
      case CropType.cassava:
        return 'Cassava';
      case CropType.potato:
        return 'Potato';
      case CropType.vegetables:
        return 'Vegetables';
      case CropType.other:
        return 'Other';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropType': cropType.index,
      'cropName': cropName,
      'area': area,
      'plantingDate': plantingDate.toIso8601String(),
      'harvestDate': harvestDate?.toIso8601String(),
      'expectedYield': expectedYield,
      'actualYield': actualYield,
      'yieldUnit': yieldUnit,
      'seedCost': seedCost,
      'fertilizerCost': fertilizerCost,
      'laborCost': laborCost,
      'sellingPrice': sellingPrice,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CropRecord.fromMap(Map<String, dynamic> map) {
    return CropRecord(
      id: map['id'],
      cropType: CropType.values[map['cropType']],
      cropName: map['cropName'],
      area: map['area'],
      plantingDate: DateTime.parse(map['plantingDate']),
      harvestDate: map['harvestDate'] != null 
          ? DateTime.parse(map['harvestDate']) 
          : null,
      expectedYield: map['expectedYield'],
      actualYield: map['actualYield'],
      yieldUnit: map['yieldUnit'],
      seedCost: map['seedCost'],
      fertilizerCost: map['fertilizerCost'],
      laborCost: map['laborCost'],
      sellingPrice: map['sellingPrice'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
