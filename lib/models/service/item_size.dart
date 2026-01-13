class ItemSize {
  ItemSize({this.name, this.price});

  ItemSize.fromMap(Map<String, dynamic> map) {
    name = map['name'] ?? '';
    price = map['price'] ?? 0;
  }

  String? name;
  num? price;

  ItemSize clone() {
    return ItemSize(
      name: name,
      price: price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
    };
  }

  @override
  String toString() {
    return 'ItemSize{name: $name, price: $price}';
  }
}
