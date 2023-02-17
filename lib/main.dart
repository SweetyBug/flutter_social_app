import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/bloc/auth_cubit.dart';
import 'package:social_media_app/screens/chat_screen.dart';
import 'package:social_media_app/screens/create_post.dart';
import 'package:social_media_app/screens/log_in_screen.dart';
import 'package:social_media_app/screens/posts_screen.dart';
import 'package:social_media_app/screens/sign_up_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init((options) {
    options.dsn = 'https://34299d60c762466f87d729d69d2548a8@o4504697054298112.ingest.sentry.io/4504697056722944';
  },
      // Init your App.
      appRunner: () async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Проверка заррегистрирован ли юзер
  Widget _buildHomeScreen() {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PostScreen();
          } else {
            return SignUpScreen();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: _buildHomeScreen(),
        routes: {
          SignUpScreen.id: (context) => SignUpScreen(),
          LogInScreen.id: (context) => LogInScreen(),
          PostScreen.id: (context) => PostScreen(),
          CreatePost.id: (context) => CreatePost(),
          ChatScreen.id: (context) => ChatScreen(),
        },
      ),
    );
  }
}
