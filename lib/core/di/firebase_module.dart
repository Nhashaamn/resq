import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

@module
abstract class FirebaseModule {
  @lazySingleton
  firebase_auth.FirebaseAuth get firebaseAuth => firebase_auth.FirebaseAuth.instance;
  
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn(
    // For web, don't pass clientId - it will use the meta tag in index.html
    // For mobile (iOS/Android), use the iOS client ID
    clientId: kIsWeb
        ? null
        : '833322773378-qlm05lf2jdc8071kghvf2j9nkoiah6gg.apps.googleusercontent.com',
  );
}

