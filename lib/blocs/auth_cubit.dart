import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationState {}

class Unauthenticated extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final User user;
  Authenticated(this.user);
}

class AuthBloc extends Cubit<AuthenticationState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthBloc() : super(Unauthenticated()) {
    //logOut();
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        print('listener sent a non-null user');
        emit(Authenticated(user));
      } else {
        print('listener sent a null user');
        emit(Unauthenticated());
      }
    });
  }

  void handleSignIn(User? user) {
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> handleUserCreation(UserCredential credential) async {
    final user = credential.user;
    if (credential.user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .set({
          'balance': 1000000,
          'stocks': [],
        });
      } on FirebaseException catch (e) {
        print('Firebase Exception: ${e.toString()}');
      } catch (e) {
        print('Its you problem');
      }
    }
  }

  Future<void> logOut() async {
    await _firebaseAuth.signOut();
    emit(Unauthenticated());
  }
}
