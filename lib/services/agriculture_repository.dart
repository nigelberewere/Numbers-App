import '../models/models.dart';

/// Abstract repository interface for Agriculture data
/// Backend developer should implement this with Firebase
abstract class AgricultureRepository {
  /// Get all agriculture records
  Future<List<AgricultureRecord>> getAllRecords();

  /// Get records by type (crop, livestock, horticulture)
  Future<List<AgricultureRecord>> getRecordsByType(AgricultureType type);

  /// Get active records only
  Future<List<AgricultureRecord>> getActiveRecords();

  /// Get a single record by ID
  Future<AgricultureRecord?> getRecordById(String id);

  /// Add a new agriculture record
  Future<void> addRecord(AgricultureRecord record);

  /// Update an existing record
  Future<void> updateRecord(AgricultureRecord record);

  /// Delete a record
  Future<void> deleteRecord(String id);

  /// Get total investment across all projects
  Future<double> getTotalInvestment();

  /// Get total revenue across all projects
  Future<double> getTotalRevenue();

  /// Get overall ROI
  Future<double> getOverallROI();

  // Livestock-specific methods
  
  /// Get all livestock records
  Future<List<LivestockRecord>> getAllLivestockRecords();

  /// Get livestock records by animal type
  Future<List<LivestockRecord>> getLivestockByType(AnimalType type);

  /// Add a new livestock record
  Future<void> addLivestockRecord(LivestockRecord record);

  /// Update a livestock record
  Future<void> updateLivestockRecord(LivestockRecord record);

  /// Delete a livestock record
  Future<void> deleteLivestockRecord(String id);

  // Crop-specific methods
  
  /// Get all crop records
  Future<List<CropRecord>> getAllCropRecords();

  /// Get crop records by type
  Future<List<CropRecord>> getCropsByType(CropType type);

  /// Get crops by season/date range
  Future<List<CropRecord>> getCropsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Add a new crop record
  Future<void> addCropRecord(CropRecord record);

  /// Update a crop record
  Future<void> updateCropRecord(CropRecord record);

  /// Delete a crop record
  Future<void> deleteCropRecord(String id);
}
