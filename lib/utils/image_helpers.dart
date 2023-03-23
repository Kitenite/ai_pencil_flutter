import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io';

import 'package:ai_pencil/model/drawing/drawing_layer.dart';
import 'package:ai_pencil/model/image/types.dart';
import 'package:ai_pencil/utils/constants.dart';
import 'package:ai_pencil/widgets/drawing_canvas/sketch_painter.dart';
import 'package:ai_pencil/model/drawing_canvas/sketch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as IMG;

class ImageHelper {
  static Size getStableDiffusionImageSize(PngImageBytes image) {
    // Required for Stable Diffusion to work. Need to have max dimension of 512 and multiple of 64.

    IMG.Image? decoded = IMG.decodeImage(image);

    int oldWidth = decoded!.width;
    int oldHeight = decoded.height;
    int newWidth = oldWidth;
    int newHeight = oldHeight;
    double aspectRatio = oldWidth / oldHeight;

    // Adhere to max dimension
    if (oldWidth > oldHeight) {
      newWidth = StableDiffusionStandards.MAX_DIMENSION.toInt();
      newHeight = newWidth ~/ aspectRatio;
    } else {
      newHeight = StableDiffusionStandards.MAX_DIMENSION.toInt();
      newWidth = (newHeight * aspectRatio).toInt();
    }

    // Adhere to multiple
    newWidth = (newWidth / StableDiffusionStandards.MULTIPLE).ceil() *
        StableDiffusionStandards.MULTIPLE;
    newHeight = (newHeight / StableDiffusionStandards.MULTIPLE).ceil() *
        StableDiffusionStandards.MULTIPLE;

    Logger("ImageHelper::getStableDiffusionImageSize")
        .info("Old size: $oldWidth x $oldHeight");
    Logger("ImageHelper::getStableDiffusionImageSize")
        .info("New size: $newWidth x $newHeight");
    return Size(newWidth.toDouble(), newHeight.toDouble());
  }

  static PngImageBytes resizeImageToDimensions(PngImageBytes image, Size size) {
    PngImageBytes resizedData = image;
    IMG.Image? decoded = IMG.decodeImage(image);
    if (decoded == null) {
      Logger("ImageHelper::resizeImage").warning("Decoded image is null");
      return resizedData;
    }

    IMG.Image resized = IMG.copyResize(
      decoded,
      width: size.width.toInt(),
      height: size.height.toInt(),
    );

    resizedData = IMG.encodePng(resized) as PngImageBytes;
    return resizedData;
  }

  static Size? getDrawingSize(GlobalKey canvasGlobalKey) {
    Size? drawingSize = canvasGlobalKey.currentContext?.size;
    if (drawingSize == null) {
      Logger("ImageHelper::getDrawingSize").warning("Drawing size is null");
      return null;
    }
    return drawingSize;
  }

  static void getCanvasScreenshot(List<DrawingLayer> layers, Size size,
      Color backgroundColor, Function(PngImageBytes?) callback) {
    getPngBytesFromLayers(layers, size, backgroundColor)
        .then((imageBytes) => callback(imageBytes));
  }

  static Future<String> bytesToBase64String(PngImageBytes bytes) async {
    String base64Image = base64Encode(bytes);
    return base64Image;
  }

  static Future<String> imageToBase64String(ui.Image image) async {
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    PngImageBytes? pngBytes = byteData?.buffer.asUint8List();
    String base64Image = base64Encode(pngBytes!);
    return base64Image;
  }

