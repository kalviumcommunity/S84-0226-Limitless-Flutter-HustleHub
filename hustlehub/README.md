# HustleHub - Freelance Workflow Manager

*A Smart Workflow & Client Management App for Freelancers*

------------------------------------------------------------------------

## 📌 Problem Statement

Freelancers often juggle tasks, client deadlines, and payments without a
unified system, leading to confusion and missed follow-ups.  
This project provides a single mobile platform where freelancers can
manage clients, projects, tasks, deadlines, and payment status — all in
one place.

------------------------------------------------------------------------

## 🚀 Solution Overview

HustleHub is a Flutter + Firebase powered mobile application that
helps freelancers organize their entire workflow from one dashboard.

The app allows users to:

-   Manage clients and projects
-   Track tasks and deadlines
-   Monitor payments
-   Receive real-time updates
-   Stay productive with a clean, responsive UI

------------------------------------------------------------------------

## 🎯 MVP Features

### 🔐 Authentication

-   Email & Password Signup/Login
-   Persistent user sessions

### 👤 Client Management

-   Add / Edit / Delete clients
-   Store contact information
-   View client-wise projects

### 📂 Project & Task Tracking

-   Create projects per client
-   Add tasks with deadlines
-   Update task status (Pending / Completed)
-   Real-time syncing using Firestore

### 💰 Payment Tracking

-   Track paid and pending payments
-   View payment history

------------------------------------------------------------------------

## 🧠 Tech Stack

### Frontend

-   Flutter
-   Dart

### Backend

-   Firebase Authentication
-   Cloud Firestore
-   Firebase Storage
-   Firebase Cloud Messaging

### State Management

-   Provider / Riverpod

------------------------------------------------------------------------

### 📁 Project Folder Structure

This project follows Flutter’s standard folder organization for clean architecture and scalability.

- Detailed explanation of each folder is documented in:

👉 PROJECT_STRUCTURE.md

- Main folders used:

lib/ – Application logic and UI

android/ – Android native configuration

ios/ – iOS native configuration

assets/ – Images and static files

test/ – Automated tests

pubspec.yaml – Dependency & asset management

This structure allows modular development and smooth collaboration across team members.

------------------------------------------------------------------------

## MaterialApp
 ┗ Scaffold
    ┣ AppBar
    ┗ Body
       ┗ Center
          ┗ Column
             ┣ Text (Counter)
             ┣ ElevatedButton (Increment)
             ┣ Text (Conditional Message)
             ┗ ElevatedButton (Toggle)

------------------------------------------------------------------------

## 🏗 High Level Architecture (HLD)

Flutter UI  
↓  
State Management (Provider / Riverpod)  
↓  
Firebase Services (Auth, Firestore, Storage)

------------------------------------------------------------------------

## 📁 Firestore Database Structure

users/  
userId/  
name  
email

clients/  
clientId/  
userId  
name  
contact

projects/  
projectId/  
clientId  
title  
deadline

tasks/  
taskId/  
projectId  
title  
status

payments/  
paymentId/  
clientId  
amount  
status

------------------------------------------------------------------------

## 🛠 Setup Instructions

### Clone Repository

git clone https://github.com/kalviumcommunity/S84-0226-Limitless-Flutter-HustleHub.git 
cd HustleHub

### Install Dependencies

flutter pub get

### Configure Firebase

1.  Create Firebase Project  
2.  Add Android App  
3.  Download google-services.json  
4.  Place inside android/app/  
5.  Run flutterfire configure

### Run App

flutter run

------------------------------------------------------------------------

## 📦 Build Release APK

flutter build apk –release

------------------------------------------------------------------------

## 👨‍💻 Team

-   Flutter Developer  
-   Firebase Backend  
-   UI/UX Designer

------------------------------------------------------------------------

## 📄 License

Educational project under Kalvium Sprint \#2.

------------------------------------------------------------------------

## 🔄 Stateless vs Stateful Widgets Demo

This demo demonstrates the difference between Stateless and Stateful widgets in Flutter.

# Stateless Widget

Used for static UI elements that do not change during runtime.

- Example from our project:

```
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Interactive Counter App",
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
```

# Stateful Widget

- Used for dynamic UI that updates based on user interaction.

```
class DemoBody extends StatefulWidget {
  const DemoBody({super.key});

  @override
  State<DemoBody> createState() => _DemoBodyState();
}

class _DemoBodyState extends State<DemoBody> {
  int counter = 0;

  void increment() {
    setState(() {
      counter++;
    });
  }
}
```

## Behavior

- Header text remains static (StatelessWidget)

- Counter updates on button click (StatefulWidget)

This separation allows Flutter apps to remain efficient and maintainable.

------------------------------------------------------------------------

## ⚡ Hot Reload, Debug Console & Flutter DevTools

- This section demonstrates how Flutter’s development tools improve productivity and debugging.

# Hot Reload

Hot Reload allows instant UI updates without restarting the app.

Steps followed:

- Modified widget code

- Pressed r in terminal

- Changes reflected immediately while preserving state

# Debug Console

Used `debugPrint()` to log runtime data.

```
debugPrint("Button pressed! Counter value: $counter");
```

This helped track button presses and state updates in real time.

## Flutter DevTools

Flutter DevTools was launched to inspect:

- Widget tree using Widget Inspector

- UI hierarchy

- App performance

These tools together enable faster iteration, easier debugging, and better optimization.

## Reflection

Hot Reload speeds up UI experimentation.
Debug Console provides visibility into app behavior.
Flutter DevTools helps analyze widgets and performance.

Together, they form an efficient Flutter development workflow.

------------------------------------------------------------------------

## 🧭 Multi-Screen Navigation Using Navigator & Routes

This demo implements multi-screen navigation using Flutter’s Navigator and named routes.

# Screens Implemented

- HomeScreen

- SecondScreen

# Route Configuration (main.dart)

```
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => const HomeScreen(),
    '/second': (context) => const SecondScreen(),
  },
);
```
# avigation Logic

From Home Screen:

```
Navigator.pushNamed(context, '/second');
```

From Second Screen:

```
Navigator.pop(context);
```

# Reflection

Flutter uses a stack-based navigation system.
`Navigator.pushNamed()` adds a screen to the stack.
`Navigator.pop()` removes the top screen and returns to the previous one.

Named routes help keep navigation organized and scalable in larger applications.