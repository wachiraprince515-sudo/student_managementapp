import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBService.initDatabase();
  runApp(const EduManageApp());
}

class EduManageApp extends StatelessWidget {
  const EduManageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduManage Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF10B981),
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/courses': (context) => const CourseExplorerScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

// ============================================================================
// WEEK 4 PERSISTENCE LAYER: LOCAL SQLITE DATABASE INFRASTRUCTURE
// ============================================================================
class DBService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDatabase();
    return _db!;
  }

  static Future<Database> initDatabase() async {
    String path = p.join(await getDatabasesPath(), 'edumanage_pro.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Students(
            id TEXT PRIMARY KEY,
            name TEXT,
            course TEXT,
            email TEXT
          )
        ''');
        // Pre-populate records for testing evaluation
        await db.insert('Students', {'id': 'BIT/0024/2023', 'name': 'Alex Kioko', 'course': 'Information Technology', 'email': 'alex.kioko@student.ac.ke'});
        await db.insert('Students', {'id': 'BIT/0112/2023', 'name': 'Jane Muthoni', 'course': 'Computer Science', 'email': 'jane.muthoni@student.ac.ke'});
      },
    );
  }

  // SQLITE CRUD Operations
  static Future<int> insertStudent(Map<String, String> student) async {
    final db = await database;
    return await db.insert('Students', student, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getAllStudents({String query = ""}) async {
    final db = await database;
    if (query.isEmpty) {
      return await db.query('Students');
    } else {
      return await db.query('Students', where: 'name LIKE ? OR id LIKE ?', whereArgs: ['%$query%', '%$query%']);
    }
  }

  static Future<int> updateStudent(Map<String, String> student) async {
    final db = await database;
    return await db.update('Students', student, where: 'id = ?', whereArgs: [student['id']]);
  }

  static Future<int> deleteStudent(String id) async {
    final db = await database;
    return await db.delete('Students', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('Students');
  }
}

// ============================================================================
// SCREEN 1: LOGIN SCREEN (Form Validation & Security Authentication)
// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access Granted. Synchronizing Portal Modules...'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.shield_rounded, size: 85, color: Color(0xFF1E3A8A)),
                const SizedBox(height: 12),
                const Text(
                  'Application Administrator',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                const Text(
                  'Secure Student Management System Portal',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 35),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Authentication email required';
                    if (!value.contains('@')) return 'Enter a legitimate email';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_person_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Security credentials required';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Authenticate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 2: MAIN DASHBOARD HUB (SQLite Fetch, Delete & Live Filter Search)
// ============================================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _students = [];
  final _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshStudentList();
  }

  Future<void> _refreshStudentList() async {
    setState(() => _isLoading = true);
    final data = await DBService.getAllStudents(query: _searchController.text);
    setState(() {
      _students = data;
      _isLoading = false;
    });
  }

  void _deleteStudent(String id) async {
    await DBService.deleteStudent(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record dropped from local SQLite database.'), backgroundColor: Colors.redAccent),
    );
    _refreshStudentList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Hub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEARCH FIELD BAR
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Local Registry Database...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _refreshStudentList();
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => _refreshStudentList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enrolled Registry (${_students.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/register');
                    _refreshStudentList();
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Record'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _students.isEmpty
                  ? const Center(child: Text('No allocations matched search criteria.'))
                  : ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final item = _students[index];
                  return Card(
                    elevation: 1.5,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                        child: const Icon(Icons.badge, color: Color(0xFF1E3A8A)),
                      ),
                      title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item['id']}\n${item['course']}\n${item['email']}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                        onPressed: () => _deleteStudent(item['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/courses');
          if (index == 2) Navigator.pushNamed(context, '/settings');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Hub'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'API Data'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// ============================================================================
// SCREEN 3: STUDENT REGISTRATION (Form Input Committed directly to SQLite)
// ============================================================================
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedCourse = 'Information Technology';

  final List<String> _courses = ['Information Technology', 'Computer Science', 'Software Engineering', 'Business Information Systems'];

  void _commitRecord() async {
    if (_formKey.currentState!.validate()) {
      await DBService.insertStudent({
        'id': _idController.text,
        'name': _nameController.text,
        'email': _emailController.text,
        'course': _selectedCourse,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record committed successfully to local SQLite Database File!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student Record', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Student Profile Meta-Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Legal Full Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Name string cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'Registration Identifier (e.g., BIT/0001/2026)',
                  prefixIcon: const Icon(Icons.fingerprint_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Valid identifier required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Institutional Student Email',
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => (value == null || !value.contains('@')) ? 'Invalid domain layout mapping missing @ symbol' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                decoration: InputDecoration(
                  labelText: 'Assigned Course Allocation',
                  prefixIcon: const Icon(Icons.class_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _courses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCourse = val!),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _commitRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Commit Profile to DB', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 4: WEEK 5 REST API CONSUMER MODULE (Asynchronous HTTP Networking)
// ============================================================================
class CourseExplorerScreen extends StatefulWidget {
  const CourseExplorerScreen({super.key});

  @override
  State<CourseExplorerScreen> createState() => _CourseExplorerScreenState();
}

class _CourseExplorerScreenState extends State<CourseExplorerScreen> {
  List<dynamic> _apiUsers = [];
  bool _isNetworkLoading = true;
  String _networkErrorMsg = "";

  @override
  void initState() {
    super.initState();
    _fetchRemoteUsers();
  }

  // Week 5 REST API Consumption Implementation
  Future<void> _fetchRemoteUsers() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users')).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        setState(() {
          _apiUsers = json.decode(response.body);
          _isNetworkLoading = false;
        });
      } else {
        setState(() {
          _networkErrorMsg = "Server Exception error: Code ${response.statusCode}";
          _isNetworkLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _networkErrorMsg = "Network communication timeout or missing connection channel link.";
        _isNetworkLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live REST API Consumer Matrix', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Remote JSON Data Payload (Week 5 Target)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 12),
            Expanded(
              child: _isNetworkLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _networkErrorMsg.isNotEmpty
                  ? Center(child: Text(_networkErrorMsg, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center))
                  : ListView.builder(
                itemCount: _apiUsers.length,
                itemBuilder: (context, index) {
                  final user = _apiUsers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF10B981),
                        child: Icon(Icons.cloud_download, color: Colors.white, size: 18),
                      ),
                      title: Text(user['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      subtitle: Text('Username: ${user['username']}\nEmail: ${user['email']}\nCompany: ${user['company']['name']}'),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 5: SETTINGS & SYSTEM UTILITIES
// ============================================================================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Meta Configurations', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Local Hardware Deployment Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Environment Runtime Framework:', style: TextStyle(fontWeight: FontWeight.w500)), Text('Flutter SDK Stable')],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('System Data Target Architecture:', style: TextStyle(fontWeight: FontWeight.w500)), Text('SQLite RDBMS Storage File')],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text('Purge Local Database Rows'),
            subtitle: const Text('Completely deletes all rows inside SQLite table.'),
            onTap: () async {
              await DBService.clearDatabase();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All student table rows purged completely!'), backgroundColor: Colors.red),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}