# EduManage Pro — Advanced Student Information Management Platform

EduManage Pro is a high-performance, modular mobile application built with Flutter to serve as a secure administrative student registry portal. This production version implements robust architectural principles to bridge the gap between material user interface engineering, embedded relational data management, and asynchronous remote networking pipelines.

This codebase fulfills all requirements outlined in the **BIT4107 Mobile Application Development** syllabus for Weeks 4 and 5, culminating in a complete portfolio submission.

---

Key Features & System Modules

### 1. Security & Administrative Authentication
* **Input Validation Filters:** Implements real-time Regular Expression (RegExp) checks on data fields to capture malformed inputs at the UI layer.
* **Credential Protection:** Secured with dynamic state toggles to control character field masking (`obscureText`) for administration access.

### 2. Embedded Relational Persistence Layer (Week 4 Focus)
* **SQLite Infrastructure:** Utilizes an integrated RDBMS file engine (`sqflite`) for hard storage persistence across device runtime cycles.
* **Full CRUD Operations:** Programs custom backend services handling database record compilation (Create), dynamic view fetches (Read), matching text filter logic (Search), and explicit data drops (Delete).

 3. Asynchronous REST API Consumer Matrix (Week 5 Focus)
* **HTTP Network Processing:** Deploys non-blocking background transport worker threads to isolate web requests from the main frame rendering loop.
* **JSON Serialization:** Fetches, decodes, and maps remote payload array streams directly into user interface data cards.
* **Network Fault Tolerance:** Hard-coded timeout guards and context-driven messaging arrays to handle slow network channels or service drops gracefully.

---

 Project Architecture & Dependencies

This system follows a modular architectural pipeline where view models decouple visual layouts from underlying persistence data rows:

```text
lib/
└── main.dart  # Central Hub containing App Engine Initialization,
               # SQLite Service Layer, Named Route Form Validation,
               # and Asynchronous Network Consumers.
Registered System Packages (pubspec.yaml):
•	sqflite: ^2.3.0 — Embedded local relational database management engine.
•	path: ^1.9.0 — Cross-platform physical file directory mapper.
•	http: ^1.2.0 — Asynchronous network request engine.
Database Schema Mapping
The local system creates a structured, permanent storage file named edumanage_pro.db featuring a target relational matrix schema:
Table: Students
Column Field	Data Type	Constraint Key	Description
id	TEXT	PRIMARY KEY	Unique Academic Registration Identifier
name	TEXT	Not Null	Legal Full Name Mapping String
email	TEXT	Not Null	Verified Domain Academic Mail Map
course	TEXT	Not Null	Assigned Academic Department Allocation
Installation, Cache Maintenance & Execution
To execute this advanced codebase version cleanly on an emulator or physical testing hardware device (such as the Samsung SM-A155F), follow these environmental alignment steps:
1. Fetch Remote Branch Pointers
Ensure your machine is pointed directly at the dedicated advanced branch:
PowerShell
git checkout v2-storage-api
2. Rebuild Package Dependencies
Fetch and link the required SQLite and HTTP service packages from the cloud registry:
PowerShell
flutter pub get
3. Purge Corrupted Compilation Stacks (If required)
If you encounter local workspace dependency asset blocks or Invalid depfile warnings from old builds, flush the caching tree entirely:
PowerShell
flutter clean
flutter pub get
Remove-Item -Recurse -Force .dart_tool
4. Deploy and Compile App Target
Launch compilation directly onto your connected hardware interface:
PowerShell
flutter run
Academic Portfolio Credits
•	Course Code: BIT4107 — Mobile Application Development
•	Evaluation Milestone: CAT 1 Presentation Portfolio
•	Development Branch: v2-storage-api (SQLite / REST API Live Consumer Production Node)

