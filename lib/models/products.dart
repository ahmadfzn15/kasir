class Products {
  int id;
  String? foto;
  String namaProduk;
  String? deskripsi;
  // ignore: non_constant_identifier_names
  int id_kategori;
  int harga;
  int? stok;
  bool selected;

  Products(
      {required this.id,
      required this.foto,
      required this.namaProduk,
      required this.harga,
      this.deskripsi = "",
      // ignore: non_constant_identifier_names
      required this.id_kategori,
      this.stok = 0,
      required this.selected});

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['id'],
      foto: json['foto'],
      namaProduk: json['namaProduk'],
      harga: json['harga'],
      deskripsi: json['deskripsi'],
      id_kategori: json['id_kategori'],
      stok: json['stok'],
      selected: json['selected'],
    );
  }
}
