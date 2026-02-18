Sprint #2 Project Plan – Freelance Workflow Manager
1. Problem Statement & Solution Overview

Problem Statement
Freelancers often juggle multiple clients, tasks, deadlines, and payments across different tools (chat apps, notes, spreadsheets). This fragmentation causes missed follow-ups, unclear priorities, delayed payments, and poor visibility into work progress.

Solution Overview
We propose a mobile-first Freelance Workflow Manager built with Flutter and Firebase that centralizes tasks, client details, deadlines, and payment tracking into a single, real-time app. The mobile experience enables freelancers to quickly update task status, check upcoming deadlines, and monitor payments on the go, ensuring better organization and accountability.

Target Users

Independent freelancers (designers, developers, writers, marketers)

Early-stage consultants managing multiple clients

Why This Matters Now
Remote work and freelancing are growing rapidly. Freelancers need lightweight, reliable mobile tools that replace scattered systems with one unified workflow hub.

Why Mobile (Flutter) + Firebase

Mobile-first usage suits freelancers’ on-the-go lifestyle

Flutter ensures fast, consistent UI across Android & iOS

Firebase provides real-time sync, authentication, and scalable backend with minimal setup

2. Scope & Boundaries
In Scope (Sprint #2)

Firebase Authentication (Email/Password)

Client management (basic profile: name, contact, notes)

Task management (CRUD tasks with deadline & status)

Payment tracking (pending / received status)

Dashboard with real-time data from Firestore

Core Flutter UI screens

APK build for demo

Out of Scope (Not in Sprint #2)

Push notifications & reminders

Advanced analytics & reports

In-app chat with clients

Payment gateway integration

Desktop/Web optimization

3. Roles & Responsibilities (Detailed)
Team Structure (3 Members)
Role	Team Member	Detailed Responsibilities
Frontend (Flutter)	App UI architecture, Flutter widgets, navigation, responsive layouts, reusable components, UI polish
Backend (Firebase) 	Firebase project setup, Authentication, Firestore schema design, security rules, backend logic
Integration, Testing & Deployment 	UI–Firebase integration, CRUD logic, state management, validation, testing, APK builds, CI/CD
Contribution Breakdown

Frontend (Flutter )

Design wireframes (Login, Dashboard, Clients, Tasks, Payments, Profile)

Implement reusable UI components (cards, buttons, forms)

Set up navigation (bottom nav / drawer)

Ensure responsive layouts and smooth animations

Backend (Firebase )

Create Firebase project & environments

Configure Firebase Auth (Sign In, Sign Up, Logout)

Design Firestore collections:

users

clients

tasks

payments

Implement Firestore security rules

Integration, Testing & Deployment

Connect Flutter screens to Firestore

Implement CRUD operations for clients, tasks, payments

Manage app state (Provider/Riverpod)

Handle loading, error, and empty states

Define and execute test cases

Generate debug & release APKs

Set up GitHub Actions CI/CD

Prepare demo checklist & documentation

---|---|---| | Frontend (Flutter) Lead |  App UI architecture, Flutter widgets, navigation, responsive layouts, state management, UI polish | | Backend (Firebase) Lead | Firebase project setup, Auth integration, Firestore schema design, security rules, backend logic | | Integration & Logic Engineer | Connecting Flutter UI with Firebase, CRUD logic, form validation, error handling, app state flow | | Testing & Deployment Lead | Testing strategy, widget & integration tests, APK builds, CI/CD setup, final deployment prep |

Contribution Breakdown

Frontend (Flutter )

Design wireframes (Login, Dashboard, Clients, Tasks, Payments, Profile)

Implement reusable UI components (cards, buttons, forms)

Set up navigation (bottom nav / drawer)

Ensure responsive layouts and smooth animations

Backend (Firebase )

Create Firebase project & environments

Configure Firebase Auth (Sign In, Sign Up, Logout)

Design Firestore collections:

users

clients

tasks

payments

Implement Firestore security rules

Integration & App Logic 

Connect Flutter screens to Firestore

Implement CRUD operations for clients, tasks, payments

Manage app state (Provider/Riverpod)

Handle loading, error, and empty states

Testing & Deployment 

Define test cases for auth & CRUD flows

Run widget & integration tests

Generate debug & release APKs

Set up GitHub Actions CI/CD

Prepare demo checklist & documentation

4. Sprint Timeline (4 Weeks)
Week-by-Week Plan
Week	Focus Area	Milestones / Deliverables	Owners
Week 1	Setup & Design	Finalize app idea, wireframes, Firebase setup, Flutter project structure	All (Lead: Aditi & Rahul)
Week 2	Core Development	Auth flows, Firestore schema, Dashboard UI, basic CRUD screens	 
Week 3	Integration & Testing	UI–Firebase integration, CRUD testing, validation, error handling	
Integration & Testing	UI–Firebase integration, CRUD testing, validation, error handling	
Week 4	MVP & Deployment	UI polish, feature freeze, APK build, demo & documentation	Meera (Lead), All
5. Deployment & Testing Plan
Testing Strategy

Widget tests for core UI components

Integration tests for Auth & Firestore CRUD

Manual UAT for:

Login/Signup

Task creation & updates

Payment status changes

Deployment

GitHub Actions for CI/CD

Generate APK for Android demo

Share APK via Google Drive for review

6. MVP (Minimum Viable Product)
MVP Features (Must-Have)

User authentication (Sign Up, Login, Logout)

Add & view clients

Create, update, delete tasks with status & deadlines

Track payment status (pending/received)

Dashboard summarizing tasks & payments

Real-time Firestore sync

Working APK

Core App Screens

Splash Screen

Login / Sign Up

Dashboard

Clients List & Detail

Tasks List & Detail

Payments Overview

Profile & Settings

7. Functional Requirements

Users can securely register and log in

Users can create, edit, and delete clients

Users can manage tasks linked to clients

Users can track payment status per task/client

App reflects real-time Firestore updates

8. Non-Functional Requirements

Performance: Screen transitions < 200 ms

Scalability: Minimum 100 concurrent users

Security: Firebase Auth + Firestore rules

Reliability: No crashes during CRUD operations

Responsiveness: Works on Android phones of varying sizes

9. Success Metrics

All MVP features implemented and functional

Firebase Auth + Firestore fully integrated

APK builds successfully and runs without errors

All planned PRs merged on time

Positive mentor/demo feedback

10. Risks & Mitigation
Risk	Impact	Mitigation
Firebase misconfiguration	Backend delays	Use mock data to unblock frontend
Integration bugs	Feature delays	Early integration in Week 3
UI inconsistency	Poor demo quality	UI review & polish in Week 4

Final Note
This project plan serves as the execution blueprint for Sprint #2. The goal is not feature overload, but a stable, well-integrated Flutter + Firebase MVP that clearly demonstrates real-world value for freelancers.

“We’re not just managing tasks—we’re giving freelancers clarity, control, and confidence in their daily workflow.”