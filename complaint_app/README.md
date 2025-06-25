## 📌 Project Scope

The **Smart Complaint Management System** is a role-based web and mobile application designed for the Computer Science Department to simplify the student complaint process. It facilitates students in submitting complaints, allows batch advisors to manage or escalate them, and enables HODs to take final decisions. Admins have control over departments, users, and batch mappings via Excel uploads.

This system improves transparency and accountability in complaint resolution by providing real-time tracking, structured escalation flow, and activity timelines.

---

## 🔐 Supabase Integration

This project uses **Supabase** as the backend-as-a-service (BaaS) platform for:

- **Authentication**: Secure email/password login with role-based access
- **Database**: PostgreSQL with Supabase Realtime for live updates
- **Row-Level Security (RLS)**: Ensures users can only access their own data
- **Storage** (optional): Google Drive links are used for media, but Supabase storage can be integrated for file uploads
- **APIs**: Auto-generated RESTful APIs for interacting with tables

---

## 🚀 Key Features

- Student complaint submission with title, description, and media (Google Drive links)
- Complaint status tracking: *Submitted → In Progress → Escalated → Resolved/Rejected*
- Timeline view with comment and status logs
- Role-specific dashboards for Admin, Student, Batch Advisor, and HOD
- Batch-wise complaint filtering for advisors and HODs
- Excel upload feature for bulk student and batch data management
- Real-time notifications on status and handler changes

---

## ✅ Functional Requirements

- User login/signup with role-based routing
- Complaint lifecycle management:
  - Submit complaint
  - Add/view comments
  - Escalate complaint
  - Mark as resolved/rejected
- Filter/search functionality in dashboards
- Admin management of:
  - Departments
  - Batches
  - Batch advisors
  - HOD accounts
- View complaint history, timeline, and status logs

---

## ❌ Non-Functional Requirements

- Smooth and responsive UI using Flutter
- Real-time data sync via Supabase Realtime
- Secure data access using RLS policies
- Scalable architecture for multiple departments
- Modular and maintainable code structure
- Excel data parsing with validation for bulk upload

---

## 🛠️ Tech Stack

| Component        | Technology             |
|------------------|-------------------------|
| Frontend         | Flutter (Dart)          |
| Backend (BaaS)   | Supabase                |
| Auth             | Supabase Auth           |
| DB               | Supabase PostgreSQL     |
| Realtime         | Supabase Realtime       |
| File Storage     | Google Drive (linked)   |
| Excel Upload     | Flutter CSV/XLSX Parser |

---

## 🗂️ Example Supabase Tables

### 🔸 users

| id | name      | email             | role         | batch_id | department_id |
|----|-----------|------------------|--------------|----------|----------------|
| 1  | Ali Raza  | ali@cs.edu       | student      | 2        | 1              |
| 2  | Ms. Ayesha| ayesha@cs.edu    | batch_advisor| 2        | 1              |

---

### 🔸 complaints

| id | title        | description       | status     | student_id | handler_id | escalated_to | created_at |
|----|--------------|-------------------|------------|------------|-------------|---------------|-------------|
| 1  | Lab Issue    | PC not working    | escalated  | 1          | 2           | 5             | 2024-12-01  |

---

### 🔸 comments

| id | complaint_id | comment_by | role     | message                  | timestamp           |
|----|--------------|------------|----------|--------------------------|---------------------|
| 1  | 1            | 2          | advisor  | Issue verified, escalating | 2024-12-02 10:30AM  |

---

### 🔸 batches

| id | name    | advisor_id | department_id |
|----|---------|-------------|----------------|
| 2  | CS-2022 | 2           | 1              |

---

### 🔸 departments

| id | name        |
|----|-------------|
| 1  | CS          |

---

## ⚠️ System Scope & Boundaries

- 🚫 No cross-department complaint support (future enhancement)
- 📄 Excel upload required to bulk add students and batches

