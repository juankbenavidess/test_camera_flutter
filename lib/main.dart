import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:untitled/preview_page.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyAppTest(),
    );
  }
}

class MyAppTest extends StatefulWidget {
  @override
  _MyAppTestState createState() => _MyAppTestState();
}

class _MyAppTestState extends State<MyAppTest> {
  late CameraController controller;
  late Uint8List? _imageUint;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future initCamera() async {
    controller = CameraController(_cameras[1], ResolutionPreset.high);
    try {
      await controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  Future takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }
    if (controller.value.isTakingPicture) {
      return null;
    }
    try {
      await controller.setFlashMode(FlashMode.off);
      _image = await controller.takePicture();
      _imageUint = await _image?.readAsBytes();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewPage(picture: _image!),
          ));
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Captura de foto'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () async {
                    await initCamera();
                    print('Foto tomada');
                    await takePicture();
                    setState(() {});
                  },
                  child: Text('Take a picture')),
              Text(
                _image != null ? _image!.path : 'No se ha tomado ninguna foto.',
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreviewPage(picture: _image!),
                        ));
                  },
                  child: Text('Preview'))
            ],
          ),
        ),
      ),
    );
  }
}
