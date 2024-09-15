import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gdsc_gallery/modals/galleryuser.dart';

class APIs {
  // For authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // For accessing Cloud Firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // For accessing Cloud Firebase Storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // For storing self information
  static late GalleryUser me;

  // To return current user
  static User get user => auth.currentUser!;

  // For checking if the user exists
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(auth.currentUser!.uid).get()).exists;
  }

  //For getting info of current user
  static Future<void> getSelfInfo() async{
    await firestore.collection('users').doc(user.uid).get().then((user) async{
      if(user.exists){
        me = GalleryUser.fromJson(user.data()!);
        print("My data: ${user.data()}");
      }
      else{
        await createUser().then((value)=>getSelfInfo());
      }
    });
  }

  // To create a new user
  static Future<void> createUser() async {
    final galleryUser = GalleryUser(
        image: user.photoURL.toString(),
        name: user.displayName.toString(),
        id: user.uid,
        email: user.email.toString(),
        pushToken: ''
    );
    return await firestore.collection('users').doc(user.uid).set(galleryUser.toJson());
  }

  // To update user's personal info
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
    });
  }

  // For getting all users from Firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore.collection('users').where('id', isNotEqualTo: user.uid).snapshots();
  }

  // Update profile picture of the user
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    print("Extension: $ext");

    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    await ref.putFile(file, SettableMetadata(contentType: "image/$ext")).then((p0) {
      print('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image
    });
  }

  // Apply customized color
  static Color hexToColor(String hexCode) {
    return Color(int.parse(hexCode.substring(1, 7), radix: 16) + 0xFF000000);
  }
}
