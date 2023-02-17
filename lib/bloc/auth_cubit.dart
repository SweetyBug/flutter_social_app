import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> logIn({
    required email,
    required password,
  }) async {
    emit(AuthLoading());

    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      emit(AuthLogIn());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(AuthFailure(message: 'No user found for that email.'));
      } else if (e.code == 'wrong-password') {
        emit(AuthFailure(message: 'Wrong password provided for that user.'));
      }
    } catch (error) {
      emit(AuthFailure(message: error.toString()));
    }
  }

  Future<void> signUp({
    required email,
    required username,
    required password,
  }) async {
    emit(AuthLoading());

    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      final UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).set({
        "userId" : userCredential.user!.uid,
        "userName" : username,
        "email" : email,
      });

      userCredential.user!.updateDisplayName(username);

      emit(AuthSignUp());
    }on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(AuthFailure(message: 'The password provided is too weak.'));
      } else if (e.code == 'email-already-in-use') {
        emit(AuthFailure(message: 'The account already exists for that email.'));
      }
    } catch (error) {
      emit(AuthFailure(message: error.toString()));
    }
  }

  Future<void> logout() async{
    await FirebaseAuth.instance.signOut();
    emit(AuthInitial());
  }
}
