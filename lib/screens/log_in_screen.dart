import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/bloc/auth_cubit.dart';
import 'package:social_media_app/screens/posts_screen.dart';
import 'package:social_media_app/screens/sign_up_screen.dart';

class LogInScreen extends StatefulWidget {
  static const String id = "log_in_screen";
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {

  final _formKey = GlobalKey<FormState>();

  String _email = "";
  String _pass = "";

  late final FocusNode _passFocusNode;

  @override
  void initState() {
    _passFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _passFocusNode.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()){
      //Invalid
      return;
    }

    _formKey.currentState!.save();

    context.read<AuthCubit>().logIn(email: _email, password: _pass);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (prevState, currentState) {
          if (currentState is AuthLogIn) {
            //Navigator.of(context).popAndPushNamed(PostScreen.id);
          }

          if (currentState is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: Duration(seconds: 2),
                content: Text(currentState.message)));
          }

        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(child: CircularProgressIndicator(color: Colors.white,),);
          }

          return SafeArea(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                // Прокрутка страницы, если это необходимо
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Text("Social Media App", style: Theme.of(context).textTheme.headline3,),
                      ),
                      SizedBox(height: 15,),
                      //email
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          labelText: "Enter your email",
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_passFocusNode); //Переход на поле username
                        },
                        onChanged: (value) {
                          _email = value.trim();
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter your email";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15,),
                      //password
                      TextFormField(
                        focusNode: _passFocusNode,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          labelText: "Enter your password",
                        ),
                        textInputAction: TextInputAction.done,
                        obscureText: true, // Скрытый текст
                        onFieldSubmitted: (_) {
                          _submit(context);
                        },
                        onChanged: (value) {
                          _pass = value;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter your password";
                          }
                          if  (value.length < 6) {
                            return "The password must be more than 6 characters long";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15,),
                      // LogIN & Auth with Google
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextButton(onPressed:(){
                            Navigator.of(context).popAndPushNamed(SignUpScreen.id);
                          }, child: Text("Sign Up", style: TextStyle(fontSize: 20),),),
                          Text("/"),
                          TextButton(onPressed:(){}, child: Text("Continue with Google", style: TextStyle(fontSize: 20),),),
                        ],
                      ),
                      TextButton(onPressed: (){
                        _submit(context);
                      }, child: Text("Log In", style: TextStyle(fontSize: 30),),),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
