/// id : "b75421f8-5e5e-49a0-b89a-57a661e2a5c7"
/// nama : "Habibul Umam"
/// nim : "202021420022"
/// prodi_id : "42"
/// prodi : "Teknik Informatika"
/// email : "oemampedia@gmail.com"
/// no_hp : "081231008968"
/// status : 1

class UserModel {
  UserModel({
    String? id,
    String? nama,
    String? nim,
    String? prodiId,
    String? prodi,
    String? email,
    String? noHp,
    num? status,
  }) {
    _id = id;
    _nama = nama;
    _nim = nim;
    _prodiId = prodiId;
    _prodi = prodi;
    _email = email;
    _noHp = noHp;
    _status = status;
  }

  UserModel.fromJson(dynamic json) {
    _id = json['id'];
    _nama = json['nama'];
    _nim = json['nim'];
    _prodiId = json['prodi_id'];
    _prodi = json['prodi'];
    _email = json['email'];
    _noHp = json['no_hp'];
    _status = json['status'];
  }

  String? _id;
  String? _nama;
  String? _nim;
  String? _prodiId;
  String? _prodi;
  String? _email;
  String? _noHp;
  num? _status;

  UserModel copyWith({
    String? id,
    String? nama,
    String? nim,
    String? prodiId,
    String? prodi,
    String? email,
    String? noHp,
    num? status,
  }) =>
      UserModel(
        id: id ?? _id,
        nama: nama ?? _nama,
        nim: nim ?? _nim,
        prodiId: prodiId ?? _prodiId,
        prodi: prodi ?? _prodi,
        email: email ?? _email,
        noHp: noHp ?? _noHp,
        status: status ?? _status,
      );

  String? get id => _id;

  String? get nama => _nama;

  String? get nim => _nim;

  String? get prodiId => _prodiId;

  String? get prodi => _prodi;

  String? get email => _email;

  String? get noHp => _noHp;

  num? get status => _status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['nama'] = _nama;
    map['nim'] = _nim;
    map['prodi_id'] = _prodiId;
    map['prodi'] = _prodi;
    map['email'] = _email;
    map['no_hp'] = _noHp;
    map['status'] = _status;
    return map;
  }
}
