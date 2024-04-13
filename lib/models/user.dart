class User {
  String? foto;
  int? id;
  String? nama;
  String? role;
  String? email;
  String? noTlp;

  User({
    this.foto,
    this.id,
    this.nama,
    this.role,
    this.email,
    this.noTlp,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      foto: json['foto'],
      nama: json['nama'],
      role: json['role'],
      email: json['email'],
      noTlp: json['noTlp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foto': foto,
      'nama': nama,
      'role': role,
      'email': email,
      'noTlp': noTlp,
    };
  }
}
