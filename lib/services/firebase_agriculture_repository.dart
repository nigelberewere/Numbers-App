import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'agriculture_repository.dart';

class FirebaseAgricultureRepository implements AgricultureRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  FirebaseAgricultureRepository({required this.userId});

  // Collection References
  CollectionReference get _agricultureCollection =>
      _firestore.collection('users').doc(userId).collection('agriculture');

  CollectionReference get _livestockCollection =>
      _firestore.collection('users').doc(userId).collection('livestock');

  CollectionReference get _cropsCollection =>
      _firestore.collection('users').doc(userId).collection('crops');

  // --- Agriculture Records ---

  @override
  Future<List<AgricultureRecord>> getAllRecords() async {
    final snapshot =
        await _agricultureCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => AgricultureRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AgricultureRecord>> getRecordsByType(AgricultureType type) async {
    final snapshot = await _agricultureCollection
        .where('type', isEqualTo: type.index)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => AgricultureRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AgricultureRecord>> getActiveRecords() async {
    final snapshot = await _agricultureCollection
        .where('isActive', isEqualTo: 1)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => AgricultureRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AgricultureRecord?> getRecordById(String id) async {
    final doc = await _agricultureCollection.doc(id).get();
    if (!doc.exists) return null;
    return AgricultureRecord.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> addRecord(AgricultureRecord record) async {
    await _agricultureCollection.doc(record.id).set(record.toMap());
  }

  @override
  Future<void> updateRecord(AgricultureRecord record) async {
    await _agricultureCollection.doc(record.id).update(
          record.copyWith(updatedAt: DateTime.now()).toMap(),
        );
  }

  @override
  Future<void> deleteRecord(String id) async {
    await _agricultureCollection.doc(id).delete();
  }

  @override
  Future<double> getTotalInvestment() async {
    final records = await getAllRecords();
    return records.fold<double>(0.0, (prev, record) => prev + record.investmentCost);
  }

  @override
  Future<double> getTotalRevenue() async {
    final records = await getAllRecords();
    return records.fold<double>(0.0, (prev, record) => prev + (record.revenue ?? 0));
  }

  @override
  Future<double> getOverallROI() async {
    final investment = await getTotalInvestment();
    final revenue = await getTotalRevenue();
    if (investment == 0) return 0;
    return ((revenue - investment) / investment) * 100;
  }

  // --- Livestock Records ---

  @override
  Future<List<LivestockRecord>> getAllLivestockRecords() async {
    final snapshot =
        await _livestockCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => LivestockRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<LivestockRecord>> getLivestockByType(AnimalType type) async {
    final snapshot = await _livestockCollection
        .where('animalType', isEqualTo: type.index)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => LivestockRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addLivestockRecord(LivestockRecord record) async {
    await _livestockCollection.doc(record.id).set(record.toMap());
  }

  @override
  Future<void> updateLivestockRecord(LivestockRecord record) async {
    await _livestockCollection.doc(record.id).update(record.toMap());
  }

  @override
  Future<void> deleteLivestockRecord(String id) async {
    await _livestockCollection.doc(id).delete();
  }

  // --- Crop Records ---

  @override
  Future<List<CropRecord>> getAllCropRecords() async {
    final snapshot =
        await _cropsCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => CropRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CropRecord>> getCropsByType(CropType type) async {
    final snapshot = await _cropsCollection
        .where('cropType', isEqualTo: type.index)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => CropRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CropRecord>> getCropsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _cropsCollection
        .where('plantingDate', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('plantingDate', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('plantingDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => CropRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addCropRecord(CropRecord record) async {
    await _cropsCollection.doc(record.id).set(record.toMap());
  }

  @override
  Future<void> updateCropRecord(CropRecord record) async {
    await _cropsCollection.doc(record.id).update(record.toMap());
  }

  @override
  Future<void> deleteCropRecord(String id) async {
    await _cropsCollection.doc(id).delete();
  }
}
