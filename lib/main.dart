import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kuwagata_image_identification/classifier.dart';
import 'package:kuwagata_image_identification/classifier_quant.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as img;


final imageProvider = StateProvider<File?>((ref) => null);
final categoryProvider = StateProvider<Category?>((ref) => null);

void main() {
  runApp(
    const ProviderScope(child: MyApp())
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'クワガタ画像識別',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: _ImagePredict(),
    );
  }
}

class _ImagePredict extends ConsumerWidget {
  _ImagePredict({Key? key}) : super(key: key);
  final _classifier = ClassifierQuant();
  final picker = ImagePicker();
  File? _image;
  Category? category;

  void _predict(WidgetRef ref) async {
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    var pred = _classifier.predict(imageInput);
    ref.watch(categoryProvider.state).state = pred;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _image = ref.watch(imageProvider.state).state;
    category = ref.watch(categoryProvider.state).state;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 2 / 3,
              color: Colors.redAccent,
              child: _image != null
                  ? Image.file(_image!, fit: BoxFit.fill,)
                  : const SizedBox(),
            ),
            const SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                    category != null ? category!.label : ''
                ),
                Text(category != null ? category!.score.toStringAsFixed(3) :"")
              ],
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
                  var pred = _classifier.predict(imageInput);
                  ref.watch(categoryProvider.state).state = pred;
                },
                child: const Text('予測する'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _button('カメラ', ImageSource.camera, ref),
                _button('ギャラリー', ImageSource.gallery, ref)
              ],
            ),
            const SizedBox()
          ],
        ),
      ),
    );
  }
  Widget _button(String title, ImageSource source, WidgetRef ref) {
    return OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: const Size(100, 40)),
        onPressed: () async {
          final pickedFile = await picker.pickImage(source: source);
          ref.read(imageProvider.state).state = File(pickedFile!.path);
        },
        child: Text(title));
  }
}




