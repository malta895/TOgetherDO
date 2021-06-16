import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../home_lists.dart';
import 'custom_route.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: Constants.APP_NAME,
      logo: Constants.APP_LOGO_PATH,
      logoTag: Constants.LOGO_TAG,
      titleTag: Constants.TITLE_TAG,
      loginAfterSignUp: false,
      loginProviders: <LoginProvider>[
        LoginProvider(
          icon: FontAwesomeIcons.facebookF,
          callback: () async {
            return context.read<ListAppAuthProvider>().loginViaFacebook();
          },
        ),
        LoginProvider(
            icon: FontAwesomeIcons.google,
            callback: () async {
              return context.read<ListAppAuthProvider>().loginViaGoogle();
            }),
      ],
      // hideForgotPasswordButton: true,
      // hideSignUpButton: true,
      // messages: LoginMessages(
      //   usernameHint: 'Username',
      //   passwordHint: 'Pass',
      //   confirmPasswordHint: 'Confirm',
      //   loginButton: 'LOG IN',
      //   signupButton: 'REGISTER',
      //   forgotPasswordButton: 'Forgot huh?',
      //   recoverPasswordButton: 'HELP ME',
      //   goBackButton: 'GO BACK',
      //   confirmPasswordError: 'Not match!',
      //   recoverPasswordIntro: 'Don\'t feel bad. Happens all the time.',
      //   recoverPasswordDescription: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
      //   recoverPasswordSuccess: 'Password rescued successfully',
      //   flushbarTitleError: 'Oh no!',
      //   flushbarTitleSuccess: 'Succes!',
      // ),
      theme: LoginTheme(
        //   primaryColor: Colors.teal,
        //   accentColor: Colors.yellow,
        //   errorColor: Colors.deepOrange,
        //   pageColorLight: Colors.indigo.shade300,
        //   pageColorDark: Colors.indigo.shade500,
        //   titleStyle: TextStyle(
        //     color: Colors.greenAccent,
        //     fontFamily: 'Quicksand',
        //     letterSpacing: 4,
        //   ),
        //   // beforeHeroFontSize: 50,
        //   // afterHeroFontSize: 20,
        bodyStyle: TextStyle(
          color: Theme.of(context).textTheme.headline1!.color,
        ),
        textFieldStyle: TextStyle(
          color: Theme.of(context).textTheme.headline1!.color,
          // shadows: [Shadow(color: Colors.yellow, blurRadius: 2)],
        ),
      ),
      //   buttonStyle: TextStyle(
      //     fontWeight: FontWeight.w800,
      //     color: Colors.yellow,
      //   ),
      //   cardTheme: CardTheme(
      //     color: Colors.yellow.shade100,
      //     elevation: 5,
      //     margin: EdgeInsets.only(top: 15),
      //     shape: ContinuousRectangleBorder(
      //         borderRadius: BorderRadius.circular(100.0)),
      //   ),
      //   inputTheme: InputDecorationTheme(
      //     filled: true,
      //     fillColor: Colors.purple.withOpacity(.1),
      //     contentPadding: EdgeInsets.zero,
      //     errorStyle: TextStyle(
      //       backgroundColor: Colors.orange,
      //       color: Colors.white,
      //     ),
      //     labelStyle: TextStyle(fontSize: 12),
      //     enabledBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.blue.shade700, width: 4),
      //       borderRadius: inputBorder,
      //     ),
      //     focusedBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.blue.shade400, width: 5),
      //       borderRadius: inputBorder,
      //     ),
      //     errorBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.red.shade700, width: 7),
      //       borderRadius: inputBorder,
      //     ),
      //     focusedErrorBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.red.shade400, width: 8),
      //       borderRadius: inputBorder,
      //     ),
      //     disabledBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.grey, width: 5),
      //       borderRadius: inputBorder,
      //     ),
      //   ),
      //   buttonTheme: LoginButtonTheme(
      //     splashColor: Colors.purple,
      //     backgroundColor: Colors.pinkAccent,
      //     highlightColor: Colors.lightGreen,
      //     elevation: 9.0,
      //     highlightElevation: 6.0,
      //     shape: BeveledRectangleBorder(
      //       borderRadius: BorderRadius.circular(10),
      //     ),
      //     // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      //     // shape: CircleBorder(side: BorderSide(color: Colors.green)),
      //     // shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(55.0)),
      //   ),
      // ),
      userType: LoginUserType.email,
      userValidator: (email) {
        if (email != null && EmailValidator.validate(email)) return null;
        return "Please insert a valid email address";
      },
      passwordValidator: (password) {
        if (password?.isEmpty ?? false) {
          return 'Password is empty';
        }
        return null;
      },
      onLogin: (loginData) {
        print('Login info');
        print('Name: ${loginData.name}');
        print('Password: ${loginData.password}');

        return context
            .read<ListAppAuthProvider>()
            .loginViaEmailPassword(loginData.name, loginData.password);
      },
      onSignup: (loginData) {
        print('Signup info');
        print('Name: ${loginData.name}');
        print('Password: ${loginData.password}');
        return context
            .read<ListAppAuthProvider>()
            .signupWithEmailAndPassword(loginData.name, loginData.password);
      },
      onSubmitAnimationCompleted: () {
        print("Login successful");
        Navigator.of(context).pushReplacement(FadePageRoute(
          builder: (context) => ListHomePage(),
        ));
      },
      onRecoverPassword: (name) {
        print('Recover password info');
        print('Name: $name');
        // return _recoverPassword(name);
        // TODO Show new password dialog
      },
      showDebugButtons: true, //TODO remove when no longer needed
    );
  }
}
