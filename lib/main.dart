import 'package:flutter/material.dart';

void main() {
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
          seedColor: const Color(0xFF1E3A8A), // Deep Navy Blue
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF10B981), // Emerald Accent
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

// Global data layer mocking local persistence state across screens
List<Map<String, String>> globalStudentDirectory = [
  {'name': 'Alex Kioko', 'id': 'BIT/0024/2023', 'course': 'Information Technology', 'email': 'alex.kioko@student.ac.ke'},
  {'name': 'Jane Muthoni', 'id': 'BIT/0112/2023', 'course': 'Computer Science', 'email': 'jane.muthoni@student.ac.ke'},
];

// ============================================================================
// SCREEN 1: LOGIN SCREEN (Form Validation & Auth Simulation)
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                const Icon(Icons.shield_rounded, size: 85, color: Color(0xFF1E38A)),
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
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Enter a legitimate email';
                    }
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
                    if (value.length < 6) return 'Password must meet security threshold (>5 chars)';
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
                    elevation: 2,
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
// SCREEN 2: MAIN DASHBOARD HUB (Metrics & Navigation Center)
// ============================================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1E3A8A)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 50, color: Colors.white),
                  SizedBox(height: 8),
                  Text('System Controller', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Nairobi Admin Node', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFF1E3A8A)),
              title: const Text('Administrative Hub'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1, color: Color(0xFF1E3A8A)),
              title: const Text('Register New Records'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(context, '/register');
                _refreshData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_stories, color: Color(0xFF1E3A8A)),
              title: const Text('Course Department Index'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/courses');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_applications, color: Color(0xFF1E3A8A)),
              title: const Text('Node Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Terminate Token'),
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INTERACTIVE EXPLORE HEADER CARD
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('System Integrity Checked: ${globalStudentDirectory.length} active database allocations detected.'),
                    backgroundColor: const Color(0xFF1E3A8A),
                  ),
                );
              },
              child: Card(
                color: const Color(0xFF1E3A8A).withOpacity(0.06),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.2),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.explore_outlined, color: Color(0xFF1E3A8A), size: 30),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore System Status Dashboard',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                            ),
                            Text(
                              'Click here to process metric status updates instantly.',
                              style: TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF1E3A8A)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enrolled Registry (${globalStudentDirectory.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/register');
                    _refreshData();
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
              child: globalStudentDirectory.isEmpty
                  ? const Center(child: Text('Database architecture currently unallocated.'))
                  : ListView.builder(
                itemCount: globalStudentDirectory.length,
                itemBuilder: (context, index) {
                  final item = globalStudentDirectory[index];
                  return Card(
                    elevation: 1.5,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                        child: const Icon(Icons.badge, color: Color(0xFF1E3A8A)),
                      ),
                      title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item['id']}\n${item['course']}\n${item['email']}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            globalStudentDirectory.removeAt(index);
                          });
                        },
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
          if (index == 1) {
            Navigator.pushNamed(context, '/courses');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/settings');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Hub'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// ============================================================================
// SCREEN 3: STUDENT REGISTRATION FORM (Form Processing & Local Storage Persistence)
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

  final List<String> _courses = [
    'Information Technology',
    'Computer Science',
    'Software Engineering',
    'Business Information Systems'
  ];

  void _commitRecord() {
    if (_formKey.currentState!.validate()) {
      globalStudentDirectory.add({
        'name': _nameController.text,
        'id': _idController.text,
        'email': _emailController.text,
        'course': _selectedCourse,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record committed successfully to local registry state.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    super.dispose();
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
                validator: (value) => (value == null || value.isEmpty) ? 'Valid unique identification parameters required' : null,
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
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Student email cannot be empty ! ';
                  if (!value.contains('@')) return 'Invalid domain layout mapping missing @ symbol';
                  return null;
                },
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
                child: const Text('Commit Profiles Offline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 4: COURSE EXPLORER (Department Catalog Representation)
// ============================================================================
class CourseExplorerScreen extends StatelessWidget {
  const CourseExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> departmentCatalog = [
      {'code': 'BIT 4107', 'title': 'Advanced Mobile Application Development', 'dept': 'IT'},
      {'code': 'DCS 3201', 'title': 'Object Oriented Programming II', 'dept': 'Computer Science'},
      {'code': 'BBIT 4205', 'title': 'Database Architecture Management Systems', 'dept': 'Information Systems'},
      {'code': 'SE 4102', 'title': 'Native Component Mobile Engineering', 'dept': 'Software Engineering'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Catalogs', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Department Course Matrices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: departmentCatalog.length,
                itemBuilder: (context, index) {
                  final course = departmentCatalog[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFF1E3A8A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.menu_book_rounded, color: Color(0xFF1E3A8A)),
                      ),
                      title: Text(course['code']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      subtitle: Text('${course['title']}\nFaculty: ${course['dept']}'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 20),
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
// SCREEN 5: SETTINGS & SYSTEM CONFIGURATION SCREEN (System Summary)
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
                    children: [Text('Environment Runtime Framework:', style: TextStyle(fontWeight: FontWeight.w500)), Text('Flutter SDK 2026')],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('System Data Target Architecture:', style: TextStyle(fontWeight: FontWeight.w500)), Text('Local State / Memory Map')],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Operational Node Node Status:', style: TextStyle(fontWeight: FontWeight.w500)), Text('Active Testing Sync', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Administrative Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF1E3A8A)),
            title: const Text('Simulate Persistent SQLite Export'),
            subtitle: const Text('Prepares data schemas for offline DB pipelines.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Schema initialization verified.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security_update_good_outlined, color: Color(0xFF1E3A8A)),
            title: const Text('Clear Active Cached Allocations'),
            subtitle: const Text('Flushes runtime mock data directory storage structures.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              globalStudentDirectory.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Temporary runtime local memory registries dropped.'), backgroundColor: Colors.redAccent),
              );
            },
          ),
        ],
      ),
    );
  }
}