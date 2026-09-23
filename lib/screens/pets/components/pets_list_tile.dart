import 'package:flutter/material.dart';

import '../../../models/pet/pet.dart';
import 'package:fouryoupet/common/app_network_image.dart';

class PetListTile extends StatelessWidget {
  const PetListTile(this.pet, this.userapp);

  final Pet pet;
  final String? userapp;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    if (pet.user_id == null) {
      return GestureDetector(
        onTap: () async {
          await Navigator.of(context).pushNamed('/edit_pet', arguments: pet);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: IconButton(
                    icon: Icon(
                      Icons.add_card,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () async {
          await Navigator.of(context).pushNamed('/edit_pet', arguments: pet);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: AppNetworkImage(imageUrl: pet.images!.first),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      pet.name!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ))
              ],
            ),
          ),
        ),
      );
    }
  }
}
