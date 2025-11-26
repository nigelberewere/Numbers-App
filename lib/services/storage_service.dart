import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadReceipt(String userId, String transactionId, File file) async {
    try {
      final ref = _storage
          .ref()
          .child('users/$userId/receipts/$transactionId.jpg');
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> deleteReceipt(String userId, String transactionId) async {
    try {
      final ref = _storage
          .ref()
          .child('users/$userId/receipts/$transactionId.jpg');
      await ref.delete();
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }
  
  Future<String?> uploadAttachment(String userId, String path, File file) async {
    try {
      final fileName = file.path.split('/').last;
      final ref = _storage
          .ref()
          .child('users/$userId/$path/$fileName');
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }
}
