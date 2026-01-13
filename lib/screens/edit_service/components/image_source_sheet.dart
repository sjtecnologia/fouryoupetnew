import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {
  ImageSourceSheet({this.onImageSelected});

  final Function(File)? onImageSelected;

  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    Future<void> editImage(String path) async {
      final CroppedFile? croppedFile = (await ImageCropper().cropImage(
        sourcePath: path,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Editar Imagem',
              toolbarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: Colors.white),
          IOSUiSettings(
            title: 'Editar Imagem',
            cancelButtonTitle: 'Cancelar',
            doneButtonTitle: 'Concluir',
          ),
        ],
      ));
      if (croppedFile != null) {
        onImageSelected!(File(croppedFile.path));
      }
    }

    if (Platform.isAndroid) {
      return BottomSheet(
        onClosing: () {},
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                final file =
                    await (picker.pickImage(source: ImageSource.camera));
                editImage(file!.path);
              },
              child: const Text('Câmera'),
            ),
            // ignore: deprecated_member_use
            TextButton(
              onPressed: () async {
                final file =
                    await (picker.pickImage(source: ImageSource.gallery));
                editImage(file!.path);
              },
              child: const Text('Galeria'),
            ),
          ],
        ),
      );
    } else {
      return CupertinoActionSheet(
        title: const Text('Selecionar foto para o item'),
        message: const Text('Escolha a origem da foto'),
        cancelButton: CupertinoActionSheetAction(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancelar'),
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () async {
              final file = await (picker.pickImage(source: ImageSource.camera));
              if (file != null) editImage(file.path);
            },
            child: const Text('Câmera'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              final file =
                  await (picker.pickImage(source: ImageSource.gallery));
              if (file != null) editImage(file.path);
            },
            child: const Text('Galeria'),
          )
        ],
      );
    }
  }
}
