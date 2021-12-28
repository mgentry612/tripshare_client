import 'package:flutter/material.dart';
import 'lists.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ListDetailsPage extends StatefulWidget {
  const ListDetailsPage({Key? key, required this.listId, required this.joinable}) : super(key: key);
  final int listId;
  final bool joinable;

  @override
  _ListDetailsPagePageState createState() => _ListDetailsPagePageState();
}

class _ListDetailsPagePageState extends State<ListDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Details'),
      ),
      body: ListView (
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            MyCustomForm(listId: widget.listId, joinable: widget.joinable),
            //AddListItem(),
            !widget.joinable ? ListItems(listId: widget.listId) : const Text(''),
            !widget.joinable ? Comments(listId: widget.listId) : const Text(''),
            // NewItem(),
          ]
      ),
    );
  }
}

// Create a Form widget.
// Allows for the list to be submitted
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key, required this.listId, required this.joinable}) : super(key: key);

  final int listId;
  final bool joinable;

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
    return FutureBuilder<dynamic>(
        future: refreshListDetails(widget.listId),
        builder: (context, snapshot) {
          log('futuredata');
          log(snapshot.data.runtimeType.toString());
          log(snapshot.data.toString());
          if (snapshot.hasData) {
            log(snapshot.data['name'].toString());
            listName = snapshot.data['name'];
            listDescription = snapshot.data['description'];
            listStore = snapshot.data['store'];
            return Form(
              autovalidateMode: AutovalidateMode.always,
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      widget.joinable ? Container(
                      margin: const EdgeInsets.only(top: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              bool success = await joinList(widget.listId);
                              if (success) {
                                final scaffold = ScaffoldMessenger.of(context);
                                scaffold.showSnackBar(
                                  const SnackBar(
                                    content: Text('Successfully Joined List'),
                                  ),
                                );
                                setState(() {});
                              } else {
                                final scaffold = ScaffoldMessenger.of(context);
                                scaffold.showSnackBar(
                                  const SnackBar(
                                    content: Text('You are already a member of this list.'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Join List'),
                          ),
                        ),
                      ) : const Text(''),
                      !widget.joinable ? Container(
                        margin: const EdgeInsets.only(top: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              bool success = await completeList(widget.listId);
                              if (success) {
                                final scaffold = ScaffoldMessenger.of(context);
                                scaffold.showSnackBar(
                                  const SnackBar(
                                    content: Text('List Completed'),
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
                                    content: Text('Error Completing List.'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Complete List'),
                          ),
                        ),
                      ) : const Text(''),
                      !widget.joinable ? Container(
                        margin: const EdgeInsets.only(top: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              await deleteList(widget.listId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ListsPage()),
                              );
                            },
                            child: const Text('Delete List'),
                          ),
                        ),
                      ) : const Text(''),
                    ]
                  ),
                  const Center(
                    child: Text("Details", style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.black,
                    ))
                  ),
                  TextFormField(
                    initialValue: listName,
                    enabled: !widget.joinable,
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
                    initialValue: listDescription,
                    enabled: !widget.joinable,
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
                    initialValue: listStore,
                    enabled: !widget.joinable,
                    decoration: const InputDecoration(
                      labelText: 'Description',
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
                  !widget.joinable ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validate returns true if the form is valid, or false otherwise.
                        log(_formKey.toString());
                        log(_formKey.currentState.toString());
                        if (_formKey.currentState!.validate()) {

                          bool success = await updateList(listName, listDescription, listStore, widget.listId);
                          if (success) {
                            final scaffold = ScaffoldMessenger.of(context);
                            scaffold.showSnackBar(
                              const SnackBar(
                                content: Text('Successfully Updated List'),
                              ),
                            );
                            setState(() {});
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
                      child: const Text('Update'),
                    ),
                  ) : const Text(''),
                ],
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        }
    );
  }
}


class ListItems extends StatefulWidget {
  const ListItems({Key? key, required this.listId}) : super(key: key);

  final int listId;

  @override
  _ListItemsState createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    log('snapshot.data.toString()');
  }

  @override
  Widget build(BuildContext context) {
    String itemName = '';
    return Center(
      child: Column(
        children: <Widget>[
          FutureBuilder<List<dynamic>?>(
            future: refreshItems(widget.listId),
            builder: (context, snapshot) {
              log('futuredata');
              log(snapshot.data.toString());
              if (snapshot.hasData) {
                return Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Center(
                          child: Text("Items", style: TextStyle(
                            fontSize: 24.0,
                            color: Colors.black,
                          ))
                      ),
                    ),
                    ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300, minHeight: 50),
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          children: (snapshot.data ?? []).map((dynamic list) {
                            log(list.toString());
                            log(list['id'].toString());
                            return ListItem(
                              id: list['id'],
                              item_name: list['item_name'],
                              listItemContext: this,
                            );
                          }).toList(),
                        )
                    )
                  ]
                );
              } else {
                return const CircularProgressIndicator();
              }
            }
          ),
          Form(
            // autovalidateMode: AutovalidateMode.always,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(

              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  onSaved: (String? value) {
                    log('saved');
                  },
                  decoration: const InputDecoration(
                    labelText: 'Add Item',
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    itemName = value;
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      log(itemName);
                      bool success = await saveListItem(itemName, widget.listId);
                      log(success.toString());
                      if (success) {
                        final scaffold = ScaffoldMessenger.of(context);
                        scaffold.showSnackBar(
                          const SnackBar(
                            content: Text('Successfully Saved Item'),
                          ),
                        );
                        // futureItems = await refreshItems();
                        _formKey.currentState?.reset();
                        setState(() {});
                      } else {
                        final scaffold = ScaffoldMessenger.of(context);
                        scaffold.showSnackBar(
                          const SnackBar(
                            content: Text('Item Creation Failed'),
                          ),
                        );
                      }
                      // log(list.toString());
                    },
                    child: const Text('Save Item'),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}

