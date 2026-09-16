// Data model representing the user details throughout the application
class UserDetails {

  String? _name;
  String? _email;
  String? _mobile;
  String? _password;
  String? _confirmPassword;
  String? _dob;
  String? _gender;
  String? _education;
  String? _city;
  String? _profilePath;

  UserDetails.con();


  UserDetails({
    String? name,
    String? email,
    String? mobile,
    String? password,
    String? confirmPassword,
    String? dob,
    String? gender,
    String? education,
    String? city,
    String? profilePath,
  }) {
    _name = name;
    _email = email;
    _mobile = mobile;
    _password = password;
    _confirmPassword = confirmPassword;
    _dob = dob;
    _gender = gender;
    _education = education;
    _city = city;
    _profilePath = profilePath;
  }

  String get profilePath => _profilePath ?? '';
  set profilePath(String value) {
    _profilePath = value;
  }


  String get city => _city ?? '';
  set city(String value) {
    _city = value;
  }

  String get education => _education ?? '';

  set education(String value) {
    _education = value;
  }

  String get gender => _gender ?? '';

  set gender(String value) {
    _gender = value;
  }

  String get dob => _dob ?? '';

  set dob(String value) {
    _dob = value;
  }

  String get confirmPassword => _confirmPassword ?? '';

  set confirmPassword(String value) {
    _confirmPassword = value;
  }

  String get password => _password ?? '';

  set password(String value) {
    _password = value;
  }

  String get mobile => _mobile ?? '';

  set mobile(String value) {
    _mobile = value;
  }

  String get email => _email ?? '';

  set email(String value) {
    _email = value;
  }

  String get name => _name ?? '';

  set name(String value) {
    _name = value;
  }

}