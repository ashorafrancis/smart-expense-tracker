import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                "Smart Expense Tracker",

                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: emailController,

                decoration: InputDecoration(
                  hintText: "Email",

                  prefixIcon: const Icon(Icons.email),

                  filled: true,
                  fillColor: Theme.of(context).cardColor,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,

                obscureText: true,

                decoration: InputDecoration(
                  hintText: "Password",

                  prefixIcon: const Icon(Icons.lock),

                  filled: true,
                  fillColor: Theme.of(context).cardColor,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),

                  onPressed: () async {
                    try {
                      final response = await ApiService.loginUser(
                        email: emailController.text,

                        password: passwordController.text,
                      );

                      if (response['token'] != null) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        await prefs.setBool('isLoggedIn', true);

                        await prefs.setString('token', response['token']);
                        debugPrint(response['token']);

                        await prefs.setString('email', emailController.text);

                        await prefs.setString('name', response['user']['name']);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(response['message'])),
                        );

                        Navigator.pushReplacement(
                          context,

                          MaterialPageRoute(
                            builder: (context) =>
                                MainScreen(toggleTheme: () {}),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },

                  child: const Text(
                    "Login",

                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },

                child: const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
