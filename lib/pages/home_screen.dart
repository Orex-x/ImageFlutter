import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_picker/models/my_image.dart';

import '../sevices/firestore.dart';
import 'account_screen.dart';
import 'login_screen.dart';

import 'package:http/http.dart' as http;

import 'view_image_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PlatformFile? pickedFile;
  final _firestoreService = Firestore();
  UploadTask? uploadTask;
  final user = FirebaseAuth.instance.currentUser;
  List<MyImage> images = [];

  Future<void> initImage() async {
    if (user == null) return;

    images.clear();
    // final storageRef =
    //     FirebaseStorage.instance.ref().child("files/${user!.email}");

    // final listResult = await storageRef.listAll();
    // for (var prefix in listResult.prefixes) {
    //   // The prefixes under storageRef.
    //   // You can call listAll() recursively on them.
    // }
    // for (var item in listResult.items) {
    //   // The items under storageRef.
    // }
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });

    final path = 'files/${user!.email}/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() => {});

    final urlDownload = await snapshot.ref.getDownloadURL();

    _firestoreService.addImage(
        user!.email ?? '',
        MyImage(
            id: '',
            name: pickedFile!.name,
            link: urlDownload,
            size: pickedFile!.size));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Главная страница'),
        actions: [
          if (user != null)
            IconButton(
              onPressed: selectFile,
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          IconButton(
            onPressed: () {
              if ((user == null)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountScreen()),
                );
              }
            },
            icon: Icon(
              Icons.person,
              color: (user == null) ? Colors.white : Colors.yellow,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: (user == null) ? _withOutAuthContent() : _withAuthContent(),
        ),
      ),
    );
  }

  Widget _withOutAuthContent() => Container(
        child: Text('Вы не зарегестрированы'),
      );

  Widget _withAuthContent() => StreamBuilder<List<MyImage>>(
        stream: _firestoreService.getImages(user!.email ?? ''),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final images = snapshot.data!;

            if (snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            image.name,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            image.size.toString(),
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (user != null)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ViewImage(link: image.link);
                                        },
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.remove_red_eye_rounded,
                                    color: Colors.green,
                                  ),
                                ),
                              const SizedBox(width: 16.0),
                              GestureDetector(
                                onTap: () {
                                  _firestoreService.deleteImage(
                                      user!.email ?? '', image.id, 'files/${user!.email}/${image.name}');
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text("No Data Found"));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
}
