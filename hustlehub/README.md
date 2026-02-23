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