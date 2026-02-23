# Flutter Project Structure – HustleHub

## Introduction

This document explains the folder structure of our Flutter project HustleHub. Understanding this structure helps us organize code efficiently, manage assets properly, and collaborate smoothly as a team while building scalable mobile applications.

---

## 📁 Folder Overview

hustlehub/
│
├── android/
├── ios/
├── lib/
│ └── main.dart
├── test/
├── assets/
├── pubspec.yaml
├── README.md
└── PROJECT_STRUCTURE.md


---

## 🔹 lib/

This is the core folder of the Flutter application.  
All Dart code lives here including screens, widgets, services, and models.

- main.dart: Entry point of the app.

---

## 🔹 android/

Contains native Android configuration files such as Gradle scripts and AndroidManifest.xml.  
Used when building the Android version of HustleHub.

---

## 🔹 ios/

Contains iOS-specific build files and configurations used by Xcode for iOS deployment.

---

## 🔹 assets/

Stores static files like images, fonts, and JSON data.  
Assets must be registered inside pubspec.yaml before use.

---

## 🔹 test/

Contains automated test files for validating widgets and logic.

---

## 🔹 pubspec.yaml

Main configuration file.

Used to:

- Manage dependencies
- Register assets
- Define app metadata

---

## 🔹 Supporting Files

- README.md: Project documentation
- .gitignore: Files ignored by Git
- build/: Generated build outputs
- .dart_tool / .idea: IDE and Dart configs

---

## Reflection

Understanding Flutter’s folder structure allows our team to:

- Keep code organized
- Avoid merge conflicts
- Scale features cleanly
- Collaborate efficiently

A clean structure improves productivity and makes onboarding new developers easier.

---