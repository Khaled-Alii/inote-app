<h1 align="center">📝 INote — Smart Flutter Notes App</h1>

<p align="center">
  A feature-rich Flutter note-taking application with local persistence, GPS-based location tracking, and reactive state management using GetX.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
</p>

---

## 📸 Screenshots

| Home Screen | Create Note | Location Feature |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/f3266a5b-b227-4111-8527-9504892f082b" width="250"/> | <img src="https://github.com/user-attachments/assets/1f30e7ff-2c0a-4ef0-adb6-5038026c4e6a" width="250"/> | <img src="https://github.com/user-attachments/assets/74297dc3-6e8a-44e6-a0df-4f570a61b4c2" width="250"/> |
---

## ✨ Key Features

### 🗒 Notes Management & Search

* **Full CRUD Operations:** Create, read, edit, and delete notes seamlessly.
* **Smart Search:** Quickly find specific notes using the built-in search functionality.
* **Smart Sorting:** Chronological sorting with automatic timestamp updates.
* **Bulk Actions:** Support for bulk deletion with an intuitive Undo mechanism.

### 📍 Smart Location Integration

* **GPS Tagging:** Save your current GPS coordinates when creating a note.
* **Live Edits:** Update the note's attached location anytime.
* **External Navigation:** Open saved note locations directly in external map applications (Google
  Maps/Apple Maps).
* **Visual Indicators:** UI elements explicitly highlight location-enabled notes.

### 🔔 Enhanced User Experience

* **Intuitive Empty States:** Beautiful empty state illustrations when no notes are available or
  when a search yields no results.
* **Reactive UI:** Built entirely with GetX for snappy, boilerplate-free state management.
* **Audio & Haptic Feedback:** Sound effects and Snackbar feedback for major user actions.
* **Gesture Controls:** Hardware shake gesture detection to trigger actions (e.g., delete all
  notes).

### 📦 Offline-First Storage

* Persistent, offline-first architecture utilizing SQLite via the **Floor ORM**. Data survives app
  restarts safely and efficiently.

---

## ⚙️ Tech Stack

| Category             | Technology / Package         | Purpose                                 |
|:---------------------|:-----------------------------|:----------------------------------------|
| **Framework**        | Flutter & Dart               | Core UI and Logic                       |
| **State Management** | `get` (GetX)                 | Reactive programming & Routing          |
| **Local Database**   | `floor`, `sqflite`           | SQLite abstraction & persistence        |
| **Device Features**  | `geolocator`, `shake`        | GPS tracking & motion detection         |
| **Utilities**        | `url_launcher`, `just_audio` | External map navigation & sound effects |
| **Dev Tools**        | `build_runner`, `dartx`      | Code generation & Dart extensions       |

---

## 🏗 Architecture & Engineering Concepts

This project was built to demonstrate clean, real-world Flutter engineering practices:

* **Lifecycle Management:** Proper `StatefulWidget` handling and controller disposal to prevent
  memory leaks.
* **Reactive Programming:** Utilizing `RxList` and GetX observers for immediate UI updates.
* **Data Integrity:** Safe state updates using immutable patterns (`copyWith`).
* **Hardware Integration:** Bridging native device sensors (GPS, Accelerometer) with Flutter.

---

## 🚀 Getting Started

Follow these steps to run the project locally on your machine.

### 1. Clone the repository

```bash
git clone [https://github.com/Khaled-Alii/inote-app.git](https://github.com/Khaled-Alii/inote-app.git)
2. Navigate to the project directory
Bash
cd inote-app
3. Install dependencies
Bash
flutter pub get
4. Generate Database Files (Required for Floor ORM)
Bash
flutter pub run build_runner build --delete-conflicting-outputs
5. Run the app
Bash
flutter run
📌 Future Improvements
[ ] Implement Categories / Tags for notes

[ ] Dark Mode support

[ ] Cloud Sync (Firebase Integration)

[ ] Image attachments inside notes

[ ] Push Notifications & Reminders

[ ] Refactor fully into Clean Architecture

👨‍💻 Developer
Khaled Ali Flutter Developer

GitHub: Khaled-Alii

LinkedIn: https://www.linkedin.com/in/khaled-ali-flutter-dev/

⭐ If you found this project helpful or interesting, please consider giving it a star!