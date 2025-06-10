# 📘 Software Requirements Specification (SRS)

**Project:** Smart Health Companion  
**Platform:** Flutter (Frontend & Backend using Dart) + MySQL (Database)  
**Version:** 1.0  
**Date:** December 2024

---

## 1. Introduction

### 1.1 Purpose

The purpose of this document is to define the functional and non-functional requirements for the Smart Health Companion app. It includes user, doctor, and hospital interfaces, real-time AI assistance, appointment/lab bookings, multilingual support (English/Nepali), and email confirmations.

### 1.2 Scope

The app will provide healthcare solutions through digital means such as appointment scheduling, doctor discovery, lab test management, and AI-assisted chat. Both frontend and backend are built using Dart (Flutter + server-side Dart such as Aqueduct or Dart Frog), and integrates with a MySQL database.

### 1.3 Definitions, Acronyms, and Abbreviations

- **SRS:** Software Requirements Specification
- **AI:** Artificial Intelligence
- **JWT:** JSON Web Token
- **RBAC:** Role-Based Access Control
- **API:** Application Programming Interface
- **SMTP:** Simple Mail Transfer Protocol
- **UI:** User Interface

---

## 2. System Overview

| Component          | Description                                                                        |
| ------------------ | ---------------------------------------------------------------------------------- |
| Frontend           | Flutter (Dart), Tailwind-inspired styling using flutter_tailwind or custom theme |
| Backend            | Dart (Aqueduct or Dart Frog)                                                      |
| Database           | MySQL                                                                              |
| AI Service         | Google Gemini API                                                                  |
| Email              | SMTP using mailer package in Dart                                                 |
| Media Storage      | Cloudinary (accessed via Dart HTTP client)                                        |
| Authentication     | Firebase Auth                                                                      |
| Authorization      | JWT-based with Role-Based Access Control (RBAC)                                   |

---

## 3. Functional Requirements

### 3.1 User Authentication

**FR-001:** The system shall provide sign up and login functionality for:
- Users (via mobile/email)
- Doctors (via email/password)
- Hospital Admins (via email + client ID)

**FR-002:** The system shall implement Firebase authentication for secure user management

**FR-003:** The system shall use JWT-based token handling for session management

**FR-004:** The system shall implement role-based access controls (RBAC)

**FR-005:** The system shall provide logout and session management functionality

### 3.2 AI Chat Integration

**FR-006:** The system shall integrate with Google Gemini API for AI-powered health assistance

**FR-007:** The system shall provide real-time health Q&A functionality

**FR-008:** The system shall display message bubbles with different styling for AI, Doctor, and User messages

**FR-009:** The system shall implement a Flutter widget with scrollable and responsive chat interface

**FR-010:** The system shall provide Dart backend routes for AI response handling

### 3.3 Appointment Booking System

**FR-011:** The system shall allow users to book doctor appointments in 5-minute time slots

**FR-012:** The system shall display live slot availability in real-time

**FR-013:** The system shall implement first-come, first-serve booking logic

**FR-014:** The system shall manage slot allocation through Dart backend logic

**FR-015:** The system shall send confirmation emails post-booking using mailer package

### 3.4 Doctor Module

**FR-016:** The system shall provide doctor login and dashboard functionality

**FR-017:** The system shall allow doctors to mark their status (available/unavailable)

**FR-018:** The system shall display appointment schedules for doctors

**FR-019:** The system shall provide placeholder functionality for prescription writing (future enhancement)

### 3.5 Hospital Admin Panel

**FR-020:** The system shall allow hospital admins to view and manage bookings

**FR-021:** The system shall provide functionality to accept/reject appointment requests

**FR-022:** The system shall display all submitted forms to hospital admins

**FR-023:** The system shall allow manual confirmation of payment transaction IDs

**FR-024:** The system shall implement Flutter-based admin UI with tables, status tags, and modals

### 3.6 User Forms & Profile

**FR-025:** The system shall provide structured user forms including:
- Personal Information
- Symptoms
- Preferred Date/Time

**FR-026:** The system shall implement conditional input rendering based on user selections

**FR-027:** The system shall use Flutter layout with grouped cards for form organization

### 3.7 Multilingual Support

**FR-028:** The system shall provide language switcher for English and Nepali

**FR-029:** The system shall implement string localization using flutter_localizations

**FR-030:** The system shall store language preferences locally on the device

### 3.8 Email Notification

