import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  File? image;
  String? _text;

  @override
  void dispose() async {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Recognition"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FractionallySizedBox(
            widthFactor: 0.85,
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        final image = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);

                        if (image == null) return;
                        final imageTemporary = File(image.path);
                        setState(() {
                          this.image = imageTemporary;
                        });
                      } on PlatformException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("FAILED_TO_PICK_IMAGE$e"),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFD5D6E4),
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.file(
                                image!,
                                fit: BoxFit.fill,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 20,
                                  color: Color(0xFF55C0F2),
                                ),
                                SizedBox(
                                  width: 50,
                                  child: Text(
                                    "UPLOAD IMAGE",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF55C0F2),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                GestureDetector(
                  onTap: () {
                    if (image == null) {
                      return;
                    }
                    processImage(image!);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Recognise Text",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                _text == null
                    ? const SizedBox()
                    : Text(
                        '\n\nRecognized text:\n\n$_text',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.black),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> processImage(File image) async {
    final recognizedText =
        await _textRecognizer.processImage(InputImage.fromFile(image));
    setState(() {
      _text = recognizedText.text;
    });

    log(_text.toString());
  }
}
