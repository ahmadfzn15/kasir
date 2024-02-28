class Products {
  int id;
  String? foto;
  String namaProduk;
  int harga;
  int? stok;

  Products({
    required this.id,
    required this.foto,
    required this.namaProduk,
    required this.harga,
    this.stok = 0,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['id'],
      foto: json['foto'],
      namaProduk: json['namaProduk'],
      harga: json['harga'],
      stok: json['stok'],
    );
  }
}
