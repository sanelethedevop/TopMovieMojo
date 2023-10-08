import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moviemojo/constants/appwrite_constants.dart';
import 'package:moviemojo/controller/providers.dart';

final viewsControllerProvider = Provider((ref) {
  final db = ref.watch(appwriteDatabasesProvider);
  return ViewController(db: db);
});

class ViewController {
  final Databases _db;
  ViewController({required Databases db}) : _db = db;

  Future<Map<String, dynamic>> getViewDocument() async {
    try {
      final documment = await _db.getDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.collectionId,
          documentId: AppwriteConstants.viewsDocument);
      log('${documment.data}');
      return documment.data;
    } on AppwriteException {
      throw AppwriteException();
    }
  }

  incrementViews() async {
    final Map<String, dynamic> viewsDocument = await getViewDocument();
    int currentViews = viewsDocument['views'];
    int newViews = currentViews + 1;
    try {
      await _db.updateDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.collectionId,
          documentId: AppwriteConstants.viewsDocument,
          data: {'views': newViews});
    } on AppwriteException {
      throw AppwriteException();
    }
  }
}
