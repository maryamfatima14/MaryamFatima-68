## 📌 Project Scope

The **Smart Complaint Management System** is a role-based web and mobile application designed for the Computer Science Department to simplify the student complaint process. It facilitates students in submitting complaints, allows batch advisors to manage or escalate them, and enables HODs to take final decisions. Admins have control over departments, users, and batch mappings via Excel uploads.

This system improves transparency and accountability in complaint resolution by providing real-time tracking, structured escalation flow, and activity timelines.

--

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
- CR/GR portal with complaint management

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
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/bb6bcc3a-d1b3-45e8-a5b8-42f0e669ac4b" width="200"/>
  <img src="https://github.com/user-attachments/assets/0f838a05-5867-482d-8cad-a6aeb3669664" width="200"/>
</p>

✨ These connections ensure:
- 🔐 **Secure authentication** with Supabase Auth
- 📡 **Real-time sync** using Supabase Realtime
- 🗃️ Easy table and role management via Supabase Studio
- ⚙️ Integration with Flutter frontend for seamless user experience

🛠️ Admin Dashboard
<p align="center"> <img src="https://github.com/user-attachments/assets/228a267f-c7b8-41ab-befd-7f84dcc9e079" width="200"/> <img src="https://github.com/user-attachments/assets/3996cbe4-bec5-42da-b4a9-7160546df6cd" width="200"/> <img src="https://github.com/user-attachments/assets/d8ece1b6-8087-4373-9a93-1319388900b8" width="200"/> <img src="https://github.com/user-attachments/assets/7bec4b23-05b0-4ade-9d36-7f2909891512" width="200"/> </p> <p align="center"> <img src="https://github.com/user-attachments/assets/a198b7c4-54ec-49e3-9ec2-e3fc947e0f20" width="200"/> <img src="https://github.com/user-attachments/assets/47311992-b938-4c6c-8be8-9188a31d291a" width="200"/> <img src="https://github.com/user-attachments/assets/79632c1f-35d9-4277-9d43-250e7b2f749d" width="200"/> <img src="https://github.com/user-attachments/assets/3cf71a0d-ba34-4736-91e5-c2b0573b5b3d" width="200"/> </p>
🧑‍🏫 HOD Dashboard
<p align="center"> <img src="https://github.com/user-attachments/assets/ea25324d-c7ef-4146-aa78-d7b7d8c3a87d" width="200"/> <img src="https://github.com/user-attachments/assets/693d394f-9c2e-48e0-82ce-4d3ff45b7637" width="200"/> <img src="https://github.com/user-attachments/assets/a95c1fc6-560a-4d64-858c-73392a360aef" width="200"/> <img src="https://github.com/user-attachments/assets/8c01531b-21c1-4836-b637-141fcb5ccee9" width="200"/> </p> <p align="center"> <img src="https://github.com/user-attachments/assets/e0802320-cd57-49cb-a00f-d1fb9f61a8b7" width="200"/> <img src="https://github.com/user-attachments/assets/275b1d87-37be-42d2-8ac5-76be0edfd7dc" width="200"/> <img src="https://github.com/user-attachments/assets/356740e1-01a3-4e2f-87b8-89559dd74c75" width="200"/> <img src="https://github.com/user-attachments/assets/b3f73a45-8a63-4475-8845-463113ad39bb" width="200"/> </p>
👨‍🏫 CR / GR Dashboard
<p align="center"> <img src="https://github.com/user-attachments/assets/49e50f1f-e5a5-408e-9e82-cb5cf153867e" width="200"/> <img src="https://github.com/user-attachments/assets/87f33c3e-1a87-4530-94e7-929a0024e969" width="200"/> <img src="https://github.com/user-attachments/assets/e9f74408-9319-451d-8b83-028793893c9e" width="200"/> <img src="https://github.com/user-attachments/assets/7e69c5d8-62e8-451a-9d39-ed81504d0b23" width="200"/> </p> <p align="center"> <img src="https://github.com/user-attachments/assets/f8b75ebe-299f-4192-9ce8-843017c2c112" width="200"/> <img src="https://github.com/user-attachments/assets/57ad29ff-44a9-48c1-86de-684c1047fb64" width="200"/> <img src="https://github.com/user-attachments/assets/eae99576-1213-47a4-935b-23fa3dc4cad7" width="200"/> <img src="https://github.com/user-attachments/assets/2737e89a-534e-47f8-a83e-73de10ef6b39" width="200"/> </p>
👩‍🎓 Student Dashboard
<p align="center"> <img src="https://github.com/user-attachments/assets/3f38b6be-52f0-48b9-a858-3c3af0e29c1b" width="200"/> <img src="https://github.com/user-attachments/assets/130fd954-c30e-4acf-8f7a-e2fb108116c6" width="200"/> <img src="https://github.com/user-attachments/assets/feea8fb3-2a9f-43d9-aa92-adb9d76f2d7d" width="200"/> <img src="https://github.com/user-attachments/assets/e404a50b-7a1e-4b68-92b7-d95f17c5094d" width="200"/> </p> <p align="center"> <img src="https://github.com/user-attachments/assets/5d1484a5-7f69-434e-9d47-07427e566354" width="200"/> <img src="https://github.com/user-attachments/assets/1764121e-74e2-4623-87f6-af4bd5481b2f" width="200"/> <img src="https://github.com/user-attachments/assets/3c75eaef-14e2-4756-b773-7948d7d26894" width="200"/> <img src="https://github.com/user-attachments/assets/3c46d9a0-ceec-4389-9098-52d347094d29" width="200"/> </p> <p align="center"> <img src="https://github.com/user-attachments/assets/bd3ed08f-dfe6-4e07-8d77-06562d5b66a8" width="200"/> </p>

Demo Vedio:

https://drive.google.com/file/d/14Aqme47_HaQQLWrUoP1OltAptJGojSH5/view?usp=sharing
