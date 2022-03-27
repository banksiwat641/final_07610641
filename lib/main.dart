import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'DataApi.dart';
import 'apt_re.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Quiz>? quiz_list;
  int count = 0;
  int wrong_guess = 0;
  String message = "";

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    List list = await Api().fetch('quizzes');
    setState(() {
      quiz_list = list.map((item) => Quiz.fromJson(item)).toList();
    });
  }

  void guess(String choice) {
    setState(() {
      if (quiz_list![count].answer == choice) {
        message = "เก่งมากครับ";
      } else {
        message = "ยังไม่ถูก ลองใหม่นะครับ";
      }
    });
    Timer timer = Timer(Duration(seconds: 2), () {
      setState(() {
        message = "";
        if (quiz_list![count].answer == choice) {
          count++;
        } else {
          wrong_guess++;
        }
      });
    });
  }

  Widget printGuess() {
    if (message.isEmpty) {
      return SizedBox(height: 20, width: 10);
    } else if (message == "เก่งมากครับ") {
      return Text(message,style: TextStyle(color: Colors.green,fontSize: 50),);
    } else {
      return Text(message,style: TextStyle(color: Colors.red,fontSize: 50));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: quiz_list != null && count < quiz_list!.length-1
          ? buildQuiz()
          : quiz_list != null && count == quiz_list!.length-1
          ? buildTryAgain()
          : const Center(child: CircularProgressIndicator()),
         backgroundColor: Color(0xF5AAEDF8),

    );
  }

  Widget buildTryAgain() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('จบเกม',style: TextStyle(fontSize: 50)),
            Text('ทายผิด ${wrong_guess} ครั้ง',style: TextStyle(fontSize: 30)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    wrong_guess = 0;
                    count = 0;
                    quiz_list = null;
                    _fetch();
                  });
                },
                child: Text('เริ่มเกมใหม่'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildQuiz() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.network(quiz_list![count].image, fit: BoxFit.cover),
            Column(
              children: [
                for (int i = 0; i < quiz_list![count].choice_list.length; i++)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                guess(quiz_list![count].choice_list[i].toString()),
                            child: Text(quiz_list![count].choice_list[i]),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            printGuess(),
          ],
        ),
      ),
    );
  }
}

class Quiz{
  final String image;
  final String answer;
  final List choice_list;

  Quiz({
    required this.image,
    required this.answer,
    required this.choice_list,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      image:  json["image"],
      answer:   json["answer"],
      choice_list:   (json['choice_list'] as List).map((choice) => choice).toList() ,
    );
  }
}
class Api {
  static const BASE_URL = 'https://cpsu-test-api.herokuapp.com';

  Future<dynamic> fetch(String endPoint, {
    Map<String, dynamic>? queryParams
  }) async {
    var url = Uri.parse('$BASE_URL/$endPoint');
    final response = await http.get(url, headers: {'id': '07610641'});
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonBody = json.decode(response.body);

      var apiResult = ApiResult.fromJson(jsonBody);
      print(apiResult.data);
      if (apiResult.status == 'ok') {
        return apiResult.data;
      }
      else {
        throw apiResult.message!;
      }
    }
    else {
      throw "Server connection failed";
    }
  }
}