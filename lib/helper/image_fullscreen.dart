import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import '../api/apis.dart';
import '../modals/galleryuser.dart';
import 'package:flutter/services.dart';

class FullScreenImage extends StatelessWidget {
  final GalleryUser? user;
  final Function onDelete;

  const FullScreenImage({super.key, required this.user, required this.onDelete});

  Future<void> _downloadImage(BuildContext context, String imageUrl) async {
    try {
      // Get the directory to save the file
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Failed to get directory.');
      }

      final taskId = await FlutterDownloader.enqueue(
        url: imageUrl,
        savedDir: directory.path,
        fileName: 'downloaded_image.jpg',
        showNotification: true, // show download progress in status bar
        openFileFromNotification: true, // click on notification to open downloaded file
      );

      if (taskId == null) {
        throw Exception('Failed to download image.');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image downloaded successfully!')),
      );
    } catch (e) {
      print('Error downloading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download image.')),
      );
    }
  }

  Future<void> _deleteImage(BuildContext context, String imageUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();

      // Remove the deleted image from Firestore collection
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(APIs.user.uid)
          .collection('photos')
          .where('image', isEqualTo: imageUrl)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully!')),
      );
      onDelete(); // Refresh the gallery
      Navigator.pop(context);
    } catch (e) {
      print('Error deleting image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          Center(
            child: Image.network(
              user!.image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
              },
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  onPressed: () => _downloadImage(context, user!.image),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  onPressed: () => _deleteImage(context, user!.image),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
