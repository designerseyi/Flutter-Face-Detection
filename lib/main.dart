import 'dart:io';
import 'dart:ui' as ui;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FacePage(),
    );
  }
}



class FacePage extends StatefulWidget {
  @override
  _FacePageState createState() => _FacePageState();
}

class _FacePageState extends State<FacePage> {

  File _imageFile;
  List<Face> _faces = <Face>[];

  ui.Image _convertedimg;
//   List<Rect> _convertedfaces = <Rect>[];


  void _getimageAndDetectFaces() async {

    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _imageFile = imageFile;

    });
    final image = FirebaseVisionImage.fromFile(imageFile);


    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector(
          FaceDetectorOptions(
            mode: FaceDetectorMode.accurate,
            enableLandmarks: true
      ),
    );

    final faces = await faceDetector.detectInImage(image);
    setState(() {
      _faces = faces;
    });

    final convertedimg = await _loadImage(_imageFile);
//
//    List<Rect> convertedfaces = convertFaces(faces);
//    setState(() {
//      _convertedfaces = convertedfaces;
//    });


    if (mounted) {
      setState(() {
        _imageFile = imageFile;
        _faces = faces;
        _convertedimg = convertedimg;
//        _convertedfaces = convertedfaces;
      });
    }


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Face Detector')
      ),

//      body: ImagesAndFaces(imageFile: _imageFile,faces: _faces,convertedimg:_convertedimg, convertedfaces: _convertedfaces,),
//    body: Column(
//      children: <Widget>[
//        Flexible(
//      flex: 2,
//      child: Container(
//          constraints: BoxConstraints.expand(),
//          child:_imageFile  == null
//              ? new Text('Select image using Floating Button...'):  Image.file(
//            _imageFile ,
//            fit: BoxFit.cover,)),
//    ),
//
//
//
//      FittedBox(
//            child: _convertedfaces == null
//                ? new Text('Select image using Floating Button...'):
//            SizedBox(
//
//              width: _convertedimg.width.toDouble(),
//              height: _convertedimg.height.toDouble(),
//              child: FacePaint( p :FacePainter(_convertedimg,_convertedfaces)),
//            ),
//          ),
////      ),
//
//
////      Flexible( flex: 1,
////          child:  _faces == null
////              ? new Text('Select image using Floating Button...'):ListView(
////            children:_faces.map<Widget>(
////                    (f) => FaceCoordinates(f) ).toList(),),
////      )
//      ]
//    ),

//    body: Column(
//      children: [ Flexible(
//      flex: 2,
//      child: Container(
//          constraints: BoxConstraints.expand(),
//          child:_imageFile  == null
//              ? new Text('Select image using Floating Button...'):  Image.file(
//            _imageFile ,
//            fit: BoxFit.cover,)),
//    ),
//
//
//      Flexible(
//        flex: 1,
//        child: _convertedfaces.isEmpty
//            ?  new Text('okk'): ListView(
//    children: _faces.map<Widget>((f)=> FaceCoordinates(f)).toList(),
//        ),
//      )
//
//      ]
//    ),



          body: Column(
      children: [  FittedBox(
                fit: BoxFit.contain,
            child: _faces.isEmpty
                ? new Text('Select image using Floating Button...'):
            SizedBox(

              width: _convertedimg.width.toDouble(),
              height: _convertedimg.height.toDouble(),
              child: FacePaint( p :FacePainter(_convertedimg,_faces)),
            ),
          ),

      Flexible(
        flex: 1,
        child: _faces.isEmpty
            ?  new Text('okk'): ListView(
    children: _faces.map<Widget>((f)=> Text("$_faces")).toList(),
        ),
      )

      ]
    ),

      floatingActionButton: FloatingActionButton(
        onPressed: _getimageAndDetectFaces,

        tooltip: 'Pick an Image',
        child: Icon(Icons.add_a_photo),),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _convertedimg;
    _imageFile;
    _faces;
    super.dispose();
  }

}




class ImagesAndFaces extends StatelessWidget {
  final File imageFile;
  final List<Face> faces;
  var convertedimg;
  List<Rect> convertedfaces;
  ImagesAndFaces({this.imageFile,this.faces,this.convertedimg,this.convertedfaces});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          flex: 2,
          child: Container(
              constraints: BoxConstraints.expand(),
              child: imageFile == null
                  ? new Text('Select image using Floating Button...'):  Image.file(
                imageFile, scale :1.0,
                fit: BoxFit.cover,)),
        ),

        FittedBox(
          child: SizedBox(
            child: ListView(
              children:faces.map<Widget>((f) => FaceCoordinates(f)).toList()
            ),

          ),
        )
      ],
    );
  }
}


class FaceCoordinates extends StatelessWidget {

  FaceCoordinates(this.face);
  final Face face;
  @override
  Widget build(BuildContext context) {

    final pos = face.boundingBox;
    return ListTile(
      title: Text('(${pos.top},${pos.left}), (${pos.bottom},${pos.right})'),
    );
  }
}



Future<ui.Image> _loadImage(File file) async {
  final data = await file.readAsBytes();
  return await decodeImageFromList(data);
}



//final facePaint = CustomPaint(
//  painter: FacePainter(convertedimg,convertedfaces),
//);

class FacePaint extends CustomPaint{

CustomPainter p;

FacePaint({this.p});
  @override
  // TODO: implement painter
  CustomPainter get painter => p;
}


List<Rect> convertFaces (List<Face>face){


  final List<Rect> rect = face.map((d){

       Rect.fromLTRB(d.boundingBox.left.toDouble(), d.boundingBox.top.toDouble(), d.boundingBox.right.toDouble(), d.boundingBox.bottom.toDouble());
  }).toList();

  

return rect;
}

class FacePainter extends CustomPainter{

  FacePainter(this.image,this.faces);
  final ui.Image image;
  final List<Face> faces;
//  List<Rect> rect_faces = <Rect>[];





  @override
  void paint(ui.Canvas canvas, ui.Size size) {

//    rect_faces = faces.map((d){
//
//    Rect.fromLTRB(d.boundingBox.left.toDouble(), d.boundingBox.top.toDouble(), d.boundingBox.right.toDouble(), d.boundingBox.bottom.toDouble());
//  }).toList();

          canvas.drawImage(image, Offset.zero, Paint());
//          canvas.drawRect(Rect.fromLTRB(223, 230, 500, 450), Paint()..strokeWidth = 4.0
//            ..color = Colors.red
//            ..style = PaintingStyle.stroke);

          for(var i =0; i< faces.length; i++){


            canvas.drawRect( Rect.fromLTRB(faces[i].boundingBox.left.toDouble(),  faces[i].boundingBox.top.toDouble(),
                faces[i].boundingBox.right.toDouble(),  faces[i].boundingBox.bottom.toDouble()), Paint()..strokeWidth = 4.0
              ..color = Colors.red
              ..style = PaintingStyle.stroke);
          }


  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    image != oldDelegate.image  || faces != oldDelegate.faces;
  }
}





