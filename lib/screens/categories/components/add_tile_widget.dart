import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/screens/edit_product/components/image_source_sheet.dart';


class AddTileWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: (){
          if(Platform.isAndroid){
            showModalBottomSheet(
              context: context,
              builder: (context) =>
                  ImageSourceSheet(onImageSelected: null),
            );
          } else {
            showCupertinoModalPopup(
              context: context,
              builder: (context) =>
                  ImageSourceSheet(onImageSelected: null),
            );
          }
        },
        child: Container(
          color: Colors.white.withAlpha(30),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
