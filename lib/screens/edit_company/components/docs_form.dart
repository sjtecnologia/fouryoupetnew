import 'dart:io';

import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:fouryoupet/helpers/styles/text_styles.dart';
import 'package:fouryoupet/models/company/company.dart';

import 'image_source_sheet.dart';

class DocsForm extends StatelessWidget {
  const DocsForm(this.company);

  final Company company;

  @override
  Widget build(BuildContext context) {
    return FormField<List<dynamic>>(
      initialValue: List.from(company.documents!),
      validator: (documents) {
        // if (images!.isEmpty) {
        //   return 'Insira ao menos uma imagem';
        // }
        return null;
      },
      onSaved: (documents) {
        company.newDocuments = documents;
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
                items: state.value!.map<Widget>((documents) {
                  return Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      if (documents is String)
                        Image.network(
                          documents,
                          fit: BoxFit.contain,
                        )
                      else
                        Image.file(
                          documents as File,
                          fit: BoxFit.contain,
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
                                        state.value!.remove(documents);
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
                options: CarouselOptions(),
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
