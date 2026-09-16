import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _dobController;
  late final TextEditingController _educationController;
  File? _profileImage;
  String _gender = '';
  String _city = '';

  final List<String> _cities = [
    'Lucknow',
    'Delhi',
    'Kanpur',
    'Mumbai',
    'Indore',
    'Bengaluru',
  ];
  final List<String> _educationOptions = [
    '10th',
    '12th',
    'Graduation',
    'Post Graduation',
    'Ph.D',
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: user.name ?? '');
    _emailController = TextEditingController(text: user.email ?? '');
    _mobileController = TextEditingController(text: user.mobile ?? '');
    _dobController = TextEditingController(text: user.dob ?? '');
    _educationController = TextEditingController(text: user.education ?? '');
    _gender = user.gender ?? '';
    _city = user.city ?? '';
    if (user.profilePath != null && user.profilePath!.isNotEmpty) {
      _profileImage = File(user.profilePath!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _educationController.dispose();
    super.dispose();
  }

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
    if (pickedFile != null && mounted) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final day = pickedDate.day.toString().padLeft(2, '0');
      final month = pickedDate.month.toString().padLeft(2, '0');
      setState(() => _dobController.text = '$day-$month-${pickedDate.year}');
    }
  }

  Future<void> _updateProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await Provider.of<UserProvider>(context, listen: false).updateProfile(
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      dob: _dobController.text.trim(),
      gender: _gender,
      education: _educationController.text.trim(),
      city: _city,
      profilePath: _profileImage?.path ?? '',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile Updated Successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.deepPurple[100],
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.deepPurple,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              _field(
                _nameController,
                'Full Name',
                Icons.person,
                required: true,
              ),
              const SizedBox(height: 14),
              _field(_emailController, 'Email', Icons.email, enabled: false),
              const SizedBox(height: 14),
              _field(
                _mobileController,
                'Mobile Number',
                Icons.phone,
                required: true,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: _selectDate,
                decoration: _decoration('Date of Birth', Icons.calendar_month),
                validator: (value) => value == null || value.isEmpty
                    ? 'Date of Birth is required'
                    : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _gender.isEmpty ? null : _gender,
                decoration: _decoration('Gender', Icons.person_outline),
                items: ['Male', 'Female', 'Other']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _gender = value ?? ''),
                validator: (value) =>
                    value == null ? 'Please select a gender' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _educationController,
                readOnly: true,
                onTap: _selectEducation,
                decoration: _decoration('Education', Icons.school),
                validator: (value) => value == null || value.isEmpty
                    ? 'Education is required'
                    : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _city.isEmpty ? null : _city,
                isExpanded: true,
                decoration: _decoration('City', Icons.location_city),
                items: _cities
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _city = value ?? ''),
                validator: (value) =>
                    value == null ? 'Please select a city' : null,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _updateProfile,
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectEducation() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: _educationOptions
              .map(
                (value) => ListTile(
                  title: Text(value),
                  onTap: () => Navigator.pop(context, value),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected != null) setState(() => _educationController.text = selected);
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: Colors.deepPurple),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool enabled = true,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: _decoration(label, icon).copyWith(
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[200],
      ),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? '$label is required'
                : null
          : null,
    );
  }
}
