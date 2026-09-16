import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Service to manage user profile data across the entire application using Provider
class UserProvider with ChangeNotifier {
  String? _name;
  String? _email;
  String? _mobile;
  String? _dob;
  String? _gender;
  String? _education;
  String? _city;
  String? _profilePath;

  String? get name => _name;
  String? get email => _email;
  String? get mobile => _mobile;
  String? get dob => _dob;
  String? get gender => _gender;
  String? get education => _education;
  String? get city => _city;
  String? get profilePath => _profilePath;

  // Initializing and loading user data from local storage (SharedPreferences)
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = prefs.getString("name");
    _email = prefs.getString("email");
    _mobile = prefs.getString("mobile");
    _dob = prefs.getString("dob");
    _gender = prefs.getString("gender");
    _education = prefs.getString("education");
    _city = prefs.getString("city");
    _profilePath = prefs.getString("profilePath");
    notifyListeners();
  }

  // Setting user data in memory and updating UI across the app
  void setUserData(
    String name,
    String email,
    String profilePath, {
    String? mobile,
    String? dob,
    String? gender,
    String? education,
    String? city,
  }) {
    _name = name;
    _email = email;
    _mobile = mobile ?? _mobile;
    _dob = dob ?? _dob;
    _gender = gender ?? _gender;
    _education = education ?? _education;
    _city = city ?? _city;
    _profilePath = profilePath;
    notifyListeners();
  }

  // Persisting profile updates to local storage and notifying all dependent widgets
  Future<void> updateProfile({
    required String name,
    required String mobile,
    required String dob,
    required String gender,
    required String education,
    required String city,
    required String profilePath,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", name);
    await prefs.setString("mobile", mobile);
    await prefs.setString("dob", dob);
    await prefs.setString("gender", gender);
    await prefs.setString("education", education);
    await prefs.setString("city", city);
    await prefs.setString("profilePath", profilePath);
    _name = name;
    _mobile = mobile;
    _dob = dob;
    _gender = gender;
    _education = education;
    _city = city;
    _profilePath = profilePath;
    notifyListeners();
  }

  // Clearing user session and resetting state
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);
    _name = null;
    _email = null;
    _mobile = null;
    _dob = null;
    _gender = null;
    _education = null;
    _city = null;
    _profilePath = null;
    notifyListeners();
  }
}
