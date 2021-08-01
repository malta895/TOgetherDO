// Mocks generated by Mockito 5.0.12 from annotations
// in mobile_applications/test/unit/utils_test.dart.
// Do not manually edit this file.

import 'package:cloud_functions/cloud_functions.dart' as _i4;
import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart'
    as _i3;
import 'package:firebase_core/firebase_core.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis

class _FakeFirebaseApp extends _i1.Fake implements _i2.FirebaseApp {}

class _FakeFirebaseFunctionsPlatform extends _i1.Fake
    implements _i3.FirebaseFunctionsPlatform {}

class _FakeHttpsCallable extends _i1.Fake implements _i4.HttpsCallable {}

/// A class which mocks [FirebaseFunctions].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseFunctions extends _i1.Mock implements _i4.FirebaseFunctions {
  MockFirebaseFunctions() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FirebaseApp get app => (super.noSuchMethod(Invocation.getter(#app),
      returnValue: _FakeFirebaseApp()) as _i2.FirebaseApp);
  @override
  _i3.FirebaseFunctionsPlatform get delegate =>
      (super.noSuchMethod(Invocation.getter(#delegate),
              returnValue: _FakeFirebaseFunctionsPlatform())
          as _i3.FirebaseFunctionsPlatform);
  @override
  Map<dynamic, dynamic> get pluginConstants =>
      (super.noSuchMethod(Invocation.getter(#pluginConstants),
          returnValue: <dynamic, dynamic>{}) as Map<dynamic, dynamic>);
  @override
  _i4.HttpsCallable httpsCallable(String? name,
          {_i3.HttpsCallableOptions? options}) =>
      (super.noSuchMethod(
          Invocation.method(#httpsCallable, [name], {#options: options}),
          returnValue: _FakeHttpsCallable()) as _i4.HttpsCallable);
  @override
  void useFunctionsEmulator(String? host, int? port) =>
      super.noSuchMethod(Invocation.method(#useFunctionsEmulator, [host, port]),
          returnValueForMissingStub: null);
}
