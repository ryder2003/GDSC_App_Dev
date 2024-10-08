import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gdsc_gallery/screens/home_screen.dart';
import 'package:gdsc_gallery/screens/signup_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../helper/forgotPassword.dart';
import '../main.dart';
import 'nav.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {


  String email="", password="";

  TextEditingController emailController= new TextEditingController();
  TextEditingController passwordController= new TextEditingController();

  final _formkey= GlobalKey<FormState>();

  userLogin() async {
    email = emailController.text.trim();
    password = passwordController.text.trim();

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.greenAccent,
          content: Text("Login Successfully",
              style: TextStyle(color: Colors.black, fontSize: 16))));

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BottomNav()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.redAccent,
              title: Text(
                "Error",
                style: TextStyle(color: Colors.black),
              ),
              content: Text(
                "User not registered",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    "OK",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (e.code == 'wrong-password') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.redAccent,
              title: Text(
                "Error",
                style: TextStyle(color: Colors.black),
              ),
              content: Text(
                "Wrong Password",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    "OK",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // For any other errors, you can show a generic error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.redAccent,
              title: Text(
                "Error",
                style: TextStyle(color: Colors.black),
              ),
              content: Text(
                "Something went wrong: ${e.message}",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    "OK",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }


  //***************Google Login*************************
  _handleGoogleButtonClick(){
    //To show Progress Loader
    Dialogs.showProgressLoader(context);

    _signInWithGoogle().then((user) async{
      //To remove Progress Loader
      Navigator.pop(context);
      if(user != null){
        print("\nUser: ${user.user}");
        print("\nUser Additional Info: ${user.additionalUserInfo}");
        //It will redirect to homescreen after login

        if((await APIs.userExists())){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const BottomNav()));
        }
        else{
          await APIs.createUser().then((value){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const BottomNav()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try{
      await InternetAddress.lookup('google.com');
      //Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e){
      print('\n_signInWithGoogle: $e');Dialogs.showSnackbar(context, 'No internet connection! Please check and try again...');
      return null;
    }
  }

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration(milliseconds: 2000), (){
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      //appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor:const Color.fromRGBO(255,245,228,1),
      body:  SingleChildScrollView(
        child: Container(
          //padding:const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Container(
                  child: Image.asset('assets/images/storage_drive.png'),
                height: 220,
                width: 300,
              ),
              //const SizedBox(height: 10,),

              SizedBox(height: 40,),


              Container(
                width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.height/1.8,
                decoration: const BoxDecoration(color: Color.fromRGBO(106,156,137,1), borderRadius: BorderRadius.only(topLeft: Radius.circular(41), topRight: Radius.circular(41))),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 10,),
                      const Center(child: const Text("Login", style: TextStyle(color: Colors.black, fontSize: 54, fontWeight: FontWeight.bold,))),
                      const SizedBox(height: 30,),

                      //Text("Login", style: AppWidget.semiBoldTextStyle(),),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        decoration: BoxDecoration(color: const Color.fromRGBO(255,245,228,1), borderRadius: BorderRadius.circular(14)),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          controller: emailController,
                          decoration: InputDecoration(border: InputBorder.none, hintText: "Email"),
                        ),
                      ),

                      const SizedBox(height: 30,),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        decoration: BoxDecoration(color: const Color.fromRGBO(255,245,228,1), borderRadius: BorderRadius.circular(14)),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          controller: passwordController,
                          decoration: InputDecoration(border: InputBorder.none, hintText: "Password"),
                        ),
                      ),

                      const SizedBox(height: 20,),

                      GestureDetector(
                        onTap:(){ Navigator.push(context,MaterialPageRoute(builder: (context) => Forgotpassword()) );},
                        child: Container(
                          margin:const EdgeInsets.symmetric(horizontal: 20),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("Forget Password ?", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20,),

                      InkWell(
                        onTap: () => _handleGoogleButtonClick(),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding:const EdgeInsets.symmetric(horizontal: 23, vertical: 10),
                                decoration: BoxDecoration(color: const Color.fromRGBO(193,216,195,1), borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  children: [

                                    SvgPicture.asset('assets/images/google.svg', height: 30, width: 30,),
                                    SizedBox(width: 9,),
                                    Text("Google", style: TextStyle(color: Colors.black, fontSize: 18),),
                                  ],),
                              ),

                              SizedBox(width: 40,),
                              //Text("Don't have an account ?", style: AppWidget.lightTextStyle(),),
                              Container(
                                padding:const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(color:const Color.fromRGBO(193,216,195,1), borderRadius: BorderRadius.circular(15) ),
                                child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(context,MaterialPageRoute(builder: (context) => Signup()) );
                                    },
                                    child: const Text("New User ?", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18),)),
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30,),

                      InkWell(
                        onTap: () {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              userLogin();
                            });
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 20, ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(color: const Color.fromRGBO(205,92,8,1), borderRadius: BorderRadius.circular(14)),
                          child: Center(child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold
                          ))),
                        ),
                      ),

                      SizedBox(height: 30,)

                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//Color.fromRGBO(193,216,195,1)