import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Image, ImageByteFormat;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:image/image.dart' as img;

class ImagePage extends StatefulWidget {
  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  GlobalKey _screen = new GlobalKey();
  Image _image;
  Size _screenSize;

  void _save() async {
    PermissionStatus _status = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (_status != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> _status2 =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (_status2[PermissionGroup.storage] == PermissionStatus.granted) {
        _screenshot();
      }
    } else {
      _screenshot();
    }
  }

  Future<void> _screenshot() async {
     RenderRepaintBoundary boundary = _screen.currentContext.findRenderObject();

    double pixelRatio = _screenSize.height / _screenSize.width;
    ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    setState(() {
      _image = Image.memory(pngBytes.buffer.asUint8List());
    });

    Directory d = Directory('/storage/emulated/0');
    if (d.existsSync()) {
      Directory(d.path + '/HairApp').createSync();
      File imgFile = new File(d.path + '/HairApp/hair.png');
      print('saving to ${imgFile.path}');
      imgFile.createSync();
      imgFile.writeAsBytes(pngBytes);
    }
  }

  double _scale = 1;
  double _lastScale = 1;
  Offset _translate = Offset(0, 0);
  double _angle = 0;
   void _scaleEnd(ScaleEndDetails d) {
    // lets remember the last scale and calculate new scale with it
    _lastScale = _scale;
    _angle = _angle;
   }

  void _handleScale(ScaleUpdateDetails d) {
    setState(() {
      // you can control max and min scale here
      if (_lastScale * d.scale < 0.2 || _lastScale * d.scale > 3) return;
      _scale = _lastScale * d.scale;
      _translate = d.focalPoint;

      //TODO fix: this sets to zero when user touched with one finger
      _angle = d.rotation;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_postCallback);
    super.initState();
  }

  void _postCallback(duration) {
    RenderBox renderBox = _screen.currentContext.findRenderObject();
    _screenSize = renderBox.size;
    setState(() {
      _translate = Offset(MediaQuery.of(context).size.width / 6,
          MediaQuery.of(context).size.height / 6);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hair'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _screen,
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'assets/images/sel.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width / 3,
            child: Transform.rotate(
              angle: _angle,
              child: Transform.translate(
                offset: _translate.translate(
                    -MediaQuery.of(context).size.width / 6,
                    -MediaQuery.of(context).size.height / 6),
                child: Transform.scale(
                  scale: _scale,
                  child: Image.asset(
                    'assets/images/red_hair.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onScaleEnd: _scaleEnd,
            onScaleUpdate: _handleScale,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: Icon(Icons.save),
      ),
    );
  }
}
