import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
//import 'Complaints.dart';
import 'KarigarHome.dart';

//import 'Admindashboard.dart';

class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  Future<Map<String, dynamic>> authenticate(String phone, String password, String app, BuildContext context) async {
    final url = Uri.parse('$baseUrl/api/fsauth');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone': phone,
        'password': password,
        'app': app.toLowerCase(),
      }),
    );



    try {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Data: $data');

        final token = data['token']?.toString() ?? '';
        final role = data['role']?.toString() ?? '';
        final userDetails = data['user'];
        final String name = (userDetails is Map && userDetails['name'] != null)
            ? userDetails['name'].toString()
            : (data['name']?.toString() ?? phone);

        print('Token: $token');
        print('Role: $role');
        print('UserDetails: $userDetails');

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => KarigarHome(
                token: token,
                name: name,
              ),
            ),
          );
        }

        if (token.isNotEmpty) {
          _scheduleTokenRefresh(token);
        }
        return data is Map<String, dynamic> ? data : {'data': data};
      } else {
        String errorMsg = 'Failed to authenticate (${response.statusCode})';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData['message'] != null) {
            errorMsg = errorData['message'].toString();
          } else if (errorData is Map && errorData['error'] != null) {
            errorMsg = errorData['error'].toString();
          } else {
            errorMsg = response.body;
          }
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMsg = response.body;
          }
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }

  void _scheduleTokenRefresh(String token) {
    try {
      if (!JwtDecoder.isExpired(token)) {
        final expirationDate = JwtDecoder.getExpirationDate(token);
        final timeToExpire = expirationDate.difference(DateTime.now()).inSeconds;

        // Refresh the token 1 minute before it expires
        final refreshTime = timeToExpire - 60;

        if (refreshTime > 0) {
          Future.delayed(Duration(seconds: refreshTime), () async {
            try {
              await refreshToken(token);
            } catch (e) {
              print('Token refresh failed: $e');
            }
          });
        }
      }
    } catch (e) {
      print('Error scheduling token refresh: $e');
    }
  }

  Future<void> refreshToken(String oldToken) async {
    final url = Uri.parse('$baseUrl/api/refreshtoken');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refreshToken': oldToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newToken = data['token'];

      if (newToken != null && newToken.toString().isNotEmpty) {
        _scheduleTokenRefresh(newToken.toString());
      }
      print('Token refreshed: $newToken');
    } else {
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }
}