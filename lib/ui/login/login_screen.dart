import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_applications/models/exception.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../lists_page.dart';
import 'custom_route.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: Constants.appName,
      logo: Constants.appLogoPath,
      logoTag: Constants.logoTag,
      titleTag: Constants.titleTag,
      loginAfterSignUp: true,
      loginProviders: <LoginProvider>[
        LoginProvider(
          icon: FontAwesomeIcons.facebookF,
          callback: () async {
            return context.read<ListAppAuthProvider>().loginViaFacebook();
          },
          providerNeedsSignUpCallback: () async {
            final listAppUser = await context
                .read<ListAppAuthProvider>()
                .getLoggedInListAppUser();
            return listAppUser?.isNew ?? true;
          },
        ),
        LoginProvider(
          icon: FontAwesomeIcons.google,
          callback: () async {
            return context.read<ListAppAuthProvider>().loginViaGoogle();
          },
          providerNeedsSignUpCallback: () async {
            final listAppUser = await context
                .read<ListAppAuthProvider>()
                .getLoggedInListAppUser();
            return listAppUser?.isNew ?? true;
          },
        ),
      ],
      additionalSignupFields: [
        UserFormField(
            keyName: 'username',
            displayName: 'Username',
            icon: const Icon(FontAwesomeIcons.userAlt),
            defaultValue: context
                    .read<ListAppAuthProvider>()
                    .loggedInListAppUser
                    ?.username ??
                ''),
        const UserFormField(keyName: 'firstName', displayName: 'Name'),
        const UserFormField(keyName: 'lastName', displayName: 'Surname'),
      ],
      theme: LoginTheme(
        bodyStyle: TextStyle(
          color: Theme.of(context).textTheme.headline1!.color,
        ),
        textFieldStyle: TextStyle(
          color: Theme.of(context).textTheme.headline1!.color,
          // shadows: [Shadow(color: Colors.yellow, blurRadius: 2)],
        ),
      ),
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
      onLogin: (loginData) async {
        print('Login info');
        print('Name: ${loginData.name}');
        print('Password: ${loginData.password}');

        String? error = await context
            .read<ListAppAuthProvider>()
            .loginViaEmailPassword(loginData.name, loginData.password);

        return error;
      },
      onSignup: (SignupData signupData) async {
        String? error;

        if (signupData.name != null && signupData.password != null) {
          error = await context
              .read<ListAppAuthProvider>()
              .signupWithEmailAndPassword(
                  signupData.name!, signupData.password!);

          if (error != null) return error;
        }

        final fields = signupData.additionalSignupData;

        if (fields != null) {
          final username = fields['username']!;
          final firstName = fields['firstName']!;
          final lastName = fields['lastName']!;

          try {
            final currentUser = await context
                .read<ListAppAuthProvider>()
                .getLoggedInListAppUser();

            if (currentUser != null) {
              currentUser.firstName = firstName;
              currentUser.lastName = lastName;
              await ListAppUserManager.instance.validateUsername(username);
              currentUser.username = username;

              currentUser.isNew = false;
              await ListAppUserManager.instance.saveToFirestore(currentUser);
            } else {
              // await context.read<ListAppAuthProvider>().deleteCurrentAccount();

              return "An error occurred. Please close the application and try again.";
            }

            // we get here only if everything goes well
            return null;
          } on ListAppException catch (e) {
            return e.message;
          }
        }
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(FadePageRoute(
          builder: (context) => const ListsPage(),
        ));
      },
      hideForgotPasswordButton:
          true, // TODO remove if password recover is implemented
      onRecoverPassword: (name) {
        print('Recover password info');
        print('Name: $name');
        // return _recoverPassword(name);
        // TODO Show new password dialog
      },
      // showDebugButtons: true,
    );
  }
}
