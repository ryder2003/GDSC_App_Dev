import 'package:flutter/material.dart';
import '../modals/galleryuser.dart';

class GalleryUserCard extends StatefulWidget {
  final GalleryUser? user;

  const GalleryUserCard({super.key, required this.user});

  @override
  State<GalleryUserCard> createState() => _GalleryUserCardState();
}

class _GalleryUserCardState extends State<GalleryUserCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // Changes position of shadow
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.user!.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
            },
          ),
        ),
      ),
    );
  }
}
