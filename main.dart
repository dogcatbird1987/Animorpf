import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(AnimorphVoiceApp());
}

class AnimorphVoiceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animorph Voice',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.deepPurpleAccent,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String message = "Tap to listen";
  String selectedAnimal = "cat";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _requestMicrophonePermission();
  }

  void _requestMicrophonePermission() async {
    await Permission.microphone.request();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          setState(() {
            _isListening = false;
            _speech.stop();
            _interpretAnimalSound();
          });
        });
      }
    }
  }

  void _interpretAnimalSound() async {
    setState(() {
      message = "Translating $selectedAnimal sound...";
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      if (selectedAnimal == "cat") {
        message = "I'm hungry. Please feed me.";
      } else if (selectedAnimal == "dog") {
        message = "I missed you all day!";
      } else if (selectedAnimal == "bird") {
        message = "The sky feels heavy today.";
      }
    });

    await flutterTts.speak(message);
  }

  Widget _animalIcon(String type, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAnimal = type;
        });
      },
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: selectedAnimal == type ? Colors.deepPurpleAccent : Colors.grey,
          ),
          SizedBox(height: 4),
          Text(
            type,
            style: TextStyle(
              color: selectedAnimal == type ? Colors.deepPurpleAccent : Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.graphic_eq, size: 80, color: Colors.deepPurpleAccent),
            SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _animalIcon("cat", Icons.pets),
                SizedBox(width: 20),
                _animalIcon("dog", Icons.pets),
                SizedBox(width: 20),
                _animalIcon("bird", Icons.filter_hdr),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _listen,
              child: Text("Listen"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
