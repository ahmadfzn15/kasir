class Products {
  int id;
  String? foto;
  String namaProduk;
  int harga;
  int stok;
  bool selected = false;

  Products(
      {required this.id,
      required this.foto,
      required this.namaProduk,
      required this.harga,
      required this.stok,
      required this.selected});

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
        id: json['id'],
        foto: json['foto'],
        namaProduk: json['namaProduk'],
        harga: json['harga'],
        stok: json['stok'],
        selected: json['selected']);
  }
}
