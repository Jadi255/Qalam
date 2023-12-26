// File generated by FlutterFire CLI.


// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members


import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;


import 'package:flutter/foundation.dart'

    show defaultTargetPlatform, kIsWeb, TargetPlatform;


/// Default [FirebaseOptions] for use with your Firebase apps.


///


/// Example:


/// ```dart


/// import 'firebase_options.dart';


/// // ...


/// await Firebase.initializeApp(


///   options: DefaultFirebaseOptions.currentPlatform,


/// );


/// ```


class DefaultFirebaseOptions {

  static FirebaseOptions get currentPlatform {

    if (kIsWeb) {

      return web;

    }


    switch (defaultTargetPlatform) {

      case TargetPlatform.android:

        return android;


      case TargetPlatform.iOS:

        return ios;


      case TargetPlatform.macOS:

        throw UnsupportedError(

          'DefaultFirebaseOptions have not been configured for macos - '

          'you can reconfigure this by running the FlutterFire CLI again.',

        );


      case TargetPlatform.windows:

        throw UnsupportedError(

          'DefaultFirebaseOptions have not been configured for windows - '

          'you can reconfigure this by running the FlutterFire CLI again.',

        );


      case TargetPlatform.linux:

        throw UnsupportedError(

          'DefaultFirebaseOptions have not been configured for linux - '

          'you can reconfigure this by running the FlutterFire CLI again.',

        );


      default:

        throw UnsupportedError(

          'DefaultFirebaseOptions are not supported for this platform.',

        );

    }

  }


  static const FirebaseOptions web = FirebaseOptions(

    apiKey: 'AIzaSyC9sqehoMNAfcfXAd9VUJR4A8HWr3raonc',

    appId: '1:519776664484:web:0d60b4b9dfd5331d065f31',

    messagingSenderId: '519776664484',

    projectId: 'ahrar-app',

    authDomain: 'ahrar-app.firebaseapp.com',

    storageBucket: 'ahrar-app.appspot.com',

    measurementId: 'G-KR16H61D5E',

  );


  static const FirebaseOptions android = FirebaseOptions(

    apiKey: 'AIzaSyCTLvSYZzpWesgwQbTfw2nf8rUOchjW23c',

    appId: '1:519776664484:android:c85aa6a68983dd8e065f31',

    messagingSenderId: '519776664484',

    projectId: 'ahrar-app',

    storageBucket: 'ahrar-app.appspot.com',

  );


  static const FirebaseOptions ios = FirebaseOptions(

    apiKey: 'AIzaSyAsEz5G5QSirRZIBjebQ0YeqyV26yoa1Ok',

    appId: '1:519776664484:ios:dda01e7c3740a072065f31',

    messagingSenderId: '519776664484',

    projectId: 'ahrar-app',

    storageBucket: 'ahrar-app.appspot.com',

    iosBundleId: 'com.example.tahrir',

  );

}

