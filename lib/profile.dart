import 'package:flutter/material.dart';


class profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.arrow_back),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.menu), onPressed: () {}),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                child: Icon(Icons.person_outline),
                radius: 40,
              ),
              SizedBox(height: 10),
              Text('Name', style: TextStyle(fontSize: 25)),
              Text('Designation', style: TextStyle(fontSize: 15)),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.email),
                title: TextField(decoration: InputDecoration(labelText: 'Email :')),
              ),
              ListTile(
                leading: Icon(Icons.directions_car),
                title: TextField(decoration: InputDecoration(labelText: 'Vehicle :')),
              ),
              ListTile(
                leading: Icon(Icons.location_city),
                title: TextField(decoration: InputDecoration(labelText: 'City :')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
