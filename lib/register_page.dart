import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'dart:developer';


class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Create Account"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 60.0, bottom: 60.0),
              child: Center(
                  child: Text("Create Account")
                // child: SizedBox(
                //     width: 200,
                //     height: 150,
                //     /*decoration: BoxDecoration(
                //         color: Colors.red,
                //         borderRadius: BorderRadius.circular(50.0)),*/
                //     child: Text("ListShare")),
                // child: Image.asset('asset/images/flutter-logo.png')),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Enter valid email id as abc@gmail.com'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () async {
                  bool success = await register(emailController.text, passwordController.text);
                  if (success) {
                    // Navigator.push(
                    //     context, MaterialPageRoute(builder: (_) => const DashboardPage()));
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const Login()));
                  } else {
                    final scaffold = ScaffoldMessenger.of(context);
                    scaffold.showSnackBar(
                      const SnackBar(
                        content: Text('Account Creation Failed'),
                        // action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Create Account',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> register(email, password) async {
  log(email);
  final response = await http.post(
    Uri.parse('http://127.0.0.1:3000/signup'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
    }),
  );
  log(response.body);
  Map<String, dynamic> responseObj = jsonDecode(response.body);
  bool success = responseObj['success'];
  if (success) {
    return true;
  } else {
    return false;
  }
}