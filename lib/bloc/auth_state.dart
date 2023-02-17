part of 'auth_cubit.dart';


abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<String> get props => [];
}

class AuthInitial extends AuthState{
  const AuthInitial();
}

class AuthLoading extends AuthState{
  const AuthLoading();
}

class AuthSignUp extends AuthState{
  const AuthSignUp();
}

class AuthLogIn extends AuthState{
  const AuthLogIn();
}

class AuthFailure extends AuthState{
  String message;
  AuthFailure({required this.message});

  @override
  List<String> get props => [message];

}