class ListItem extends StatelessWidget {
  const ListItem({
    Key? key,
    required this.id,
    required this.item_name,
    required this.listItemContext,
  }) : super(key: key);

  final int id;
  final String item_name;
  final _ListItemsState listItemContext;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // onTap: () {
      //   // Navigator.push(
      //   //   context,
      //   //   MaterialPageRoute(builder: (context) => const ListDetailsPage()),
      //   // );
      // },
      // leading: CircleAvatar(
      //   child: Text(item_name),
      // ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        tooltip: 'Delete Item from List',
        onPressed: () async {
          bool success = await deleteListItem(id);
          if (success) {
            final scaffold = ScaffoldMessenger.of(context);
            scaffold.showSnackBar(
              const SnackBar(
                content: Text('Successfully Deleted Item'),
              ),
            );
            // futureItems = await refreshItems();
            listItemContext.setState(() {});
          } else {
            final scaffold = ScaffoldMessenger.of(context);
            scaffold.showSnackBar(
              const SnackBar(
                content: Text('Item Deletion Failed'),
              ),
            );
          }
        },
      ),
      title: Text(
        item_name,
      ),
    );
  }
}




class Comments extends StatefulWidget {
  const Comments({Key? key, required this.listId}) : super(key: key);

  final int listId;

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    log('snapshot.data.toString()');
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    String newCommentText = '';
    return Center(
        child: Column(
          children: <Widget>[
            FutureBuilder<List<dynamic>?>(
                future: refreshComments(widget.listId),
                builder: (context, snapshot) {
                  log('futuredata');
                  log(snapshot.data.toString());
                  if (snapshot.hasData) {
                    return Column(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Center(
                                child: Text("Comments", style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.black,
                                ))
                            ),
                          ),
                          ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 300, minHeight: 50),
                              child: ListView(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                children: (snapshot.data ?? []).map((dynamic comment) {
                                  return CommentItem(
                                    created_at: comment['created_at'],
                                    comment: comment['comment'],
                                    user_id: comment['user_id'],
                                    id: comment['id'],
                                    email: comment['email'],
                                    commentItemContext: this,
                                  );
                                }).toList(),
                              )
                          )
                        ]
                    );
                  } else {
                    return Column(
                        children: const <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Text("")
                        ),
                      ],
                    );
                  }
                }
            ),
            Form(
              // autovalidateMode: AutovalidateMode.always,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(

                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    onSaved: (String? value) {
                      log('saved');
                    },
                    decoration: const InputDecoration(
                      labelText: 'Add Comment',
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      newCommentText = value;
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        log(newCommentText);
                        bool success = await saveComment(newCommentText, widget.listId);
                        log(success.toString());
                        if (success) {
                          final scaffold = ScaffoldMessenger.of(context);
                          scaffold.showSnackBar(
                            const SnackBar(
                              content: Text('Successfully Saved Comment'),
                            ),
                          );
                          _formKey.currentState?.reset();
                          setState(() {});
                        } else {
                          final scaffold = ScaffoldMessenger.of(context);
                          scaffold.showSnackBar(
                            const SnackBar(
                              content: Text('Comment Saving Failed'),
                            ),
                          );
                        }
                        // log(list.toString());
                      },
                      child: const Text('Save Comment'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
}



class CommentItem extends StatelessWidget {
  const CommentItem({
    Key? key,
    required this.created_at,
    required this.comment,
    required this.user_id,
    required this.id,
    required this.email,
    required this.commentItemContext,
  }) : super(key: key);

  final String created_at;
  final String comment;
  final int user_id;
  final int id;
  final String email;
  final _CommentsState commentItemContext;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const ListPage()),
        // );
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        tooltip: 'Delete Item from List',
        onPressed: () async {
          bool success = await deleteComment(id);
          if (success) {
            final scaffold = ScaffoldMessenger.of(context);
            scaffold.showSnackBar(
              const SnackBar(
                content: Text('Successfully Deleted Comment'),
              ),
            );
            // futureItems = await refreshItems();
            commentItemContext.setState(() {});
          } else {
            final scaffold = ScaffoldMessenger.of(context);
            scaffold.showSnackBar(
              const SnackBar(
                content: Text('Item Deletion Failed'),
              ),
            );
          }
        },
      ),
      title: Text(
        '$created_at $email:\n$comment',
      ),
    );
  }
}

