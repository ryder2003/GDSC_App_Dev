import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_gallery/screens/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../modals/galleryuser.dart';

class ProfileScreen extends StatefulWidget {
  final GalleryUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  Color hexToColor(String hexCode) {
    return Color(int.parse(hexCode.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context); // Initialize MediaQuery

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: hexToColor('#293d3d'),
        appBar: AppBar(
          title: Text("Profile Details", style: TextStyle(fontSize: 25)),
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              // For showing progress bar
              Dialogs.showProgressLoader(context);
              // Sign out from the app
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  // For hiding progress bar and moving to login screen
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const Login()));
                });
              });
            },
            icon: Icon(Icons.logout, color: Colors.white),
            label: Text("Logout", style: const TextStyle(color: Colors.white)),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.size.width, height: mq.size.height * .02),

                  Stack(
                    children: [
                      _image != null
                      // Image from Local
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(mq.size.height * .1),
                        child: Image.file(
                          File(_image!),
                          width: mq.size.height * .2,
                          height: mq.size.height * .2,
                          fit: BoxFit.cover,
                        ),
                      )
                      // Image from server
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(mq.size.height * .1),
                        child: CachedNetworkImage(
                          width: mq.size.height * .2,
                          height: mq.size.height * .2,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.image,
                          errorWidget: (context, url, error) => CircleAvatar(
                            child: Icon(CupertinoIcons.person),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        right: -5,
                        width: mq.size.width * .2,
                        height: mq.size.height * .03,
                        child: MaterialButton(
                          onPressed: () {
                            _showBottomSheet();
                          },
                          child: Icon(Icons.edit, color: Colors.orange, size: 20),
                          color: Colors.grey,
                          shape: CircleBorder(),
                          elevation: 1,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: mq.size.height * .019),

                  // Display Email
                  Text(widget.user.email, style: TextStyle(color: Colors.white, fontSize: 16)),
                  SizedBox(height: mq.size.height * .04),

                  TextFormField(
                    initialValue: widget.user.name,
                    style: TextStyle(color: Colors.white),
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow, width: 2.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "eg. Mickey Mouse",
                      prefixIcon: Icon(Icons.person, color: Colors.white),
                      label: Text("Name", style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  SizedBox(height: mq.size.height * .03),

                  TextFormField(
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow, width: 2.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "eg. Feeling Happy",
                      prefixIcon: Icon(Icons.info, color: Colors.white),
                      label: Text("About", style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  SizedBox(height: mq.size.height * .05),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(mq.size.width * .5, mq.size.height * .06),
                      backgroundColor: Colors.greenAccent,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(context, 'Profile Updated Successfully');
                        });
                      }
                    },
                    label: Text("Update", style: TextStyle(fontSize: 23, color: Colors.white)),
                    icon: Icon(Icons.edit, color: Colors.white, size: 25),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        final mq = MediaQuery.of(context); // Initialize MediaQuery

        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: mq.size.height * .03, bottom: mq.size.height * .08),
          children: [
            Text(
              "Pick Profile Picture",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: mq.size.height * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Pick from Gallery Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    fixedSize: Size(mq.size.width * .3, mq.size.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image from the gallery.
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _image = image.path;
                      });
                      APIs.updateProfilePicture(File(_image!));
                      // For hiding bottom sheet
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset('assets/images/gallery.png'),
                ),
                // Pick from camera button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    fixedSize: Size(mq.size.width * .3, mq.size.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Capture a photo.
                    final XFile? image = await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setState(() {
                        _image = image.path;
                      });
                      APIs.updateProfilePicture(File(_image!));
                      // To hide bottom sheet
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset('assets/images/camera.png'),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
