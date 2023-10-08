import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/appwrite_constants.dart';

final appwriteClientProvider = Provider((ref) {
  final Client client = Client()
      .setEndpoint(AppwriteConstants.appwriteEndpoint)
      .setProject(AppwriteConstants.projectId);
  return client;
});

final appwriteDatabasesProvider = Provider((ref) {
  final Databases databases = Databases(ref.watch(appwriteClientProvider));
  return databases;
});
