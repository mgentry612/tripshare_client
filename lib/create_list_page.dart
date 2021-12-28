import 'package:flutter/material.dart';
import 'lists.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CreateListPage extends StatefulWidget {
  const CreateListPage({Key? key}) : super(key: key);

  @override
  _CreateListPageState createState() => _CreateListPageState();
}

class _CreateListPageState extends State<CreateListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a List'),
      ),
      body: ListView (
        padding: const EdgeInsets.all(8),
        children: const <Widget>[
          MyCustomForm(),
          //AddListItem(),
          // GenerateList(),
        ]
      ),
    );
  }
}

// Create a Form widget.
// Allows for the list to be submitted
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key}) : super(key: key);

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    String listName = '';
    String listDescription = '';
    String listStore = '';
    return Form(
      autovalidateMode: AutovalidateMode.always,
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            onSaved: (String? value) {
              log('saved');
            },
            decoration: const InputDecoration(
              labelText: 'Name *',
            ),
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              listName = value;
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Description',
            ),
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              listDescription = value;
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Store',
            ),
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              listStore = value;
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                log(_formKey.toString());
                log(_formKey.currentState.toString());
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );

                  bool success = await saveList(listName, listDescription, listStore);
                  if (success) {
                    final scaffold = ScaffoldMessenger.of(context);
                    scaffold.showSnackBar(
                      const SnackBar(
                        content: Text('Successfully Saved List'),
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ListsPage()),
                    );
                  } else {
                    final scaffold = ScaffoldMessenger.of(context);
                    scaffold.showSnackBar(
                      const SnackBar(
                        content: Text('List Creation Failed'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> saveList(listName, listDescription, listStore) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();

  final response = await http.post(
    Uri.parse('http://127.0.0.1:3000/list'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, String>{
      'name': listName,
      'description': listDescription,
      'store': listStore,
    }),
  );
  log(response.body);
  Map<String, dynamic> responseObj = jsonDecode(response.body);
  int status = responseObj['status'];
  if (status == 200) {
    log(responseObj.toString());
    return true;
  } else {
    return false;
  }
}
