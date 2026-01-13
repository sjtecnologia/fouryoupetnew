import 'dart:io';

import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:fouryoupet/helpers/styles/text_styles.dart';
import 'package:fouryoupet/models/company/company.dart';

import 'image_source_sheet.dart';

class ImagesForm extends StatelessWidget {
  const ImagesForm(this.company);

  final Company company;

  @override
  Widget build(BuildContext context) {
    return FormField<List<dynamic>>(
      initialValue: List.from(company.images ?? []),
      validator: (images) {
        // if (images!.isEmpty) {
        //   return 'Insira ao menos uma imagem';
        // }
        return null;
      },
      onSaved: (images) {
        company.newImages = images;
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
              child: CarouselSlider(
                items: state.value!.map<Widget>((image) {
                  return Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: image is String
                            ? Image.network(
                                image,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  print('❌ Erro ao carregar imagem: $error');
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 80,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Text(
                                            'Imagem não encontrada',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Text(
                                            'Remova esta imagem e adicione uma nova',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Image.file(
                                image as File,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 80,
                                          color: Colors.red[300],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Erro ao carregar arquivo',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.remove),
                          color: Colors.red,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Confirmar'),
                                  content: Text(
                                    'Confirmar a exclusão da imagem',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancelar',
                                        style: context.textStyles.textBold
                                            .copyWith(color: Colors.red),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        state.value!.remove(image);
                                        state.didChange(state.value);
                                      },
                                      child: Text(
                                        'Confirmar',
                                        style: context.textStyles.textBold,
                                      ),
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      )
                    ],
                  );
                }).toList()
                  ..add(
                    Material(
                      color: Colors.grey[100],
                      child: IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        color: Theme.of(context).primaryColor,
                        iconSize: 50,
                        onPressed: () {
                          if (Platform.isAndroid) {
                            showModalBottomSheet(
                                context: context,
                                builder: (_) => ImageSourceSheet(
                                      onImageSelected: onImageSelected,
                                    ));
                          } else {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (_) => ImageSourceSheet(
                                      onImageSelected: onImageSelected,
                                    ));
                          }
                        },
                      ),
                    ),
                  ),
                options: CarouselOptions(
                  enableInfiniteScroll: false,
                  viewportFraction: 0.8,
                  enlargeCenterPage: false,
                  aspectRatio: 1.0,
                ),
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
  }
}
