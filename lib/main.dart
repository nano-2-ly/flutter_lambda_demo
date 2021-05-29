import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.black,
          accentColor: Colors.white),
      home: MyHomePage(title: 'AWS lambda demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: MovieInfo(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            //nothing to do
          });
        },
        tooltip: 'Increment',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Widget MovieInfo(BuildContext context) {
  var futureBuilder = new FutureBuilder(
    future: fetchPost(),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.none:
        case ConnectionState.waiting:
          return Center(
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
              ],
            ),
          );
        default:
          if (snapshot.hasError)
            return new Text('Error: ${snapshot.error}');
          else
            return buildBody(context, snapshot);
      }
    },
  );
  return futureBuilder;
}

Future<List> fetchPost() async {
  http.Response response = await http.get(Uri.parse(
      "https://gpo9r3cm1b.execute-api.ap-northeast-2.amazonaws.com/default/movie_test"));
  final parsed = await jsonDecode(response.body).cast<Map<String, dynamic>>();
  return parsed.map<Movie>((json) => Movie.fromJson(json)).toList();
}

Widget buildBody(BuildContext context, AsyncSnapshot snapshot) {
  List<Movie> movies = snapshot.data;

  return ListView(
    children: makeBoxImages(context, movies),
  );
}

List<Widget> makeBoxImages(BuildContext context, List<Movie> movies) {
  List<Widget> results = [];
  for (var i = 0; i < movies.length; i++) {
    results.add(
      Container(
        padding: EdgeInsets.all(50),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              Image.network(movies[i].poster),
              Text(
                movies[i].title,
                style: TextStyle(fontSize: 30),
              ),
              Text(
                movies[i].keyword,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white60,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  return results;
}

class Movie {
  final String title;
  final String keyword;
  final String poster;
  final bool like;

  Movie({this.title, this.keyword, this.poster, this.like});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] as String,
      keyword: json['keyword'] as String,
      poster: json['poster'] as String,
      like: json['like'] as bool,
    );
  }
}
