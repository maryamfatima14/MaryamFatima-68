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


## 🛠️ Database Connectivity (Supabase Integration)

This project uses **Supabase** to handle real-time, secure, and scalable backend operations. The following screenshots demonstrate how the database is connected and configured with the application:

<p align="center">
  <img src="https://github.com/user-attachments/assets/03f15364-71b2-4fbf-a73c-8d50b19eac8e" width="200"/>
  <img src="https://github.com/user-attachments/assets/1324b9d5-07b0-492f-adcf-ac4ab685d9f6" width="200"/>
  <img src="https://github.com/user-attachments/assets/736b057f-7f30-4907-b60f-a11dd72de8e1" width="200"/>
  <img src="https://github.com/user-attachments/assets/bb6bcc3a-d1b3-45e8-a5b8-42f0e669ac4b" width="200"/>
</p>

✨ These connections ensure:
- 🔐 **Secure authentication** with Supabase Auth
- 📡 **Real-time sync** using Supabase Realtime
- 🗃️ Easy table and role management via Supabase Studio
- ⚙️ Integration with Flutter frontend for seamless user experience



## 📊 Admin Dashboard

<p align="center">
  <img src="https://github.com/user-attachments/assets/faad65ce-9587-44cd-9dd0-92554a430256" width="200"/>
  <img src="https://github.com/user-attachments/assets/1fc120c4-35a2-41fa-8092-f1ea54cb1c5f" width="200"/>
  <img src="https://github.com/user-attachments/assets/6ad47e77-2ed7-44ec-b38e-09cf82fe8695" width="200"/>
  <img src="https://github.com/user-attachments/assets/c82ed85e-fd7d-4b3d-8b12-81b113240f66" width="200"/>
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/9f608adf-6fb6-4ea8-bf26-656336b58cc2" width="200"/>
  <img src="https://github.com/user-attachments/assets/d7158b63-d949-4699-9ae6-d91cd96e15b8" width="200"/>
  <img src="https://github.com/user-attachments/assets/cf52bf49-36ad-49f5-bb24-0f3bdbea91fa" width="200"/>
  <img src="https://github.com/user-attachments/assets/58a98e62-ecda-48ae-85db-d6cf09213ce6" width="200"/>
</p>

## 🧑‍🏫 HOD Dashboard

<p align="center">
  <img src="https://github.com/user-attachments/assets/fcf7607b-164d-4bbc-b152-7a6bb521a0a3" width="200"/>
  <img src="https://github.com/user-attachments/assets/28adf2f5-4a58-44ab-9107-26b2525bdf1f" width="200"/>
  <img src="https://github.com/user-attachments/assets/190c7530-ce2b-4d0c-94f9-24de73d35856" width="200"/>
  <img src="https://github.com/user-attachments/assets/e563fe92-e87a-4708-9f35-fdc49cdef40f" width="200"/>
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/bc0b25cb-d6c7-49d6-b53c-44f9aa71147c" width="200"/>
  <img src="https://github.com/user-attachments/assets/9cff074a-573d-40c3-94e8-cf0e7a517dcb" width="200"/>
  <img src="https://github.com/user-attachments/assets/dd1d56e5-5ee0-4a4c-8ac2-b635e6c2d05e" width="200"/>
  <img src="https://github.com/user-attachments/assets/b68abc8d-fb1b-4cb7-b642-c25d4f912b5e" width="200"/>
</p>

## 👨‍🏫 Batch Advisor Dashboard

<p align="center">
  <img src="https://github.com/user-attachments/assets/5c0384cb-c1a0-456a-9f78-2acc0c9a2b8c" width="200"/>
  <img src="https://github.com/user-attachments/assets/d56b0ed4-9121-4390-aa30-386fe8d62cf2" width="200"/>
  <img src="https://github.com/user-attachments/assets/e459ab7e-a854-4eac-8c1e-c51620eb963d" width="200"/>
  <img src="https://github.com/user-attachments/assets/ec689a8e-4733-46be-9ed4-3c0ec80e68de" width="200"/>
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/c2433ae8-3326-4809-a58a-48ee65c42d95" width="200"/>
  <img src="https://github.com/user-attachments/assets/8972bc85-127f-4455-b786-9bd268b3c28d" width="200"/>
  <img src="https://github.com/user-attachments/assets/566c32fe-bcc4-43ad-97ca-ed0bc336a047" width="200"/>
  <img src="https://github.com/user-attachments/assets/524e536d-4eab-432d-b511-b82adc3029d4" width="200"/>
</p>

## 👩‍🎓 Student Dashboard

<p align="center">
  <img src="https://github.com/user-attachments/assets/7373cb17-9b01-427d-9bac-8e6f3947fde7" width="200"/>
  <img src="https://github.com/user-attachments/assets/ddca7253-12ad-4f36-9320-b517244c2575" width="200"/>
  <img src="https://github.com/user-attachments/assets/af035bbf-75a0-49fc-baff-486134fa5a2a" width="200"/>
  <img src="https://github.com/user-attachments/assets/89fdefbc-ef2c-47ec-8d22-c80c95c6a33d" width="200"/>
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/46af603b-0898-4889-8c78-14890b509786" width="200"/>
  <img src="https://github.com/user-attachments/assets/e9a18044-40c8-4711-a30e-040cb0c51fa6" width="200"/>
  <img src="https://github.com/user-attachments/assets/9091d285-a79c-4597-9b4b-06a08e7f0fea" width="200"/>
  <img src="https://github.com/user-attachments/assets/ab5c8331-0d82-48a6-97c9-1c65475e66fb" width="200"/>
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/c7af9144-f023-4c52-93dd-3d2e5cf9375c" width="200"/>
</p>

