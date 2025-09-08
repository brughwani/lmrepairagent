import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lmrepaireagent/KarigarHome.dart';
import 'package:lmrepaireagent/Karigarform.dart';
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    super.initState();
    role="Karigar";
  }

  // Future<void> LoginUser(String phoneNumber, String password) async {
  //   // Call your Node.js backend for registration
  //   final response = await http.post(
  //     Uri.parse('https://limsonvercelapi2.vercel.app/api/fsauth'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'phoneNumber': phoneNumber,
  //       'password': password,
  //       'app': role!,
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     // User registered successfully
  //     print('User logged in successfully!');
  //     Navigator.of(context).push(MaterialPageRoute(builder: (context)=>KarigarHome(token: token, name: name)));
  //   } else {
  //     // Handle error
  //     print('Error: ${response.body}');
  //   }
  // }

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
            ElevatedButton(onPressed:(){

        //    var url=Uri.parse('https://limsonvercelapi2.vercel.app/api/fsauth');
//LoginUser(phoneController.text, passwordController.text);
            AuthService(baseUrl: 'https://limsonvercelapi2.vercel.app').authenticate(phoneController.text, passwordController.text, role!, context);


              //Navigator.of(context).push(MaterialPageRoute(builder: (context)=>KarigarApp()));

            } , child:Text("Login") )
          ],

        ),
      )
    );
  }
}
