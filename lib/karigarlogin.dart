import 'package:flutter/material.dart';
import 'package:lmrepaireagent/Karigarform.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

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
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                    label: Text("password"),
                    border: OutlineInputBorder()),
              ),
            ),
            ElevatedButton(onPressed:(){
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>KarigarApp()));
            } , child:Text("Login") )
          ],

        ),
      )
    );
  }
}
