import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdsc_gallery/screens/nav.dart';

import '../api/apis.dart';
import '../main.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen>{
  Color hexToColor(String hexCode) {
    return Color(int.parse(hexCode.substring(1, 7), radix: 16) + 0xFF000000);
  }
  @override
  void initState(){
    super.initState();
    Future.delayed(Duration(milliseconds: 2000), (){
      //To exit full screen
      SystemChrome.setEnabledSystemUIMode((SystemUiMode.edgeToEdge));
      //Status bar can be customized too
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));

      //To Navigate to home screen or login screen
      if(FirebaseAuth.instance.currentUser != null){
        print('\nUser: ${APIs.auth.currentUser}\n');
        Navigator.pushReplacement((context), MaterialPageRoute(builder: (_)=>BottomNav()));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>Login()));
      }

    });
  }


  @override
  Widget build(BuildContext context) {
    //  Initialising media query
    mq = MediaQuery.of(context).size;


    return Scaffold(
      body: Container(
        color: hexToColor('#00264d'),
        child: Stack(
          children: [

            Positioned(
              top: mq.height * .4,
              width: mq.width * .45,
              right: mq.width * .24,
              child: Image.asset('assets/images/phone.png'),
            ),
            Positioned(
              bottom: mq.height * .12,
              left: mq.width * .4,
              width: mq.width,
              child: Text("Made By",style: TextStyle(
                  fontSize:25,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'Font1',
                  color: hexToColor('#85adad')
              ),),
            ),
            Positioned(
              bottom: mq.height * .00000000000001,
              left: mq.width * .45,
              width: mq.width,
              child: Text("®",style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Font1',
                  color: hexToColor("#85adad")
              ),),
            ),
          ],
        ),
      ),
    );
  }
}