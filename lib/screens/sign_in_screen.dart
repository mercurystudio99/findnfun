import 'dart:io';

import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/plugins/social_logins/social_auth.dart';
import 'package:dating_app/screens/blocked_account_screen.dart';
import 'package:dating_app/screens/home_screen.dart';
import 'package:dating_app/screens/phone_number_screen.dart';
import 'package:dating_app/screens/sign_up_screen.dart';
import 'package:dating_app/screens/update_location_sceen.dart';
import 'package:dating_app/widgets/app_logo.dart';
import 'package:dating_app/widgets/cicle_button.dart';
import 'package:dating_app/widgets/default_button.dart';
import 'package:dating_app/widgets/show_scaffold_msg.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:dating_app/widgets/terms_of_service_row.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late AppLocalizations _i18n;

  void _showErrorMessage(String message) {
    showScaffoldMessage(
        context: context, message: message, bgcolor: Colors.red);
  }

  void _nextScreen(screen) {
    Future(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => screen), (route) => false);
    });
  }

  void _checkUserAccount() {
    UserModel().authUserAccount(
        updateLocationScreen: () => _nextScreen(const UpdateLocationScreen()),
        signUpScreen: () => _nextScreen(const SignUpScreen()),
        homeScreen: () => _nextScreen(const HomeScreen()),
        blockedScreen: () => _nextScreen(const BlockedAccountScreen()));
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_image.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
              Theme.of(context).primaryColor,
              Colors.black.withOpacity(.4)
            ]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const AppLogo(),
              const SizedBox(height: 10),

              /// App name
              const Text(APP_NAME,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 20),

              Text(_i18n.translate("welcome_back"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 5),
              Text(_i18n.translate("app_short_description"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.white)),

              const SizedBox(height: 50),

              /// Sign in with Phone Number
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.maxFinite,
                  child: DefaultButton(
                    child: Text(_i18n.translate("sign_in_with_phone_number"),
                        style: const TextStyle(fontSize: 18)),
                    onPressed: () {
                      /// Go to phone number screen
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PhoneNumberScreen()));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              /// Customization
              Text(_i18n.translate('OR'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.grey)),

              const SizedBox(height: 5),

              Text(_i18n.translate('sign_in_with_social_apps'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.white60)),

              const SizedBox(height: 10),

              /// Social login
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ///
                  /// Login with Facebook
                  ///
                  cicleButton(
                      bgColor: Colors.white,
                      padding: 20,
                      icon: const SvgIcon("assets/icons/facebook_icon.svg",
                          width: 40, height: 40, color: Colors.blue),
                      onTap: () async {
                        // Login with Facebook
                        SocialAuth.signInWithFacebook(
                            checkUserAccount: _checkUserAccount,
                            onError: (error) {
                              // Show error message
                              _showErrorMessage(
                                  _i18n.translate('an_error_has_occurred') +
                                      "\nError -> ${error.message}");
                              debugPrint(
                                  'signInWithFacebook() -> error: ${error.toString()}');
                            });
                      }),

                  /// Apple Sign In
                  if (Platform.isIOS)
                    cicleButton(
                        bgColor: Colors.white,
                        padding: 13,
                        icon: SvgPicture.asset("assets/icons/apple_icon.svg",
                            width: 35, height: 35, color: Colors.black),
                        onTap: () async {
                          // Login with Apple
                          SocialAuth.signInWithApple(
                              checkUserAccount: _checkUserAccount,
                              onNotAvailable: () {
                                // Show error message
                                _showErrorMessage(_i18n.translate(
                                    "login_with_apple_not_available"));
                              },
                              onError: (error) {
                                // Show error message
                                _showErrorMessage(
                                    _i18n.translate('an_error_has_occurred') +
                                        '\nError: ${error.message}');
                                // Debug
                                debugPrint(
                                    'signInWithApple() -> error: $error');
                              });
                        }),

                  /// Login with google
                  cicleButton(
                      bgColor: Colors.white,
                      padding: 13,
                      icon: SvgPicture.asset("assets/icons/google_icon.svg",
                          width: 35, height: 35),
                      onTap: () async {
                        // Login with google
                        SocialAuth.signInWithGoogle(
                            checkUserAccount: _checkUserAccount,
                            onError: (error) {
                              // Show error message
                              _showErrorMessage(
                                  _i18n.translate('an_error_has_occurred') +
                                      "\nError -> ${error.message}");
                              debugPrint('signInWithGoogle() -> error: $error');
                            });
                      }),
                ],
              ),

              const SizedBox(height: 15),

              // Terms of Service section
              Text(
                _i18n.translate("by_tapping_log_in_you_agree_with_our"),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 7,
              ),
              TermsOfServiceRow(),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
