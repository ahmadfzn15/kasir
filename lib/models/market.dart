class Market {
  int? id;
  String? namaToko;
  String? alamat;
  String? bidangUsaha;
  String? noTlp;

  Market({
    this.id,
    this.namaToko,
    this.alamat,
    this.bidangUsaha,
    this.noTlp,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'],
      namaToko: json['nama_toko'],
      alamat: json['alamat'],
      bidangUsaha: json['bidang_usaha'],
      noTlp: json['no_tlp'],
    );
  }
}
