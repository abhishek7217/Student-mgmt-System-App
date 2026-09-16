import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'login_page.dart';
import '../services/database_helper.dart';
import 'admission_form_page.dart';
import 'profile_update_screen.dart';

// The main hub of the application, providing overview and navigation
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int totalStudents = 0;
  int pendingFees = 0;

  // Initializing dummy data for demonstration purposes
  final List<Map<String, dynamic>> dummyStudents = [
    {'name': 'Rahul Sharma', 'course': 'Computer Science', 'mobile': '9876543210', 'fees': '50000', 'submitted_fees': '30000', 'id': -1},
    {'name': 'Priya Singh', 'course': 'Data Science', 'mobile': '8765432109', 'fees': '60000', 'submitted_fees': '60000', 'id': -2},
    {'name': 'Amit Kumar', 'course': 'Cloud Computing', 'mobile': '7654321098', 'fees': '70000', 'submitted_fees': '20000', 'id': -3},
    {'name': 'Sneha Patel', 'course': 'Cyber Security', 'mobile': '6543210987', 'fees': '65000', 'submitted_fees': '65000', 'id': -4},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Refreshing data from SQLite and merging with dummy records
  Future<void> _loadData() async {
    final students = await DatabaseHelper().queryAllStudents();
    int sqliteCount = students.length;
    int sqlitePending = 0;

    for (var s in students) {
      int total = int.tryParse(s['fees'] ?? '0') ?? 0;
      int submitted = int.tryParse(s['submitted_fees'] ?? '0') ?? 0;
      sqlitePending += (total - submitted);
    }

    // Calculating pending fees for dummy records
    int dummyPending = 0;
    for (var s in dummyStudents) {
      dummyPending += (int.parse(s['fees']) - int.parse(s['submitted_fees']));
    }

    setState(() {
      totalStudents = dummyStudents.length + sqliteCount;
      pendingFees = dummyPending + sqlitePending;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    List<Widget> pages = [
      _buildHomeView(),
      _buildAdmissionView(),
      StudentListWidget(onRefresh: _loadData, dummyData: dummyStudents),
      _buildAboutView(),
    ];

    // Using PopScope to prevent accidental app exit on back press
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
          title: Text(_selectedIndex == 0 ? "Welcome ${userProvider.name ?? ''}" : _getPageTitle(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            // Right-side profile shortcut
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileUpdateScreen())),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  backgroundImage: (userProvider.profilePath != null && userProvider.profilePath!.isNotEmpty)
                      ? FileImage(File(userProvider.profilePath!))
                      : null,
                  child: (userProvider.profilePath == null || userProvider.profilePath!.isEmpty)
                      ? const Icon(Icons.person, size: 20, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.deepPurple),
                accountName: Text(userProvider.name ?? "User Name"),
                accountEmail: Text(userProvider.email ?? "user@example.com"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: (userProvider.profilePath != null && userProvider.profilePath!.isNotEmpty)
                      ? FileImage(File(userProvider.profilePath!))
                      : null,
                  child: (userProvider.profilePath == null || userProvider.profilePath!.isEmpty)
                      ? const Icon(Icons.person, size: 40, color: Colors.deepPurple)
                      : null,
                ),
              ),
              _buildDrawerItem(Icons.home, "Home", 0),
              _buildDrawerItem(Icons.update, "Update Profile", -1, onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileUpdateScreen()));
              }),
              _buildDrawerItem(Icons.info, "About", 3),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () async {
                  await userProvider.logout();
                  if (!mounted) return;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                },
              ),
            ],
          ),
        ),
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Admission'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  // Safety dialog to prevent unwanted exits
  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App?"),
        content: const Text("Are you sure you want to exit the application?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(onPressed: () => exit(0), child: const Text("Yes")),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 1: return "New Admission";
      case 2: return "Student Records";
      case 3: return "About App";
      default: return "Dashboard";
    }
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
      onTap: onTap ?? () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  void _showCoursesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Active Courses", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: const [
              ListTile(leading: Icon(Icons.computer), title: Text("Computer Science")),
              ListTile(leading: Icon(Icons.analytics), title: Text("Data Science")),
              ListTile(leading: Icon(Icons.code), title: Text("Software Engineering")),
              ListTile(leading: Icon(Icons.security), title: Text("Cyber Security")),
              ListTile(leading: Icon(Icons.cloud), title: Text("Cloud Computing")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Quick Stats", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard("Total Students", totalStudents.toString(), Colors.blue, Icons.people, () => setState(() => _selectedIndex = 2))),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard("Active Courses", "5", Colors.orange, Icons.book, () => _showCoursesDialog())),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatCard("New Requests", "12", Colors.green, Icons.notifications, () {})),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard("Pending Fees", "₹ $pendingFees", Colors.red, Icons.money, () {})),
            ],
          ),
          const SizedBox(height: 30),
          const Text("Institutional Updates", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 10),
          _buildActivityItem("Admission process started for Batch 2024", "2 mins ago"),
          _buildActivityItem("Course list updated for Data Science", "1 hour ago"),
          _buildActivityItem("Fee receipt verified for Student ID #102", "Yesterday"),
          const SizedBox(height: 30),
          const Text("Important Notice", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 10),
          Card(
            color: Colors.deepPurple[50],
            child: const ListTile(
              leading: Icon(Icons.event, color: Colors.deepPurple),
              title: Text("Semester Exams - Start Dec 15", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Contact administration for datesheets"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String activity, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 10, color: Colors.deepPurple),
          const SizedBox(width: 15),
          Expanded(child: Text(activity, style: const TextStyle(fontSize: 16))),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(colors: [color.withValues(alpha: 0.7), color]),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 10),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdmissionView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionCard("Add New Student", "Start a new admission process", Icons.person_add, Colors.deepPurple, () async {
              final result = await Navigator.pushNamed(context, 'AdmissionFormPage');
              if (result == true) _loadData();
            }),
            const SizedBox(height: 20),
            _buildActionCard("Manage Records", "View and edit existing student data", Icons.edit_note, Colors.indigo, () {
              setState(() => _selectedIndex = 2);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color, radius: 30, child: Icon(icon, color: Colors.white, size: 30)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 50, backgroundColor: Colors.deepPurple, child: Icon(Icons.school, size: 60, color: Colors.white)),
          SizedBox(height: 20),
          Text("Student Mgmt System", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
          Padding(
            padding: EdgeInsets.all(30.0),
            child: Text(
              "A comprehensive solution for managing student admissions, records, and institutional data efficiently.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class StudentListWidget extends StatefulWidget {
  final VoidCallback onRefresh;
  final List<Map<String, dynamic>> dummyData;
  const StudentListWidget({super.key, required this.onRefresh, required this.dummyData});

  @override
  State<StudentListWidget> createState() => _StudentListWidgetState();
}

class _StudentListWidgetState extends State<StudentListWidget> {
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  // Fetching real records and merging with the provided dummy records
  Future<void> _fetchStudents() async {
    final data = await DatabaseHelper().queryAllStudents();
    setState(() {
      students = [...widget.dummyData, ...data];
    });
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        bool isDummy = student['id'] < 0;
        int total = int.tryParse(student['fees'] ?? '0') ?? 0;
        int submitted = int.tryParse(student['submitted_fees'] ?? '0') ?? 0;
        int remaining = total - submitted;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isDummy ? Colors.grey : Colors.deepPurple,
              child: Text(student['name'][0].toUpperCase(), style: const TextStyle(color: Colors.white))),
            title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${student['course']}\nPaid: ₹$submitted | Due: ₹$remaining"),
            isThreeLine: true,
            trailing: isDummy ? const Chip(label: Text("Demo", style: TextStyle(fontSize: 10))) : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdmissionFormPage(student: student)),
                    );
                    if (result == true) _fetchStudents();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await DatabaseHelper().deleteStudent(student['id']);
                    _fetchStudents();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
