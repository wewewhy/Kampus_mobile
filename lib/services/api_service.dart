import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dummy_data_service.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await DummyDataService.clearDummySession();
  }

  static Future<bool> isFirstOpen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_open') ?? false;
  }

  static Future<void> setFirstOpen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_open', true);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final dummyUser = DummyDataService.findUser(email, password);

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: jsonEncode(
                {'email': email.trim(), 'password': password.trim()}),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        await _saveUser(data['user']);
        return {'success': true, 'data': data};
      }
    } catch (_) {}

    if (dummyUser != null) {
      await saveToken(DummyDataService.dummyToken);
      await _saveUser(dummyUser);
      await DummyDataService.saveDummySession(dummyUser);
      return {
        'success': true,
        'data': {'token': DummyDataService.dummyToken, 'user': dummyUser}
      };
    }

    return {
      'success': false,
      'message':
          'Login gagal. Gunakan akun dummy admin@kampus.test, dosen.ti@kampus.test, atau andi@kampus.test. Password: password'
    };
  }

  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) return jsonDecode(userStr);
    return DummyDataService.currentUser();
  }

  static Future<Map<String, dynamic>?> updateProfile(
      Map<String, dynamic> data) async {
    final updated = await DummyDataService.updateCurrentUserProfile(data);
    if (updated != null) {
      await _saveUser(updated);
    }
    return updated;
  }

  static Future<List<dynamic>> getMahasiswaUsers() async {
    return DummyDataService.getMahasiswaUsers();
  }

  static Future<Map<String, dynamic>?> updateUserProfileById(
      int userId, Map<String, dynamic> data) async {
    final updated = await DummyDataService.updateUserProfileById(userId, data);
    final current = await getUser();
    if (updated != null && current?['id'] == userId) {
      await _saveUser(updated);
    }
    return updated;
  }

  static Future<T> _tryApi<T>(
      Future<T> Function(String? token) request, T fallback) async {
    try {
      return await request(await getToken())
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      return fallback;
    }
  }

  static Future<List<dynamic>> getBerita() async {
    return _tryApi((token) async {
      final response = await http.get(
        Uri.parse('$baseUrl/beritas'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200)
        return jsonDecode(response.body)['data'] ?? [];
      return DummyDataService.beritas;
    }, DummyDataService.beritas);
  }

  static Future<bool> createBerita(Map<String, dynamic> data) async {
    final ok = await _tryApi((token) async {
      final response = await http.post(
        Uri.parse('$baseUrl/beritas'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    }, false);
    if (!ok) {
      DummyDataService.beritas.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        ...data,
        'tanggal':
            data['tanggal'] ?? DateTime.now().toIso8601String().split('T')[0],
      });
    }
    return true;
  }

  static Future<bool> updateBerita(int id, Map<String, dynamic> data) async {
    final ok = await _tryApi((token) async {
      final response = await http.put(
        Uri.parse('$baseUrl/beritas/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    }, false);
    if (!ok) {
      final index = DummyDataService.beritas.indexWhere((b) => b['id'] == id);
      if (index >= 0)
        DummyDataService.beritas[index] = {
          ...DummyDataService.beritas[index],
          ...data
        };
    }
    return true;
  }

  static Future<bool> deleteBerita(int id) async {
    final ok = await _tryApi((token) async {
      final response = await http.delete(
        Uri.parse('$baseUrl/beritas/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      return response.statusCode == 200;
    }, false);
    if (!ok) DummyDataService.beritas.removeWhere((b) => b['id'] == id);
    return true;
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    return _tryApi((token) async {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {'events': DummyDataService.events};
    }, {'events': DummyDataService.events});
  }

  static Future<List<dynamic>> getDosenList() async {
    return _tryApi((token) async {
      final response = await http.get(
        Uri.parse('$baseUrl/pengajuans/dosen-list'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return DummyDataService.getDosenList();
    }, DummyDataService.getDosenList());
  }

  static Future<List<dynamic>> getJadwal() async {
    final fallback = DummyDataService.getJadwalForUser(await getUser());
    return _tryApi((token) async {
      final response = await http.get(Uri.parse('$baseUrl/jadwals'),
          headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      return fallback;
    }, fallback);
  }

  static Future<Map<String, dynamic>> createJadwal(
      Map<String, dynamic> data) async {
    final result = await _tryApi((token) async {
      final response = await http.post(
        Uri.parse('$baseUrl/jadwals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(data),
      );
      return {'status': response.statusCode, 'body': jsonDecode(response.body)};
    }, <String, dynamic>{'status': 0, 'body': data});

    if (result['status'] != 201) {
      DummyDataService.jadwals.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'dosen_id': (await getUser())?['dosen']?['id'] ?? 1,
        ...data,
      });
      return {'status': 201, 'body': data};
    }
    return result;
  }

  static Future<List<dynamic>> getPengajuan() async {
    final fallback = DummyDataService.getPengajuanForUser(await getUser());
    return _tryApi((token) async {
      final response = await http.get(Uri.parse('$baseUrl/pengajuans'),
          headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      return fallback;
    }, fallback);
  }

  static Future<Map<String, dynamic>> createPengajuan(
      Map<String, dynamic> data) async {
    final result = await _tryApi((token) async {
      final response = await http.post(
        Uri.parse('$baseUrl/pengajuans'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(data),
      );
      return {'status': response.statusCode, 'body': jsonDecode(response.body)};
    }, <String, dynamic>{'status': 0, 'body': data});

    if (result['status'] != 201) {
      await DummyDataService.addPengajuan(data, await getUser());
      return {'status': 201, 'body': data};
    }
    return result;
  }

  static Future<List<dynamic>> getPesertaJadwal(int jadwalId) async {
    final fallback = DummyDataService.getPesertaJadwal(jadwalId);
    return _tryApi((token) async {
      final response = await http.get(
        Uri.parse('$baseUrl/jadwals/$jadwalId/mahasiswas'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return fallback;
    }, fallback);
  }

  static Future<Map<String, dynamic>> createAbsensi(
      Map<String, dynamic> data) async {
    final result = await _tryApi((token) async {
      final response = await http.post(
        Uri.parse('$baseUrl/absensis'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(data),
      );
      return {'status': response.statusCode, 'body': jsonDecode(response.body)};
    }, <String, dynamic>{'status': 0, 'body': data});

    if (result['status'] != 201) {
      await DummyDataService.addAbsensi(data);
      return {'status': 201, 'body': data};
    }
    return result;
  }

  static Future<List<dynamic>> getNilai() async {
    final fallback = DummyDataService.getNilaiForUser(await getUser());
    return _tryApi((token) async {
      final response = await http.get(Uri.parse('$baseUrl/nilais'),
          headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      return fallback;
    }, fallback);
  }

  static Future<Map<String, dynamic>> updateNilai(
      int id, Map<String, dynamic> data) async {
    final result = await _tryApi((token) async {
      final response = await http.put(
        Uri.parse('$baseUrl/nilais/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(data),
      );
      return {'status': response.statusCode, 'body': jsonDecode(response.body)};
    }, <String, dynamic>{'status': 0, 'body': data});

    if (result['status'] != 200) {
      await DummyDataService.updateNilai(
          id, int.tryParse('${data['nilai_akhir']}') ?? 0);
      return {'status': 200, 'body': data};
    }
    return result;
  }

  static Future<Map<String, dynamic>> getGrafikNilai(int mahasiswaId) async {
    return _tryApi((token) async {
      final response = await http.get(
        Uri.parse('$baseUrl/nilais/grafik/$mahasiswaId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return DummyDataService.getGrafikNilai(mahasiswaId);
    }, DummyDataService.getGrafikNilai(mahasiswaId));
  }

  static Future<List<dynamic>> getEvents() async {
    return _tryApi((token) async {
      final response = await http.get(Uri.parse('$baseUrl/events'),
          headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) return body;
        return body['data'] ?? [];
      }
      return DummyDataService.events;
    }, DummyDataService.events);
  }

  static Future<Map<String, dynamic>> createEvent(
      Map<String, dynamic> data) async {
    final result = await _tryApi((token) async {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(data),
      );
      return {'status': response.statusCode, 'body': jsonDecode(response.body)};
    }, <String, dynamic>{'status': 0, 'body': data});

    if (result['status'] != 201) {
      DummyDataService.events.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'status': 'aktif',
        ...data,
      });
      return {'status': 201, 'body': data};
    }
    return result;
  }

  static Future<Map<String, dynamic>> registerEvent(
      Map<String, dynamic> event) async {
    return DummyDataService.registerEvent(event, await getUser());
  }

  static Future<List<dynamic>> getEventPesertas(int eventId) async {
    return DummyDataService.getEventPesertas(eventId);
  }

  static Future<bool> isRegisteredToEvent(int eventId) async {
    final user = await getUser();
    return DummyDataService.isRegisteredToEvent(
      eventId,
      user?['mahasiswa']?['id'],
    );
  }

  static Future<List<dynamic>> getPollings() async {
    return _tryApi((token) async {
      final response = await http.get(
        Uri.parse('$baseUrl/pollings'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200)
        return jsonDecode(response.body)['data'] ?? [];
      return DummyDataService.pollings;
    }, DummyDataService.pollings);
  }

  static Future<bool> createPolling(Map<String, dynamic> data) async {
    final ok = await _tryApi((token) async {
      final response = await http.post(
        Uri.parse('$baseUrl/pollings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    }, false);

    if (!ok) DummyDataService.addPolling(data);
    return true;
  }

  static Future<bool> votePolling(int pollingId, int optionIndex,
      {int? optionId}) async {
    final user = await getUser();
    try {
      if (optionId == null) {
        return DummyDataService.votePolling(
            pollingId, optionIndex, user?['id']);
      }
      final token = await getToken();
      final response = await http
          .post(
            Uri.parse('$baseUrl/pollings/$pollingId/vote'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: jsonEncode({'option_id': optionId}),
          )
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 201;
    } catch (_) {
      return DummyDataService.votePolling(pollingId, optionIndex, user?['id']);
    }
  }

  static Future<List<dynamic>> getTagihan() async {
    final fallback = DummyDataService.getTagihanForUser(await getUser());
    return _tryApi((token) async {
      final response = await http.get(Uri.parse('$baseUrl/tagihans'),
          headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200)
        return jsonDecode(response.body)['data'] ?? [];
      return fallback;
    }, fallback);
  }

  static Future<bool> payTagihan(int id, String metodePembayaran) async {
    final ok = await _tryApi((token) async {
      final response = await http.post(
        Uri.parse('$baseUrl/tagihans/$id/bayar'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'metode_pembayaran': metodePembayaran}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    }, false);

    if (!ok) return DummyDataService.payTagihan(id, metodePembayaran);
    return true;
  }

  static Future<void> logout() async {
    final token = await getToken();
    try {
      await http.post(Uri.parse('$baseUrl/logout'), headers: {
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 2));
    } catch (_) {}
    await clearToken();
  }
}
