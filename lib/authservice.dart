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



    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Data: $data');

      final token = data['token'];
      final role = data['role'];
      final userDetails = data['user'];
      print('Token: $token');
      print('Role: $role');
      print('UserDetails: $userDetails');

      String karigarName = '';
      if (userDetails is Map) {
        karigarName = (userDetails['name'] ??
                       userDetails['Name'] ??
                       userDetails['technicianName'] ??
                       userDetails['Technician'] ??
                       userDetails['userName'] ??
                       userDetails['username'] ??
                       userDetails['allotted to'] ??
                       userDetails['Allotted To'] ??
                       userDetails['employee'] ??
                       userDetails['Employee'] ??
                       '').toString().trim();
      } else if (userDetails is String) {
        karigarName = userDetails.trim();
      }

      if (karigarName.isEmpty && data is Map) {
        karigarName = (data['name'] ??
                       data['Name'] ??
                       data['technicianName'] ??
                       data['Technician'] ??
                       data['username'] ??
                       data['userName'] ??
                       '').toString().trim();
      }

      // If name is still empty, check the JWT token payload
      if (karigarName.isEmpty && token != null && token is String) {
        try {
          final decoded = JwtDecoder.decode(token);
          print('Decoded Token: $decoded');
          karigarName = (decoded['name'] ??
                         decoded['Name'] ??
                         decoded['technicianName'] ??
                         decoded['Technician'] ??
                         decoded['username'] ??
                         decoded['userName'] ??
                         decoded['allotted to'] ??
                         decoded['sub'] ??
                         '').toString().trim();
        } catch (e) {
          print('JWT decode error: $e');
        }
      }

      if (karigarName.isEmpty && phone.trim().isNotEmpty) {
        karigarName = phone.trim();
      }

      print('Resolved Karigar Name: $karigarName');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KarigarHome(
            token: token ?? '',
            name: karigarName,
          ),
        ),
      );

      if (token != null && token is String) {
        _scheduleTokenRefresh(token);
      }
      return data;
    } else {
      throw Exception('Failed to authenticate: ${response.body}');
    }
  }

  void _scheduleTokenRefresh(String token) {
    final expirationDate = JwtDecoder.getExpirationDate(token);
    final timeToExpire = expirationDate.difference(DateTime.now()).inSeconds;

    // Refresh the token 1 minute before it expires
    final refreshTime = timeToExpire - 60;

    if (refreshTime > 0) {
      Future.delayed(Duration(seconds: refreshTime), () async {
        await refreshToken(token);
      });
    }
  }

  Future<void> refreshToken(String oldToken) async {
    final url = Uri.parse('${baseUrl}/api/refreshtoken');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refreshToken': oldToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newToken = data['token'];

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => MyApp(),
      //   ),
      // );


      _scheduleTokenRefresh(newToken);
      // Store the new token as needed
      print('Token refreshed: $newToken');
    } else {
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }
}