// class Comments extends StatefulWidget {
//   const Comments({Key? key, required this.listId}) : super(key: key);
//
//   final int listId;
//
//   @override
//   _CommentsState createState() => _CommentsState();
// }
//
// class _CommentsState extends State<Comments> {
//   late Future<List<dynamic>?> futureComments;
//
//   @override
//   void initState() {
//     super.initState();
//     futureComments = refreshComments(widget.listId);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         children: <Widget>[
//           const Padding(
//             padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
//             child: Center(m
//                 child: Text("Comments")
//             ),
//           ),
//           FutureBuilder<List<dynamic>?>(
//               future: futureComments,
//               builder: (context, snapshot) {
//                 log(snapshot.data.toString());
//                 if (snapshot.hasData) {
//                   return ConstrainedBox(
//                       constraints: const BoxConstraints(maxHeight: 300, minHeight: 50),
//                       child: ListView(
//                         shrinkWrap: true,
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         children: (snapshot.data ?? []).map((dynamic comment) {
//                           log(comment.toString());
//                           return CommentItem(
//                             created_at: comment['created_at'],
//                             comment: comment['comment'],
//                             user_id: comment['user_id'],
//                             email: comment['email'],
//                           );
//                         }).toList(),
//                       )
//                   );
//                 } else {
//                   return const CircularProgressIndicator();
//                 }
//               }
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               CommentsForm(listId: widget.listId)
//             ],
//           ),
//         ],
//       )
//     );
//   }
// }
//
// // Create a Form widget.
// class CommentsForm extends StatefulWidget {
//   const CommentsForm({Key? key, required this.listId}) : super(key: key);
//
//   final int listId;
//
//   @override
//   _CommentsFormState createState() {
//     return _CommentsFormState();
//   }
// }
//
// // Create a corresponding State class.
// // This class holds data related to the form.
// class _CommentsFormState extends State<CommentsForm> {
//   // Create a global key that uniquely identifies the Form widget
//   // and allows validation of the form.
//   //
//   // Note: This is a GlobalKey<FormState>,
//   // not a GlobalKey<MyCustomFormState>.
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     // Build a Form widget using the _formKey created above.
//     String newCommentText = '';
//     return Form(
//       autovalidateMode: AutovalidateMode.always,
//       key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               height: 300,
//               width: 300,
//               child: TextFormField(
//                 // maxLines: 8,
//                 decoration: const InputDecoration.collapsed(hintText: "Add a Comment"),
//                 // The validator receives the text that the user has entered.
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'This field is required';
//                   }
//                   newCommentText = value;
//                   return null;
//                 },
//               )
//           ),
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               child: ElevatedButton(
//                 onPressed: () async {
//                   // Validate returns true if the form is valid, or false otherwise.
//                   if (_formKey.currentState!.validate()) {
//
//                     bool success = await saveComment(newCommentText, widget.listId);
//                     if (success) {
//                       final scaffold = ScaffoldMessenger.of(context);
//                       scaffold.showSnackBar(
//                         const SnackBar(
//                           content: Text('Successfully Added Comment'),
//                         ),
//                       );
//                       refreshComments(widget.listId);
//                     } else {
//                       final scaffold = ScaffoldMessenger.of(context);
//                       scaffold.showSnackBar(
//                         const SnackBar(
//                           content: Text('Failed to Save Comment'),
//                         ),
//                       );
//                     }
//                   }
//                 },
//                 child: const Text('Save Comment'),
//               )
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class CommentItem extends StatelessWidget {
//   const CommentItem({
//     Key? key,
//     required this.created_at,
//     required this.comment,
//     required this.user_id,
//     required this.email,
//   }) : super(key: key);
//
//   final String created_at;
//   final String comment;
//   final int user_id;
//   final String email;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: () {
//         // Navigator.push(
//         //   context,
//         //   MaterialPageRoute(builder: (context) => const ListPage()),
//         // );
//       },
//       title: Text(
//         '$created_at $email: $comment',
//       ),
//     );
//   }
// }

// TODO: remove question mark
Future<List<dynamic>?> refreshComments(listId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();
  // TODO: if no token redirect to login

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

Future<bool> saveComment(newCommentText, listId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();

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




Future<bool> saveListItem(itemName, listId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();

  final response = await http.post(
    Uri.parse('http://127.0.0.1:3000/list/items'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, String>{
      'item_name': itemName,
      'list_id': listId.toString(),
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

Future<bool> deleteListItem(itemId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();

  final response = await http.delete(
    Uri.parse('http://127.0.0.1:3000/list/items/$itemId'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
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

Future<bool> deleteComment(commentId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();

  final response = await http.delete(
    Uri.parse('http://127.0.0.1:3000/list/comment/$commentId'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
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

// TODO: remove question mark
Future<List<dynamic>?> refreshItems(int listId) async {
  log('refreshItemsStart');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();
  // TODO: if no token redirect to login

  final httpResponse = await http
      .get(Uri.parse('http://127.0.0.1:3000/list/$listId/items'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      });
  log(httpResponse.body);

  final jsonResponse = json.decode(httpResponse.body);
  log(jsonResponse.toString());
  log(jsonResponse['items'].toString());

  List<dynamic> items = jsonResponse['items'];
  log('refreshItems');
  log(items.toString());

  return items;
}

// TODO: remove question mark
Future<dynamic> refreshListDetails(int listId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();
  // TODO: if no token redirect to login
  log('refreshListDetails');

  final httpResponse = await http
      .get(Uri.parse('http://127.0.0.1:3000/list/$listId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      });
  log(httpResponse.body);

  final jsonResponse = json.decode(httpResponse.body);
  log(jsonResponse.toString());
  log(jsonResponse['list'].toString());

  dynamic list = jsonResponse['list'];
  log('refreshListDetails');
  log(list.toString());

  return list;
}

Future<bool> joinList(listId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();

  final response = await http.post(
    Uri.parse('http://127.0.0.1:3000/list/$listId/join'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
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

Future<bool> deleteList(listId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();

  final response = await http.delete(
    Uri.parse('http://127.0.0.1:3000/list/$listId'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
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
Future<bool> completeList(listId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();

  final response = await http.put(
    Uri.parse('http://127.0.0.1:3000/list/$listId/status'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
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

Future<bool> updateList(listName, listDescription, listStore, listId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();

  final response = await http.put(
    Uri.parse('http://127.0.0.1:3000/list/$listId'),
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
