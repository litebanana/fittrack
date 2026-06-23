import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProgressPhoto({
    required String userId,
    required File file,
    required String photoType,
    required String photoId,
  }) async {
    final ref = _storage
        .ref()
        .child(AppConstants.progressPhotosPath)
        .child(userId)
        .child('${photoType}_$photoId.jpg');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> uploadProfilePhoto({
    required String userId,
    required File file,
  }) async {
    final ref = _storage
        .ref()
        .child('profile_photos')
        .child('$userId.jpg');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      // File might not exist
    }
  }
}
