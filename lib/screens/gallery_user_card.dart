import 'package:flutter/material.dart';
import '../helper/image_fullscreen.dart';
import '../modals/galleryuser.dart';

class GalleryUserCard extends StatelessWidget {
  final GalleryUser user;
  final Function onDelete;

  const GalleryUserCard({
    Key? key,
    required this.user,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FullScreenImage(user: user, onDelete: onDelete),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                user.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                },
              ),
            ),
            // Remove unnecessary name or other information
          ],
        ),
      ),
    );
  }
}
