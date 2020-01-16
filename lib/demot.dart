import 'dart:io'; 
import 'dart:typed_data';
import 'dart:ui' as ui show Image, ImageByteFormat;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; 
import 'package:permission_handler/permission_handler.dart';



class MyAppS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey _screen = new GlobalKey();

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
    Image _image;

    print(_screen.currentContext.findRenderObject());
    RenderRepaintBoundary boundary = _screen.currentContext.findRenderObject();
    RenderBox renderBox =  _screen.currentContext.findRenderObject() ;
    double pixelRatio =  renderBox.size.height / renderBox.size.width;
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

  Offset _offset = Offset(0, 0);
  double _angle = 0;
  double _scale = 1;
  Offset _origin = Offset(0, 0);

  //true: scale mode
  //false: move mode
  bool _scaleMode = false;

  void _handleScale(ScaleUpdateDetails d) {
    setState(() {
      _angle = d.rotation;
      _origin = d.localFocalPoint;
      _scale = d.scale;
    });
  }

  void _dragUpdate(DragUpdateDetails d) {
    setState(() {
      _offset = _offset.translate(d.delta.dx, d.delta.dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            RaisedButton(
                child: Text("Move"),
                color: _scaleMode ? Colors.white : Colors.grey,
                disabledColor: Colors.redAccent,
                onPressed: _scaleMode
                    ? () {
                  setState(() {
                    _scaleMode = false;
                  });
                }
                    : null),
            RaisedButton(
                child: Text("Scale"),
                color: !_scaleMode ? Colors.white : Colors.grey,
                disabledColor: Colors.redAccent,
                onPressed: !_scaleMode
                    ? () {
                  setState(() {
                    _scaleMode = true;
                  });
                }
                    : null)
          ],
        ),
        centerTitle: true,
      ),
      body: RepaintBoundary(
        key: _screen,
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Image.network(
                'https://purepng.com/public/uploads/large/purepng.com-brad-pittbradpittwilliam-bradley-pittamerican-actorproducer-1701528020145jcrri.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: GestureDetector(
                onScaleUpdate: _scaleMode ? _handleScale : null,
                onHorizontalDragUpdate: !_scaleMode ? _dragUpdate : null,
                onVerticalDragUpdate: !_scaleMode ? _dragUpdate : null,
                child: Transform.rotate(
                  angle: _angle,
                  origin: _origin,
                  child: Transform.scale(
                    scale: _scale,
                    child: Transform.translate(
                      offset: _offset,
                      child: Image.network(
                        'https://i0.wp.com/sreditingzone.com/wp-content/uploads/2018/01/Rc-Editz-8.png?zoom=2.625&resize=410%2C213&ssl=1',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: Icon(Icons.save),
      ),
    );
  }
}