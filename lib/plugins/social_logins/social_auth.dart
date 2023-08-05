import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuth {
  // Variables
  static final auth = FirebaseAuth.instance;

  //
  // LOGIN WITH APPLE - SECTION
  //
  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  static String _generateNonce([int length = 32]) {
    // Define 64 characters string
    const String charset64 =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    // Creates a cryptographically secure random number generator.
    final random = Random.secure();
    return List.generate(
        length, (_) => charset64[random.nextInt(charset64.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  static String _sha256ofString(String input) {
    final List<int> bytes = utf8.encode(input);
    final Digest digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Login with Apple - method
  static Future<void> signInWithApple({
    // Callback functions
    required Function() checkUserAccount,
    required Function(FirebaseAuthException error) onError,
    required Function() onNotAvailable,
  }) async {
    try {
      if (!await SignInWithApple.isAvailable()) {
        onNotAvailable();
        return; //Break the program
      }
      // To prevent replay attacks with the credential returned from Apple, we
      // include a nonce in the credential request. When signing in in with
      // Firebase, the nonce in the id token returned by Apple, is expected to
      // match the sha256 hash of `rawNonce`.
      final String rawNonce = _generateNonce();
      final String nonce = _sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Get Apple User Fullname
      final String appleUserName =
          "${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}";

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      // Once signed in, return the Firebase UserCredential
      final userCredential = await auth.signInWithCredential(oauthCredential);

      // Update Firebase User display name
      await userCredential.user!.updateDisplayName(appleUserName);

      /// Check User Account in Database to take action
      checkUserAccount();
    } on FirebaseAuthException catch (error) {
      // Error callback
      onError(error);
    }
  }

  //
  // LOGIN WITH FACEBOOK
  //
  static Future<void> signInWithFacebook({
    // Callback functions
    required Function() checkUserAccount,
    required Function(FirebaseAuthException error) onError,
  }) async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Continues if not null
      if (loginResult.accessToken == null) return;

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      // Once signed in, return the Firebase UserCredential
      await auth.signInWithCredential(facebookAuthCredential);

      /// Check User Account in Database to take action
      checkUserAccount();
    } on FirebaseAuthException catch (error) {
      // Error callback
      onError(error);
    }
  }

  //
  // LOGIN WITH GOOGLE
  //
  static Future<void> signInWithGoogle({
    // Callback functions
    required Function() checkUserAccount,
    required Function(FirebaseAuthException error) onError,
  }) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Continues not null
      if (googleUser == null) return;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the Firebase UserCredential
      await auth.signInWithCredential(credential);

      /// Check User Account in Database to take action
      checkUserAccount();
    } on FirebaseAuthException catch (error) {
      // // Debug
      debugPrint('error code: $error');
      // Error callback
      onError(error);
    }
  }
}
