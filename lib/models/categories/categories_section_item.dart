class CategoriesSectionItem{

  CategoriesSectionItem({this.image});

  CategoriesSectionItem.fromMap(Map<String, dynamic> map){
    image = map['image'] as String?;
    pos = map['pos'] as String?;

  }

  dynamic image;
  String? pos;



  Map<String, dynamic> toMap(){
    return {
      'image': image,
      'pos': pos,
    };
  }

  @override
  String toString() {
    return 'CategoriesSectionItem{image: $image, pos: $pos}';
  }
}