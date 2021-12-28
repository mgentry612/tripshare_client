// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'create_list_page.dart';
import 'list_details_page.dart';
import 'dashboard_page.dart';
import 'dart:developer';

class ListsPage extends StatefulWidget {
  const ListsPage({Key? key}) : super(key: key);

  @override
  _ListsPageState createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  // TODO: remove question mark

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Lists',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // theme: ThemeData(
      //   primaryColor: Colors.white,
      // ),
      // theme: ThemeData.dark(),
      home: const RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  // final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18.0);
  // List<dynamic>? lists = <dynamic>[] ;
  late Future<List<dynamic>?> futureLists;

  @override
  void initState() {
    super.initState();
    log('snapshot.data.toString()');
    // refreshLists().then((List<dynamic>? myLists) {
    //   lists = myLists;
    // });
    futureLists = refreshLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        actions: [
          IconButton(icon: const Icon(Icons.list), onPressed: goToDashboard),
        ],
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: futureLists,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: (snapshot.data ?? []).map((dynamic list) {
                return ShoppingListItem(
                  id: list['id'],
                  name: list['name'],
                );
              }).toList(),

              // widget.products.map((Product product) {
              //   return ShoppingListItem(
              //     product: product,
              //   );
              // }).toList(),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Center(
                  child: Text("No Pending Lists")
              ),
            );
          }
          // return ListView.builder(
          //     padding: const EdgeInsets.all(16.0),
          //     itemBuilder: /*1*/ (context, i) {
          //       log(i.toString());
          //       if (i.isOdd) return const Divider(); /*2*/
          //       log(i.toString());
          //
          //       // final index = i ~/ 2; /*3*/
          //       // if (index >= _suggestions.length) {
          //       //   _suggestions.addAll(generateWordPairs().take(10)); /*4*/
          //       // }
          //       // return _buildRow(futureLists[index]);
          //       return const CircularProgressIndicator();
          //     });
          // // return _buildSuggestions();
        }
        // builder: _buildSuggestions(),
      ),
      // body: _buildSuggestions(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const CreateListPage()));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  void goToDashboard() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const DashboardPage()));
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final tiles = _saved.map(
                (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(context: context, tiles: tiles).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  // Widget _buildSuggestions() {
  //   return ListView.builder(
  //       padding: const EdgeInsets.all(16.0),
  //       itemBuilder: /*1*/ (context, i) {
  //         if (i.isOdd) return const Divider(); /*2*/
  //
  //         // final index = i ~/ 2; /*3*/
  //         // if (index >= _suggestions.length) {
  //         //   _suggestions.addAll(generateWordPairs().take(10)); /*4*/
  //         // }
  //         return _buildRow(_buildSuggestions[index]);
  //       });
  // }

//   Widget _buildRow(WordPair pair) {
//     final alreadySaved = _saved.contains(pair);
//     return ListTile(
//       title: Text(
//         pair.asPascalCase,
//         style: _biggerFont,
//       ),
//       trailing: Icon(
//         alreadySaved ? Icons.favorite : Icons.favorite_border,
//         color: alreadySaved ? Colors.red : null,
//       ),
//       onTap: () {
//         // setState(() {
//         //   if (alreadySaved) {
//         //     _saved.remove(pair);
//         //   } else {
//         //     _saved.add(pair);
//         //   }
//         // });
//         // Navigator.push(
//         //     context, MaterialPageRoute(builder: (_) => const ListDetailsPage()));
//       },
//     );
//   }
}

class ShoppingListItem extends StatelessWidget {
  const ShoppingListItem({
    Key? key,
    required this.id,
    required this.name,
  }) : super(key: key);

  final int id;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListDetailsPage(listId: id, joinable: false)),
        );
      },
      leading: CircleAvatar(
        child: Text(name),
      ),
      title: Text(
        name,
      ),
    );
  }
}

class Response {
  final int status;
  final List<MyList> myLists;


  Response({required this.status, required this.myLists});

  factory Response.fromJson(Map<String, dynamic> parsedJson) {
    var lists = parsedJson['lists'] as List;
    log(lists.toString());
    List<MyList> myLists = lists.map((i) => MyList.fromJson(i)).toList();
    log('lists.toString()');

    return Response(
        status: parsedJson['status'],
        myLists: myLists
    );
  }
}

class MyList {
  final String name;
  final String description;

  MyList({required this.name, required this.description});

  factory MyList.fromJson(Map<String, dynamic> parsedJson) {
    return MyList(
        name: parsedJson['name'],
        description: parsedJson['description'],
    );
  }
}

// TODO: remove question mark
Future<List<dynamic>?> refreshLists() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token').toString();
  // TODO: if no token redirect to login

  final httpResponse = await http
      .get(Uri.parse('http://127.0.0.1:3000/list'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      });
  log(httpResponse.body);
  // log(response.body.toString());

  final jsonResponse = json.decode(httpResponse.body);
  log(jsonResponse.toString());
  log(jsonResponse['lists'].toString());
  Response response = Response.fromJson(jsonResponse);
  log(response.myLists[0].name.toString());

  List<dynamic> lists = jsonResponse['lists'];
  log('return');
  log(lists.toString());

  return lists;
}