**FR-031:** The system shall send confirmation emails post-booking

**FR-032:** The system shall include doctor, hospital, time, and message details in confirmation emails

**FR-033:** The system shall trigger emails via Dart backend /send-confirmation endpoint

### 3.9 Doctor & Hospital Search

**FR-034:** The system shall allow users to search doctors by:
- Name
- Specialization
- Availability
- Gender
- Language

**FR-035:** The system shall provide Dart backend filtering support for search functionality

### 3.10 Lab Test Module

**FR-036:** The system shall allow users to book lab test packages

**FR-037:** The system shall display detailed test information

**FR-038:** The system shall support upload/download of reports via Cloudinary

**FR-039:** The system shall provide admin interface for uploading lab reports

### 3.11 Wellness Tab

**FR-040:** The system shall display health tips, articles, and videos

**FR-041:** The system shall implement Flutter card-based layout for wellness content

**FR-042:** The system shall provide admin backend to manage wellness content

### 3.12 Branding & UI

**FR-043:** The system shall display logo in the app bar

**FR-044:** The system shall support favicon for web deployment

**FR-045:** The system shall provide light/dark theme support

**FR-046:** The system shall implement brand color and font configuration

**FR-047:** The system shall provide responsive UI across devices (mobile, tablet, desktop)

---

## 4. Non-Functional Requirements

### 4.1 Performance

**NFR-001:** The system must handle concurrent bookings without conflicts

**NFR-002:** AI chat response time must be less than 2 seconds

**NFR-003:** The system shall support minimum 100 concurrent users

### 4.2 Security

**NFR-004:** The system shall implement Firebase authentication for secure access

**NFR-005:** The system shall validate all input data to prevent injection attacks

**NFR-006:** The system shall encrypt all passwords and sensitive data

**NFR-007:** The system shall implement secure API endpoints with proper authentication

### 4.3 Usability

**NFR-008:** The system shall provide smooth navigation between screens

**NFR-009:** The system shall implement intuitive language toggle functionality

**NFR-010:** The system shall support offline caching for basic functionality (optional)

**NFR-011:** The system shall be accessible and user-friendly for all age groups

### 4.4 Maintainability

**NFR-012:** The system shall implement modular codebase architecture

**NFR-013:** The system shall use config-driven endpoints for easy maintenance

**NFR-014:** The system shall provide scalable backend APIs

**NFR-015:** The system shall include comprehensive documentation and code comments

### 4.5 Compatibility

**NFR-016:** The system shall support Android and iOS platforms

**NFR-017:** The system shall support web deployment

**NFR-018:** The system shall be compatible with modern browsers

---

## 5. System Constraints

### 5.1 Technical Constraints

- Frontend must be developed using Flutter framework
- Backend must be implemented using Dart
- Database must be MySQL
- AI integration must use Google Gemini API
- Authentication must use Firebase Auth

### 5.2 Business Constraints

- Must support English and Nepali languages
- Must comply with healthcare data privacy regulations
- Must provide email confirmation for all bookings

---

## 6. Future Enhancements

**FE-001:** Doctor prescription management system

**FE-002:** Integrated payment gateway

**FE-003:** Offline health tracker functionality

**FE-004:** Push notifications for appointments and reminders

**FE-005:** AI-generated health reports and insights

**FE-006:** Telemedicine video consultation feature

**FE-007:** Integration with wearable devices

**FE-008:** Advanced analytics and reporting dashboard

---

## 7. Acceptance Criteria

### 7.1 User Acceptance

- Users can successfully register, login, and book appointments
- AI chat provides relevant health information
- Email confirmations are received for all bookings
- Language switching works seamlessly
- All forms are intuitive and easy to complete

### 7.2 Technical Acceptance

- System handles concurrent users without performance degradation
- All security requirements are met
- Responsive design works across all target devices
- Integration with external APIs (Gemini, Cloudinary) functions correctly

---

## 8. Glossary

**Appointment Slot:** A 5-minute time period available for booking with a doctor

**Gemini API:** Google's AI service for natural language processing

**Cloudinary:** Cloud-based media management service

**Flutter:** Google's UI toolkit for building cross-platform applications

**RBAC:** Role-Based Access Control system for managing user permissions

---

**Document Control:**
- **Author:** Development Team
- **Reviewed By:** Project Manager
- **Approved By:** Stakeholders
- **Last Modified:** December 2024
