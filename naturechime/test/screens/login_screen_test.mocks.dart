// Mocks generated by Mockito 5.4.6 from annotations
// in naturechime/test/screens/login_screen_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:io' as _i6;

import 'package:firebase_auth/firebase_auth.dart' as _i5;
import 'package:flutter/src/widgets/navigator.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:naturechime/services/auth_service.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [NavigatorObserver].
///
/// See the documentation for Mockito's code generation for more information.
class MockNavigatorObserver extends _i1.Mock implements _i2.NavigatorObserver {
  @override
  void didPush(
    _i2.Route<dynamic>? route,
    _i2.Route<dynamic>? previousRoute,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #didPush,
          [
            route,
            previousRoute,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void didPop(
    _i2.Route<dynamic>? route,
    _i2.Route<dynamic>? previousRoute,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #didPop,
          [
            route,
            previousRoute,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void didRemove(
    _i2.Route<dynamic>? route,
    _i2.Route<dynamic>? previousRoute,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #didRemove,
          [
            route,
            previousRoute,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void didReplace({
    _i2.Route<dynamic>? newRoute,
    _i2.Route<dynamic>? oldRoute,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #didReplace,
          [],
          {
            #newRoute: newRoute,
            #oldRoute: oldRoute,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void didChangeTop(
    _i2.Route<dynamic>? topRoute,
    _i2.Route<dynamic>? previousTopRoute,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #didChangeTop,
          [
            topRoute,
            previousTopRoute,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void didStartUserGesture(
    _i2.Route<dynamic>? route,
    _i2.Route<dynamic>? previousRoute,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #didStartUserGesture,
          [
            route,
            previousRoute,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void didStopUserGesture() => super.noSuchMethod(
        Invocation.method(
          #didStopUserGesture,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [AuthService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthService extends _i1.Mock implements _i3.AuthService {
  MockAuthService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Stream<_i5.User?> get authStateChanges => (super.noSuchMethod(
        Invocation.getter(#authStateChanges),
        returnValue: _i4.Stream<_i5.User?>.empty(),
      ) as _i4.Stream<_i5.User?>);

  @override
  _i4.Future<_i5.User?> signInWithEmailAndPassword(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithEmailAndPassword,
          [
            email,
            password,
          ],
        ),
        returnValue: _i4.Future<_i5.User?>.value(),
      ) as _i4.Future<_i5.User?>);

  @override
  _i4.Future<void> sendPasswordResetEmail(String? email) => (super.noSuchMethod(
        Invocation.method(
          #sendPasswordResetEmail,
          [email],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<_i5.User?> signInWithGoogle() => (super.noSuchMethod(
        Invocation.method(
          #signInWithGoogle,
          [],
        ),
        returnValue: _i4.Future<_i5.User?>.value(),
      ) as _i4.Future<_i5.User?>);

  @override
  _i4.Future<void> signOut() => (super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<_i5.User?> createUserWithEmailAndPassword(
    String? email,
    String? password,
    String? displayName,
    _i6.File? profileImageFile,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #createUserWithEmailAndPassword,
          [
            email,
            password,
            displayName,
            profileImageFile,
          ],
        ),
        returnValue: _i4.Future<_i5.User?>.value(),
      ) as _i4.Future<_i5.User?>);

  @override
  _i4.Future<bool> isDisplayNameTaken(String? displayName) =>
      (super.noSuchMethod(
        Invocation.method(
          #isDisplayNameTaken,
          [displayName],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
}
