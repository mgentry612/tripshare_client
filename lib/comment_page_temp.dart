import 'package:flutter/material.dart';
import 'lists.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CommentTempPage extends StatefulWidget {
  const CommentTempPage({Key? key}) : super(key: key);

  @override
  _CommentTempPageState createState() => _CommentTempPageState();
}

class _CommentTempPageState extends State<CommentTempPage> {
  late Future<List<dynamic>?> futureComments;

  @override
  void initState() {
    super.initState();
    futureComments = refreshComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments Test Page'),
      ),
      body: Center(
          child: Column(
            children: <Widget>[
              FutureBuilder<List<dynamic>?>(
                  future: futureComments,
                  builder: (context, snapshot) {
                    log('futuredata');
                    log(snapshot.data.toString());
                    if (snapshot.hasData) {
                      return SizedBox(
                        height: 400,
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          children: (snapshot.data ?? []).map((dynamic comment) {
                            log(comment.toString());
                            return CommentItem(
                              created_at: comment['created_at'],
                              comment: comment['comment'],
                              user_id: comment['user_id'],
                              email: comment['email'],
                            );
                          }).toList(),
                        )
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                }
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  CommentsForm()
                ],
              ),
            ],
          )
      ),
    );
  }
}

// Create a Form widget.
class CommentsForm extends StatefulWidget {
  const CommentsForm({Key? key}) : super(key: key);

  @override
  CommentsFormState createState() {
    return CommentsFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class CommentsFormState extends State<CommentsForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    String newCommentText = '';
    return Form(
      autovalidateMode: AutovalidateMode.always,
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              width: 300,
              child: TextFormField(
                maxLines: 8,
                decoration: const InputDecoration.collapsed(hintText: "Add a Comment"),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  newCommentText = value;
                  return null;
                },
              )
            ),
            SizedBox(
              height: 100,
              width: 300,
              child: Padding(
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

                      bool success = await saveComment(newCommentText);
                      if (success) {
                        final scaffold = ScaffoldMessenger.of(context);
                        scaffold.showSnackBar(
                          const SnackBar(
                            content: Text('Successfully Added Comment'),
                          ),
                        );
                        // Refresh comments
                      } else {
                        final scaffold = ScaffoldMessenger.of(context);
                        scaffold.showSnackBar(
                          const SnackBar(
                            content: Text('Failed to Save Comment'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Submit'),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  const CommentItem({
    Key? key,
    required this.created_at,
    required this.comment,
    required this.user_id,
    required this.email,
  }) : super(key: key);

  final String created_at;
  final String comment;
  final int user_id;
  final String email;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const ListPage()),
        // );
      },
      title: Text(
        '$created_at $email: $comment',
      ),
    );
  }
}

// TODO: remove question mark
Future<List<dynamic>?> refreshComments() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();
  // TODO: if no token redirect to login
  // TODO: make dynamic
  int listId = 1;

  final httpResponse = await http
      .get(Uri.parse('http://127.0.0.1:3000/list/$listId/comment'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      });
  log(httpResponse.body);
  // log(response.body.toString());

  log('return0');
  final jsonResponse = json.decode(httpResponse.body);
  log(jsonResponse.toString());
  log(jsonResponse['comments'].toString());
  log('return1');
  // GetCommentsResponse response = GetCommentsResponse.fromJson(jsonResponse);
  log('return2');
  // log(response.myComments[0].comment.toString());

  List<dynamic> comments = jsonResponse['comments'];
  log('return');
  log(comments.toString());

  return comments;
}

Future<bool> saveComment(newCommentText) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();
  // TODO: make dynamic
  int listId = 1;

  final response = await http.post(
    Uri.parse('http://127.0.0.1:3000/list/$listId/comment'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, String>{
      'comment': newCommentText,
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