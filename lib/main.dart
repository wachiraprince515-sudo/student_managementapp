import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

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
      // 🎯 WEEK 10 IMPROVEMENT 1: Route to Splash Screen on launch instead of Login
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(), // New Route
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
// 🎯 WEEK 10 FEATURE 1: SPLASH SCREEN (UX & Loading Animation)
// ============================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Simulate system diagnostic initialization delay before routing to authentication login
    Future.delayed(const Duration(seconds: 3, milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school_rounded, size: 85, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 24),
              const Text(
                'EduManage Pro',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
              ),
              const SizedBox(height: 8),
              Text(
                'System Core Integration • v1.10.0',
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 48),
              // 🎯 WEEK 10 FEATURE 3A: Progress indicator tracking startup state
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Color(0xFF10B981),
                  strokeWidth: 3.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SQLITE LOCAL DATABASE LAYER (DBService)
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
        await db.insert('Students', {'id': 'BIT/0024/2023', 'name': 'Alex Kioko', 'course': 'Information Technology', 'email': 'alex.kioko@student.ac.ke'});
        await db.insert('Students', {'id': 'BIT/0112/2023', 'name': 'Jane Muthoni', 'course': 'Computer Science', 'email': 'jane.muthoni@student.ac.ke'});
      },
    );
  }

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
// SCREEN 1: LOGIN SCREEN
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
          content: Row(
            children: [
              Icon(Icons.verified_user, color: Colors.white),
              SizedBox(width: 12),
              Text('Access Granted. Synchronizing Portal Modules...'),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
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
                const SizedBox(height: 12),
                const Text(
                  'KIng SYs Administrator',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                const Text(
                  'Secure Student Portal',
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
// SCREEN 2: MAIN DASHBOARD HUB
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

    // 🎯 WEEK 10 FEATURE 2A: Upgraded notification context tracking for destructive changes
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student file ($id) dropped from local instance.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
        ),
      );
    }
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
              // 🎯 WEEK 10 FEATURE 3B: Integrated linear progress layout for structural filtering
              child: _isLoading
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Filtering records...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
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
// SCREEN 3: STUDENT REGISTRATION
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
        // 🎯 WEEK 10 FEATURE 2B: Enhanced Dialog Notification on explicit database commit success
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 54),
              title: const Text('Record Committed'),
              content: Text('Profile for ${_nameController.text} has been structurally bound to the SQLite core schema.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); // Close Dialog
                    Navigator.pop(context);       // Return to Hub
                  },
                  child: const Text('Return to Hub', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
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
              const SizedBox(height: 20),
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

              const Divider(height: 40, thickness: 1.5),

              const HardwareIntegrationModule(),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 4: REST API CONSUMER MODULE
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
            const Text('Remote JSON Data Payload (Week 6 Target)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 12),
            Expanded(
              // 🎯 WEEK 10 FEATURE 3C: Full screen loader overlay mapping with intuitive descriptions
              child: _isNetworkLoading
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                    SizedBox(height: 16),
                    Text('Consuming Remote REST Endpoints...', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                  ],
                ),
              )
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

// ============================================================================
// DEVICE FEATURES INTEGRATION (CAMERA & GPS LOCATION)
// ============================================================================
class HardwareIntegrationModule extends StatefulWidget {
  const HardwareIntegrationModule({super.key});

  @override
  State<HardwareIntegrationModule> createState() => _HardwareIntegrationModuleState();
}

class _HardwareIntegrationModuleState extends State<HardwareIntegrationModule> {
  File? _capturedImage;
  String _gpsCoordinates = "Coordinates: Tap 'Get Location' to request GPS module...";
  bool _isLoadingLocation = false;

  Future<void> _capturePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo assets captured successfully via native intent!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera error / permission rejection: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _getGPSLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() => _isLoadingLocation = true);

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Hardware location toggle is turned off on device.';
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Permissions are locked permanently in Android settings.';
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _gpsCoordinates = "Latitude: ${position.latitude.toStringAsFixed(6)}\nLongitude: ${position.longitude.toStringAsFixed(6)}";
      });
    } catch (error) {
      setState(() {
        _gpsCoordinates = "Fault: $error";
      });
    } fractionally {
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Smart Campus Explorer Features (Week 9 Tasks)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 14),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _capturedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.file(_capturedImage!, fit: BoxFit.cover),
              )
                  : const Center(child: Text('No campus media captured yet.', style: TextStyle(color: Colors.grey))),
            ),
            const SizedBox(height: 14),
            Text(
              _gpsCoordinates,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'monospace', color: Colors.black87),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _capturePhoto,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Capture Photo'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _getGPSLocation,
                  icon: _isLoadingLocation
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.my_location),
                  label: const Text('Get GPS'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}