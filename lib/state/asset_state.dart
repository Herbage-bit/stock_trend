import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/asset_record.dart';

class AssetState extends ChangeNotifier {
  List<AssetRecord> records = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AssetState() {
    _init();
  }

  void _init() {
    final today = '${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}';
    
    _firestore.collection('assets').snapshots().listen((snapshot) {
      final allRecords = snapshot.docs.map((doc) => AssetRecord.fromJson(doc.data())).toList();
      // dedup：同一 date 只保留一筆
      final seen = <String>{};
      records = allRecords.where((r) => seen.add(r.date)).toList();

      if (!records.any((r) => r.date == today)) {
        addDate(today);
      } else {
        records.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    }, onError: (error) {
      debugPrint("Error fetching assets: $error");
    });
  }

  Future<void> saveRecord(AssetRecord record) async {
    final docId = record.date.replaceAll('/', '-');
    await _firestore.collection('assets').doc(docId).set(record.toJson());
  }

  Future<void> addDate(String dateStr) async {
    final docId = dateStr.replaceAll('/', '-');
    final docRef = _firestore.collection('assets').doc(docId);
    final doc = await docRef.get();
    
    if (!doc.exists) {
      await docRef.set(AssetRecord(date: dateStr).toJson());
    }
  }
}
