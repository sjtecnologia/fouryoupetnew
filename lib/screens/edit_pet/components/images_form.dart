import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fouryoupet/models/pet/pet.dart';
import 'package:fouryoupet/screens/edit_pet/components/image_source_sheet.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/common/app_network_image.dart';

class ImagesForm extends StatelessWidget {
  const ImagesForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Pet>(
      builder: (_, pet, __) {
        return FormField<List<dynamic>>(
          initialValue: List.from(pet.images ?? []),
          validator: (images) {
            if (images == null || images.isEmpty) {
              return 'Insira ao menos uma imagem';
            }
            return null;
          },
          onSaved: (images) {
            pet.newImages = images ?? [];
          },
          builder: (state) {
            void onImageSelected(File file) {
              state.value!.add(file);
              state.didChange(state.value);
              Navigator.of(context).pop();
            }

            return Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: Carousel(
                    images: state.value!,
                    onImageTap: (context) {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => ImageSourceSheet(
                          onImageSelected: onImageSelected,
                        ),
                      );
                    },
                  ),
                ),
                if (state.hasError)
                  Container(
                    margin: const EdgeInsets.only(top: 16, left: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  )
              ],
            );
          },
        );
      },
    );
  }
}

class Carousel extends StatelessWidget {
  const Carousel({
    Key? key,
    required this.images,
    required this.onImageTap,
  }) : super(key: key);

  final List<dynamic> images;
  final Function(BuildContext) onImageTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PageView(
          children: images.map<Widget>((image) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (image is String)
                  AppNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                  )
                else
                  Image.file(
                    image as File,
                    fit: BoxFit.cover,
                  ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () {
                        images.remove(image);
                        // Força a reconstrução do widget
                        (context as Element).markNeedsBuild();
                      },
                    ),
                  ),
                ),
              ],
            );
          }).toList()
            ..add(
              Material(
                color: Colors.grey[100],
                child: InkWell(
                  onTap: () => onImageTap(context),
                  child: const Icon(
                    Icons.add_a_photo,
                    color: Colors.grey,
                    size: 50,
                  ),
                ),
              ),
            ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length + 1,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
