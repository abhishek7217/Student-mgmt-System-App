import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/validation_mixin.dart';
import '../models/user.dart';
import 'login_page.dart';

// Initial signup screen for new users
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with ValidationMixin {
  List<String> city = [
    "Lucknow",
    "Delhi",
    "Kanpur",
    "Mumbai",
    "Indore",
    "Bengaluru",
  ];
  String? selectedCity;
  String? gender = "";
  final List<String> educationList = [
    "10th",
    "12th",
    "Graduation",
    "Post Graduation",
    "Ph.D",
  ];
  List<String> selectedEducation = [];
  File? _profileImage;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> saveData() async {
    UserDetails user = UserDetails();
    user.name = nameController.text;
    user.email = emailController.text;
    user.mobile = mobileController.text;
    user.password = passController.text;
    user.confirmPassword = confirmPassController.text;
    user.dob = dobController.text;
    user.gender = gender ?? '';
    user.education = selectedEducation.join(", ");
    user.city = selectedCity ?? '';
    user.profilePath = _profileImage?.path ?? '';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", user.name);
    await prefs.setString("email", user.email);
    await prefs.setString("mobile", user.mobile);
    await prefs.setString("password", user.password);
    await prefs.setString("dob", user.dob);
    await prefs.setString("gender", user.gender);
    await prefs.setString("education", user.education);
    await prefs.setString("city", user.city);
    await prefs.setString("profilePath", user.profilePath);

    if (mounted) {
      Provider.of<UserProvider>(context, listen: false).setUserData(
        user.name,
        user.email,
        user.profilePath,
        mobile: user.mobile,
        dob: user.dob,
        gender: user.gender,
        education: user.education,
        city: user.city,
      );
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text(
          "Register",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 50),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.deepPurple[100],
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.deepPurple,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUnfocus,
                child: Column(
                  children: [
                    //Name field
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.deepPurple,
                              ),
                              label: Text("Name"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.deepPurple,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: validateName,
                          ),
                        ),
                      ],
                    ),

                    //email field
                    SizedBox(height: 15),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Colors.deepPurple,
                                  ),
                                  label: Text("Email"),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurple,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: validateEmail,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    //mobile field
                    SizedBox(height: 15),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                maxLength: 10,
                                keyboardType: TextInputType.number,
                                controller: mobileController,
                                decoration: InputDecoration(
                                  counter: Offstage(),
                                  prefixIcon: Icon(
                                    Icons.phone,
                                    color: Colors.deepPurple,
                                  ),
                                  label: Text("Mobile Number"),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurple,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: validateMobile,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    //password field
                    SizedBox(height: 15),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                maxLength: 6,
                                obscureText: true,
                                keyboardType: TextInputType.number,
                                controller: passController,
                                decoration: InputDecoration(
                                  counter: Offstage(),
                                  prefixIcon: Icon(
                                    Icons.password,
                                    color: Colors.deepPurple,
                                  ),
                                  label: Text("Password"),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurple,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: validatePassword,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Confirm password field
                    SizedBox(height: 15),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                maxLength: 6,
                                obscureText: true,
                                keyboardType: TextInputType.number,
                                controller: confirmPassController,
                                decoration: InputDecoration(
                                  counter: Offstage(),
                                  prefixIcon: Icon(
                                    Icons.password,
                                    color: Colors.deepPurple,
                                  ),
                                  label: Text("Confirm Password"),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurple,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: validateConfirmPassword,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Date of Birth filed
                    SizedBox(height: 15),
                    TextFormField(
                      readOnly: true,
                      controller: dobController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                            width: 2,
                          ),
                        ),
                        suffixIcon: Icon(
                          Icons.calendar_month,
                          color: Colors.deepPurple,
                        ),
                        label: Text("Date of Birth"),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );

                        // 2. Agar user date select kar le
                        if (pickedDate != null) {
                          String formattedDay = pickedDate.day
                              .toString()
                              .padLeft(2, '0');
                          String formattedMonth = pickedDate.month
                              .toString()
                              .padLeft(2, '0');
                          String dob =
                              "$formattedDay-$formattedMonth-${pickedDate.year}";

                          setState(() {
                            dobController.text =
                                dob; // TextFormField me set kar diya
                          });
                        }
                      },
                      validator: validateDob,
                    ),
                    /*GestureDetector(
                    onTap: () async{
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                      );

                      if(pickedDate != null)
                      {
                        String dob = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                        setState(() {
                           dobController.text= dob;
                        });
                      }

                    },
                  ),*/

                    // Gender
                    SizedBox(height: 15),

                    /* Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Text("Gender : ",style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(width: 8,),
                        Radio(value: "Male",activeColor: Colors.deepPurple,groupValue: gender,visualDensity: VisualDensity.compact,
                          onChanged: (String? value){
                            setState(() {
                              gender=value;
                            });
                          },

                        ),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              gender="Male";
                            });
                          },
                          child: Text("Male"),
                        ),

                        SizedBox(width: 8,),
                        Radio(value: "Female",activeColor: Colors.deepPurple,groupValue: gender,visualDensity: VisualDensity.compact,
                          onChanged: (String? value){
                            setState(() {
                              gender=value;
                            });
                          },
                        ),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              gender="Female";
                            });
                          },
                          child: Text("Female"),
                        ),

                        SizedBox(width: 8,),
                        Radio(value: "Other",activeColor: Colors.deepPurple,groupValue: gender,visualDensity: VisualDensity.compact,
                          onChanged: (String? value){
                            setState(() {
                              gender=value;
                            });
                          },
                        ),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              gender="Other";
                            });
                          },
                          child: Text("Other"),
                        ),



                      ],
                    ),
                  ),*/
                    FormField<String>(
                      initialValue: gender,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a gender'; // 👈 Validation Message
                        }
                        return null;
                      },
                      builder: (FormFieldState<String> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  const Text(
                                    "Gender : ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // --- Male ---
                                  Radio<String>(
                                    value: "Male",
                                    activeColor: Colors.deepPurple,
                                    groupValue: state.value,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (String? value) {
                                      state.didChange(value);
                                      setState(() {
                                        gender = value;
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      state.didChange("Male");
                                      setState(() {
                                        gender = "Male";
                                      });
                                    },
                                    child: const Text("Male"),
                                  ),

                                  const SizedBox(width: 8),

                                  // --- Female ---
                                  Radio<String>(
                                    value: "Female",
                                    activeColor: Colors.deepPurple,
                                    groupValue: state.value,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (String? value) {
                                      state.didChange(value);
                                      setState(() {
                                        gender = value;
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      state.didChange("Female");
                                      setState(() {
                                        gender = "Female";
                                      });
                                    },
                                    child: const Text("Female"),
                                  ),

                                  const SizedBox(width: 8),

                                  // --- Other ---
                                  Radio<String>(
                                    value: "Other",
                                    activeColor: Colors.deepPurple,
                                    groupValue: state.value,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (String? value) {
                                      state.didChange(value);
                                      setState(() {
                                        gender = value;
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      state.didChange("Other");
                                      setState(() {
                                        gender = "Other";
                                      });
                                    },
                                    child: const Text("Other"),
                                  ),
                                ],
                              ),
                            ),

                            // 🛑 Error Message Display
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  top: 4,
                                ),
                                child: Text(
                                  state.errorText!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    // Education Field
                    const SizedBox(height: 15),

                    /* Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: const Text(
                            "Education : ",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Wrap(
                              runSpacing: 8,
                              spacing: 8,
                            children: educationList.map((qualification){
                              bool isSelected = selectedEducation.contains(qualification);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(value: isSelected,
                                      activeColor: Colors.deepPurple,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (bool? checked){
                                           setState(() {
                                             if(checked==true)
                                               {
                                                 selectedEducation.add(qualification);
                                               }
                                             else{
                                               selectedEducation.remove(qualification);
                                             }
                                           });
                                      }),

                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        if(isSelected){
                                          selectedEducation.remove(qualification);
                                        }
                                        else{
                                          selectedEducation.add(qualification);
                                        }
                                      });
                                    },
                                    child:Text(qualification),
                                  ),
                                ],
                              );
                            }).toList(),
                            ),
                        ),
                      ],
                    ),
                  ),*/
                    FormField<List<String>>(
                      initialValue: selectedEducation,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select at least one qualification';
                        }
                        return null;
                      },
                      builder: (FormFieldState<List<String>> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text(
                                      "Education : ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Wrap(
                                      runSpacing: 8,
                                      spacing: 8,
                                      children: educationList.map((
                                        qualification,
                                      ) {
                                        bool isSelected = selectedEducation
                                            .contains(qualification);
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: isSelected,
                                              activeColor: Colors.deepPurple,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              onChanged: (bool? checked) {
                                                setState(() {
                                                  if (checked == true) {
                                                    selectedEducation.add(
                                                      qualification,
                                                    );
                                                  } else {
                                                    selectedEducation.remove(
                                                      qualification,
                                                    );
                                                  }
                                                  state.didChange(
                                                    selectedEducation,
                                                  );
                                                });
                                              },
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (isSelected) {
                                                    selectedEducation.remove(
                                                      qualification,
                                                    );
                                                  } else {
                                                    selectedEducation.add(
                                                      qualification,
                                                    );
                                                  }
                                                  state.didChange(
                                                    selectedEducation,
                                                  );
                                                });
                                              },
                                              child: Text(qualification),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 🛑 Error Message Display
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  top: 4,
                                ),
                                child: Text(
                                  state.errorText!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    //City field
                    /*SizedBox(height: 15,),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCity,
                    hint: const Text("Select City"),
                    isExpanded: true,
                    menuMaxHeight: 250,
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.deepPurple),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.location_city,color: Colors.deepPurple),
                      label: Text("City"),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.deepPurple, width: 2
                    ),
                  ),
                    ),

                    items: city.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(), onChanged: (String? value) {
                      setState(() {
                        selectedCity = value;
                      });
                  },
                  ),*/
                    SizedBox(height: 15),

                    /* DropdownMenu<String>(
                    // Field ki width (screen padding minus hoke)
                    width: MediaQuery.of(context).size.width - 20,
                    menuHeight: 250, // Popup menu ki height limit
                    hintText: "Select City",
                    leadingIcon: const Icon(Icons.location_city, color: Colors.deepPurple),

                    // Input decoration style
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    ),

                    // Popup Menu ki floating card styling
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      elevation: WidgetStateProperty.all(8), // Subtle shadow
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    dropdownMenuEntries: city.map((String city) {
                      return DropdownMenuEntry<String>(
                        value: city,
                        label: city,
                      );
                    }).toList(),

                    onSelected: (String? value) {
                      setState(() {
                        selectedCity = value;
                      });
                    },
                  ),*/
                    FormField<String>(
                      initialValue: selectedCity,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select a city'; // 👈 Validation Message
                        }
                        return null;
                      },
                      builder: (FormFieldState<String> state) {
                        return DropdownMenu<String>(
                          // Field ki width (screen padding minus hoke)
                          width: MediaQuery.of(context).size.width - 20,
                          menuHeight: 250, // Popup menu ki height limit
                          hintText: "Select City",
                          leadingIcon: const Icon(
                            Icons.location_city,
                            color: Colors.deepPurple,
                          ),
                          errorText: state.errorText,

                          inputDecorationTheme: InputDecorationTheme(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 15,
                            ),
                          ),

                          // Popup Menu ki floating card styling
                          menuStyle: MenuStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                            elevation: WidgetStateProperty.all(
                              8,
                            ), // Subtle shadow
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          dropdownMenuEntries: city.map((String city) {
                            return DropdownMenuEntry<String>(
                              value: city,
                              label: city,
                            );
                          }).toList(),

                          onSelected: (String? value) {
                            state.didChange(value);
                            setState(() {
                              selectedCity = value;
                            });
                          },
                        );
                      },
                    ),

                    SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),

                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          try {
                            await saveData();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                                content: const Text(
                                  "Account Created Successfully!",
                                ),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          } catch (e) {
                            // Handling any unexpected errors during save
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Registration Failed. Please try again.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          // Informing user to fix validation errors
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields correctly"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      child: Text("Submit"),
                    ),

                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            /*ScaffoldMessenger.of(context).showSnackBar(SnackBar
                            (
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.black87,
                            duration: Duration(seconds: 3), content: ,
                            ),
                          );*/

                            /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Saved Successfully!"),
                          behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(10),
                            ),
                            backgroundColor: Colors.black87,
                            duration: Duration(seconds: 2),
                          ),

                          );*/

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Already have an account? Login",
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
