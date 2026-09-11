class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String jabatan;
  final String departemen;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.jabatan,
    this.departemen = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
        uid: (m['uid'] ?? '') as String,
        nama: (m['nama'] ?? '') as String,
        email: (m['email'] ?? '') as String,
        jabatan: (m['jabatan'] ?? '') as String,
        departemen: (m['departemen'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'nama': nama,
        'email': email,
        'jabatan': jabatan,
        'departemen': departemen,
      };
}