import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_page.dart';
import 'register_page.dart';
import 'dart:developer';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _email_controller = TextEditingController();
  final TextEditingController _password_controller = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0, bottom: 60.0),
              child: Center(
                  // child: Text("ListShare")
                  child: Image.asset(
                    "assets/listlogo.jpg",
                    // height: 30,
                  )
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
                controller: _email_controller,
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
                controller: _password_controller,
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              ),
            ),
            // TextButton(
            //   onPressed: (){
            //     //TODO FORGOT PASSWORD SCREEN GOES HERE
            //   },
            //   child: const Text(
            //     'Forgot Password',
            //     style: TextStyle(color: Colors.blue, fontSize: 15),
            //   ),
            // ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () async {
                  bool success = await authenticate(_email_controller.text, _password_controller.text);
                  if (success) {
                     Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const DashboardPage()));
                  } else {
                    final scaffold = ScaffoldMessenger.of(context);
                    scaffold.showSnackBar(
                      const SnackBar(
                        content: Text('Login Failed'),
                        // action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            const SizedBox(
              height: 130,
            ),
            TextButton(
              onPressed: (){
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const RegisterPage()));
              },
              child: const Text(
                'Create Account',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> authenticate(email, password) async {
  // final storage = new FlutterSecureStorage();
  // final response = await http
  //     .get(Uri.parse('http://127.0.0.1:3000/login'));
  if (email == '') {
    email = 'aab@bbb.ccc';
  }
  if (password == '') {
    password = 'test';
  }
  final response = await http.post(
    Uri.parse('http://127.0.0.1:3000/login'),
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
    log(success.toString());
    log(responseObj.toString());
    log(responseObj['token']);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', responseObj['token']);
    String token = prefs.getString('token').toString();
    log(token);
    return true;
  } else {
    return false;
  }
}
