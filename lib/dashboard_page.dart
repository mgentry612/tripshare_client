import 'package:flutter/material.dart';
import 'create_list_page.dart';
import 'lists.dart';
import 'join_lists.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      "assets/listlogo.jpg",
                    // height: 30,
                    )
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: MaterialButton(
                        height: 100.0,
                        minWidth: 150.0,
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: const Text("Create a List"),
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreateListPage()),
                          )
                        },
                        splashColor: Colors.redAccent,
                      )
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: MaterialButton(
                        height: 100.0,
                        minWidth: 150.0,
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: const Text("View My Lists"),
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ListsPage()),
                          )
                        },
                        splashColor: Colors.redAccent,
                      )
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: MaterialButton(
                        height: 100.0,
                        minWidth: 150.0,
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: const Text("Join a List"),
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const JoinListsPage()),
                          )
                        },
                        splashColor: Colors.redAccent,
                      )
                  ),
                ],
              ),
            ],
          )
      ),
      // body: Center(
      //   child: Container(
      //     height: 80,
      //     width: 150,
      //     decoration: BoxDecoration(
      //         color: Colors.blue, borderRadius: BorderRadius.circular(10)),
      //     child: TextButton(
      //       onPressed: () {
      //         Navigator.pop(context);
      //       },
      //       child: const Text(
      //         'Welcome',
      //         style: TextStyle(color: Colors.white, fontSize: 25),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}