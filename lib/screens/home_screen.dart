import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_gallery/screens/gallery_user_card.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../modals/galleryuser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GalleryUser> _list = [];
  File? _image;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  // Method to pick image from gallery
  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
      _uploadImageToFirebase();
    }
  }

  // Method to upload the image to Firebase Storage and save the URL to Firestore
  Future<void> _uploadImageToFirebase() async {
    if (_image == null) return;

    final userId = APIs.user.uid; // Fetch logged-in user's ID
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = FirebaseStorage.instance.ref().child('gallery/$userId/$fileName');

    try {
      // Upload the image
      final uploadTask = await storageRef.putFile(_image!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save image URL to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('photos').add({
        'image': downloadUrl,
        'uploadedAt': Timestamp.now(),
        'name': APIs.me.name,  // Replace with actual user name
        'email': APIs.me.email,  // Replace with actual user email
      });

      setState(() {
        _image = null;  // Clear the image after upload
      });

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

  Color hexToColor(String hexCode) {
    return Color(int.parse(hexCode.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor('#293d3d'),
      appBar: AppBar(
        title: const Text('Gallery'),
        leading: const Icon(Icons.home, size: 28, color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add_a_photo),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(APIs.user.uid)
            .collection('photos')
            .orderBy('uploadedAt', descending: true) // Order by upload time
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error fetching data!",
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Photos Uploaded!",
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            );
          } else {
            final data = snapshot.data!.docs.map((doc) => doc.data()).toList();
            _list = data
                .map((e) => GalleryUser.fromJson(e))
                .whereType<GalleryUser>()
                .toList();

            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3 / 4,
              ),
              itemCount: _list.length,
              itemBuilder: (context, index) {
                return GalleryUserCard(user: _list[index]);
              },
            );
          }
        },
      ),
    );
  }
}
