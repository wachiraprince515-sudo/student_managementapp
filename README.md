# EduManage Pro - Student Management System

student_managementapp is a secure, clean, and intuitive Student Management System portal built using Flutter and Google's Material 3 design guidelines. This application provides administrative tools to manage student records, explore course catalogs, and maintain local system configurations.

##  Key Features

* **Secure Authentication Portal:** Secure administrator login simulation equipped with strict form input validation and dynamic visibility controls for safety credentials.
* **Administrative Dashboard Hub:** An interactive metrics hub tracking active system integrity and database allocations at a single glance.
* **Student Registry Lifecycle:** Full CRUD interface capability allowing administrators to add unique registration profiles, map student emails, assign courses, and drop cached database records.
* **Faculty Course Catalogs:** Structured department indexes mapping code, title, and faculty information for quick academic matrix reference.
* **System Meta Configurations:** Dedicated administrative node controls to simulate persistent schemas and manage runtime memory states cleanly.

## Architecture & App Routing

The application uses clean, named declarative routing structure to manage state transitions across five core portal modules:
* `/` -> `LoginScreen` (Security Authenticator)
* `/dashboard` -> `DashboardScreen` (Administrative Metrics Hub)
* `/register` -> `RegistrationScreen` (Student Profile Onboarding)
* `/courses` -> `CourseExplorerScreen` (Department Matrix Catalogs)
* `/settings` -> `SettingsScreen` (Node Meta Preferences)

## Tech Stack & Requirements

* **Framework:** Flutter SDK (Material 3 Enabled)
* **Language:** Dart
* **Design Pattern:** State-aware modular UI with centralized state arrays for offline registry mapping.

##  How to Run the Application Locally

1. **Clone the Repository:**
```bash
   git clone https://github.com/wachiraprince515-sudo/student_managementapp.git
cd student_managementapp
