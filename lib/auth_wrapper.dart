import 'package:flutter/material.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screen/layout.dart';
import 'package:myapp/screen/login_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/firebase_service.dart';

class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key});

  final FirebaseService _auth = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('Something went wrong!')),
            );
          }
          if (snapshot.hasData) {
            final uid = snapshot.data?.uid;
            return FutureBuilder<Map<String, dynamic>?>(
              future: _auth.getUserData(uid),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (userSnapshot.hasError || userSnapshot.data == null) {
                  return const Scaffold(
                    body: Center(child: Text('Failed to load user data!')),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);

                  userProvider.setEmail(userSnapshot.data!["email"] ?? "");
                  userProvider
                      .setUsername(userSnapshot.data!["username"] ?? "");
                  userProvider.setBio(userSnapshot.data!["bio"] ?? "");
                  userProvider.setPhone(userSnapshot.data!["phone"] ?? "");
                });

                return const Layout();
              },
            );
          } else {
            return const LoginPage();
          }
        });
  }
}
