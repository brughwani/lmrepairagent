import 'package:flutter/material.dart';
import 'package:lmrepaireagent/authservice.dart';

class LoginForm extends StatefulWidget {
   LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController phoneController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  String? role;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    role = "Karigar";
  }

  Future<void> _handleLogin() async {
    if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both login ID and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService(baseUrl: 'https://limsonvercelapi2.vercel.app')
          .authenticate(phoneController.text, passwordController.text, role!, context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"),),
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                    label: Text("Login id"),
                    border: OutlineInputBorder()),
                controller: phoneController,
                keyboardType: TextInputType.phone,

              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                    label: Text("password"),
                    border: OutlineInputBorder()),
                controller: passwordController,
                obscureText: true,
              ),
            ),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text("Login"),
                  ),
          ],

        ),
      )
    );
  }
}
