import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../modals/galleryuser.dart';
import 'gallery_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GalleryUser> _list = [];
  File? _image;

  @override
  void initState() {
    super.initState();
    _fetchGallery();
  }

  Future<void> _fetchGallery() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(APIs.user.uid)
          .collection('photos')
          .orderBy('uploadedAt', descending: true)
          .get();

      final fetchedList = snapshot.docs
          .map((doc) => GalleryUser.fromJson(doc.data()))
          .toList();

      setState(() {
        _list = fetchedList;
      });
    } catch (e) {
      print('Error fetching gallery data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch gallery data.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
      _uploadImageToFirebase();
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_image == null) return;

    final userId = APIs.user.uid;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = FirebaseStorage.instance.ref().child('gallery/$userId/$fileName');

    try {
      final uploadTask = await storageRef.putFile(_image!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).collection('photos').add({
        'image': downloadUrl,
        'uploadedAt': Timestamp.now(),
        'name': APIs.me.name,
        'email': APIs.me.email,
      });

      setState(() {
        _image = null;
      });

      // Refresh gallery to reflect the new image
      await _fetchGallery();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image Uploaded Successfully!')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image.')),
      );
    }
  }

  Future<void> _refreshGallery() async {
    await _fetchGallery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APIs.hexToColor('#293d3d'),
      appBar: AppBar(
        title: const Text('Gallery'),
        leading: const Icon(Icons.home, size: 28, color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add_a_photo),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGallery,
        child: _list.isEmpty
            ? const Center(
          child: Text(
            "No Photos Uploaded!",
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
        )
            : GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3 / 4,
          ),
          itemCount: _list.length,
          itemBuilder: (context, index) {
            return GalleryUserCard(
              user: _list[index],
              onDelete: _refreshGallery, // Pass the refresh callback
            );
          },
        ),
      ),
    );
  }
}
