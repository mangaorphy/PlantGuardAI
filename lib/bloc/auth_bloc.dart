import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess(userCredential.user!));
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(e.message ?? 'Authentication failed'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess(userCredential.user!));
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(e.message ?? 'Sign up failed'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}