class EventModel {
  final int id;
  final String judul;
  final String? deskripsi;
  final String tipe;
  final int harga;
  final String tanggalEvent;
  final String? posterUrl;
  final String? lokasi;
  final String status;

  EventModel({
    required this.id,
    required this.judul,
    this.deskripsi,
    required this.tipe,
    required this.harga,
    required this.tanggalEvent,
    this.posterUrl,
    this.lokasi,
    required this.status,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'],
      tipe: json['tipe'] ?? 'gratis',
      // Mengubah tipe data num ke int dengan aman dari database
      harga: json['harga'] != null ? (json['harga'] as num).toInt() : 0,
      tanggalEvent: json['tanggal_event'] ?? '',
      posterUrl: json['poster_url'],
      lokasi: json['lokasi'],
      status: json['status'] ?? 'nonaktif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'tipe': tipe,
      'harga': harga,
      'tanggal_event': tanggalEvent,
      'poster_url': posterUrl,
      'lokasi': lokasi,
      'status': status,
    };
  }

  bool get isGratis => tipe == 'gratis';
  bool get isAktif => status == 'aktif';
}
