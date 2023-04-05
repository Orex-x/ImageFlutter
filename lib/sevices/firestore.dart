import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_file_picker/models/my_image.dart';

class Firestore {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<MyImage>> getImages(String uid) {
    return _db.collection('images_$uid').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => MyImage.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> addImage(String uid, MyImage image) {
    return _db.collection('images_$uid').add(image.toMap());
  }

  void deleteImage(String uid, String idImage, String path) {
    _db.collection('images_$uid').doc(idImage).delete();

    final storageRef = FirebaseStorage.instance.ref();

    final desertRef = storageRef.child(path);

    desertRef.delete();
  }
}
