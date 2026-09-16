// Reusable validation logic for forms across the application
mixin ValidationMixin {
    String password='';
  String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return "Name is required";
    }

    if (name.length < 3) {
      return "Name must be at least 3 characters";
    }
    else {
      return null;
    }
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return "Email is required";
    }
    // More comprehensive email regex
    if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? validateMobile(String? value) {
    final mobile = value?.trim() ?? '';
    if (mobile.isEmpty) {
      return "Mobile number is required";
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      return "Enter a valid 10-digit mobile number";
    }
    return null;
  }


  String? validatePassword(String? value) {
      password = value?.trim() ?? '';
    if (password.isEmpty) {
      return "Password is required";
    }
    if (password.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }



  String? validateConfirmPassword(String? value) {
    final confirmPassword = value?.trim() ?? '';
    if (confirmPassword.isEmpty) {
      return "Confirm Password is required";
    }
    if (confirmPassword.length < 6) {
      return "Confirm Password must be at least 6 characters";
    }
    if (confirmPassword!=password) {
      return "Password didn't match";
    }

    return null;
  }

  String? validateDob(String? value) {
    final dob = value?.trim() ?? '';
    if (dob.isEmpty) {
      return "Date of Birth is required";
    }
    return null;
  }

  String? validateGender(String? value) {
    final gender = value?.trim() ?? '';
    if (gender.isEmpty) {
      return "Gender is required";
    }
    return null;
  }


    String? validateEmailOrMobile(String? value) {
      if (value == null || value.isEmpty) {
        return "This field is required";
      }

      if (validateMobile(value) == null) {
        return null;
      }

      if (validateEmail(value) == null) {
        return null;
      }
      return "Please enter a valid Email or 10-digit Mobile number";
    }

}