  static Future<ui.Image> base64StringToImage(String base64String) async {
    Uint8List bytes = base64Decode(base64String);
    ui.Codec codec = await ui.instantiateImageCodec(bytes);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  static Uint8List base64StringToBytes(String base64String) {
    return base64Decode(base64String);
  }

  static void downloadDrawingImage(
    List<DrawingLayer> layers,
    Size? size,
    Color? backgroundColor,
    PngImageBytes? backgroundImage,
  ) async {
    PngImageBytes? pngBytes = await ImageHelper.getDrawingAsPngBytes(
      layers,
      size,
      backgroundColor,
      backgroundImage,
    );
    if (pngBytes != null) ImageHelper.saveFile(pngBytes, 'png');
  }

  static Future<PngImageBytes?> getDrawingAsPngBytes(
    List<DrawingLayer> layers,
    Size? size,
    Color? backgroundColor,
    PngImageBytes? backgroundImage,
  ) async {
    if (size == null) {
      Logger("ImageHelper::getDrawingAsPngBytes")
          .severe('Size is null, returning null');
      return null;
    }
    List<Sketch> allSketches = [];
    for (DrawingLayer layer in layers) {
      allSketches.addAll(layer.sketches);
    }
    var ret = await getPngBytesFromSketches(
        allSketches, size, backgroundColor, backgroundImage);
    return ret;
  }

  // static Future<PngImageBytes?> getCanvasAsBytes(
  //     GlobalKey canvasGlobalKey) async {
  //   RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
  //       ?.findRenderObject() as RenderRepaintBoundary;
  //   ui.Image image = await boundary.toImage();
  //   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   PngImageBytes? pngBytes = byteData?.buffer.asUint8List();
  //   return pngBytes;
  // }

  static Future<PngImageBytes?> getPngBytesFromSketches(List<Sketch> sketches,
      Size size, Color? backgroundColor, PngImageBytes? backgroundImage) async {
    ui.Image image = await _getImageFromSketches(
        sketches, size, backgroundColor, backgroundImage);
    var pngByteData = await image.toByteData(format: ui.ImageByteFormat.png);
    PngImageBytes? pngBytesList = pngByteData?.buffer.asUint8List();
    return pngBytesList;
  }

  static Future<ui.Image> _getImageFromSketches(List<Sketch> sketches,
      Size size, Color? backgroundColor, PngImageBytes? backgroundImage) async {
    // Create a new canvas with a PictureRecorder, paint it with all sketches,
    // and then return the image
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);

    if (backgroundColor != null) {
      canvas.drawColor(backgroundColor, BlendMode.src);
    }

    SketchPainter painter;
    if (backgroundImage != null) {
      painter = SketchPainter(
          sketches: sketches,
          backgroundImage: await decodeImageFromList(backgroundImage));
    } else {
      painter = SketchPainter(sketches: sketches);
    }

    painter.paint(canvas, Size(size.width, size.height));
    return recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
  }

  static Future<PngImageBytes?> getPngBytesFromLayers(
      List<DrawingLayer> layers, Size size, Color? backgroundColor) async {
    // Create a new canvas with a PictureRecorder, paint it with all sketches,
    // and then return the image
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);

    if (backgroundColor != null) {
      canvas.drawColor(backgroundColor, BlendMode.src);
    }

    SketchPainter painter;

    for (DrawingLayer layer in layers) {
      if (layer.backgroundImage != null) {
        painter = SketchPainter(
            sketches: layer.sketches,
            backgroundImage: await decodeImageFromList(layer.backgroundImage!));
      } else {
        painter = SketchPainter(sketches: layer.sketches);
      }

      painter.paint(canvas, Size(size.width, size.height));
    }

    ui.Image image = await recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());

    var pngByteData = await image.toByteData(format: ui.ImageByteFormat.png);
    PngImageBytes? pngBytesList = pngByteData?.buffer.asUint8List();
    return pngBytesList;
  }

  static Future<File> createTempImageFile(PngImageBytes imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    File imageFile = await File('${tempDir.path}/image.png').create();
    imageFile.writeAsBytesSync(imageBytes);
    return imageFile;
  }

  static void saveFile(Uint8List bytes, String extension) async {
    if (kIsWeb) {
      html.AnchorElement()
        ..href = '${Uri.dataFromBytes(bytes, mimeType: 'image/$extension')}'
        ..download =
            'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension'
        ..style.display = 'none'
        ..click();
    } else {
      File image = await createTempImageFile(bytes);
      GallerySaver.saveImage(image.path);
    }
  }

  static Future<Uint8List> getImageFromDevice(
    double width,
    double height,
    BuildContext context,
  ) async {
    final completer = Completer<Uint8List>();
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      final file = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (file != null) {
        final filePath = file.files.single.path;
        final bytes = filePath == null
            ? file.files.first.bytes
            : File(filePath).readAsBytesSync();
        if (bytes != null) {
          completer.complete(bytes);
        } else {
          completer.completeError('No image selected');
        }
      }
    } else {
      XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        CroppedFile? croppedImage =
            await cropImage(File(image.path), width, height, context);
        if (croppedImage == null) {
          return getImageFromDevice(width, height, context);
        } else {
          image = XFile(croppedImage.path);
        }
        final bytes = await image.readAsBytes();
        completer.complete(bytes);
      } else {
        completer.completeError('No image selected');
      }
    }

    return completer.future;
  }

  static Future<PngImageBytes?> cropImageFromBytes(
    PngImageBytes imageBytes,
    double width,
    double height,
    BuildContext context,
  ) async {
    // Create temp image file
    File imageFile = await createTempImageFile(imageBytes);
    imageFile.writeAsBytesSync(imageBytes);

    CroppedFile? croppedImage = await cropImage(
      imageFile,
      width,
      height,
      context,
    );

    if (croppedImage == null) {
      return imageBytes;
    }
    return await croppedImage.readAsBytes();
  }

  static Future<CroppedFile?> cropImage(
    File image,
    double width,
    double height,
    BuildContext context,
  ) async {
    return await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: width, ratioY: height),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop your photo',
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop your photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
        WebUiSettings(
          context: context,
          presentStyle: CropperPresentStyle.page,
          enableResize: true,
          enableZoom: true,
        )
      ],
    );
  }
}
