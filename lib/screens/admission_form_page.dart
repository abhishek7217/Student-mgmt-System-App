import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_helper.dart';

// Screen for handling new admissions and updating existing student records
class AdmissionFormPage extends StatefulWidget {
  final Map<String, dynamic>? student;
  const AdmissionFormPage({super.key, this.student});

  @override
  State<AdmissionFormPage> createState() => _AdmissionFormPageState();
}

class _AdmissionFormPageState extends State<AdmissionFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for handling text input
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final submittedFeesController = TextEditingController();

  File? _receiptImage;
  String? _selectedCourse;
  int _totalFees = 0;
  int _remainingFees = 0;

  // Pre-defined course list with their respective fee structures
  final Map<String, int> _courseFees = {
    'Computer Science': 50000,
    'Data Science': 60000,
    'Software Engineering': 55000,
    'Cyber Security': 65000,
    'Cloud Computing': 70000,
  };

  @override
  void initState() {
    super.initState();
    // Pre-populating the form if we are in 'Edit' mode
    if (widget.student != null) {
      nameController.text = widget.student!['name'];
      emailController.text = widget.student!['email'];
      mobileController.text = widget.student!['mobile'];
      _selectedCourse = widget.student!['course'];
      _totalFees = _courseFees[_selectedCourse] ?? 0;

      final submitted =
          int.tryParse(widget.student!['submitted_fees'] ?? '0') ?? 0;
      submittedFeesController.text = submitted.toString();
      _calculateRemaining(submitted.toString());

      if (widget.student!['receipt_path'] != null &&
          widget.student!['receipt_path'].isNotEmpty) {
        _receiptImage = File(widget.student!['receipt_path']);
      }
    }

    // Listening to fee inputs to update the remaining balance in real-time
    submittedFeesController.addListener(() {
      _calculateRemaining(submittedFeesController.text);
    });
  }

  // Logic to calculate the balance fee
  void _calculateRemaining(String value) {
    int submitted = int.tryParse(value) ?? 0;
    setState(() {
      _remainingFees = _totalFees - submitted;
    });
  }

  // Picking a fee receipt image
  Future<void> _pickReceipt() async {
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
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  // Finalizing and saving student data to SQLite
  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      final studentData = {
        'name': nameController.text,
        'email': emailController.text,
        'mobile': mobileController.text,
        'course': _selectedCourse,
        'fees': _totalFees.toString(),
        'submitted_fees': submittedFeesController.text,
        'receipt_path': _receiptImage?.path ?? '',
      };

      if (widget.student == null) {
        await DatabaseHelper().insertStudent(studentData);
      } else {
        studentData['id'] = widget.student!['id'];
        await DatabaseHelper().updateStudent(studentData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Student Record Saved!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Success signal to list page
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.student != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Details" : "New Admission"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  nameController,
                  "Student Name",
                  Icons.person,
                  (v) => v!.isEmpty ? "Enter name" : null,
                ),
                const SizedBox(height: 15),
                // Email field is disabled in edit mode to maintain data integrity
                _buildTextField(
                  emailController,
                  "Email Address",
                  Icons.email,
                  (v) => v!.isEmpty ? "Enter email" : null,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isEditMode,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  mobileController,
                  "Mobile Number",
                  Icons.phone,
                  (v) => v!.length != 10 ? "Enter 10 digit number" : null,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 15),

                // Course Dropdown - Automatically updates the total fees
                DropdownButtonFormField<String>(
                  initialValue: _selectedCourse,
                  decoration: InputDecoration(
                    labelText: "Select Course",
                    prefixIcon: const Icon(
                      Icons.book,
                      color: Colors.deepPurple,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _courseFees.keys.map((course) {
                    return DropdownMenuItem(value: course, child: Text(course));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCourse = value;
                      _totalFees = _courseFees[value] ?? 0;
                      _calculateRemaining(submittedFeesController.text);
                    });
                  },
                  validator: (v) => v == null ? "Select a course" : null,
                ),
                const SizedBox(height: 20),

                // Automated Fee Section
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoField("Total Fee", "₹$_totalFees"),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoField(
                        "Remaining",
                        "₹$_remainingFees",
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  submittedFeesController,
                  "Submitted Fees",
                  Icons.account_balance_wallet,
                  (v) => v!.isEmpty ? "Enter amount" : null,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickReceipt,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            _receiptImage == null
                                ? "Upload Fee Receipt"
                                : "Receipt Uploaded: ${_receiptImage!.path.split('/').last}",
                          ),
                        ),
                        if (_receiptImage != null)
                          const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _saveStudent,
                  child: Text(
                    isEditMode ? "Update Records" : "Submit Admission",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?)? validator, {
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        fillColor: enabled ? null : Colors.grey[200],
        filled: !enabled,
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  Widget _buildInfoField(
    String label,
    String value, {
    Color color = Colors.black,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
