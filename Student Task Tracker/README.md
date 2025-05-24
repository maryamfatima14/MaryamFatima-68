📚 Real-time Student Task Tracker App with Supabase

## 📌 1. Project Overview

### 🎯 1.1 Objective
To develop a real-time task management system using **Supabase** where:

- **Teachers (Admins)** can manage students, assign tasks, and track progress.
- **Students** can view their assigned tasks, update status, and monitor their performance.

### 🛠️ 1.2 Technology Stack

| Component     | Technology                          |
|--------------|-------------------------------------|
| Frontend     | Flutter (Cross-platform)            |
| Backend      | Supabase (PostgreSQL + Realtime)    |
| Excel Import | Manual Entry / CSV Upload           |
| Charts       | `fl_chart` (Flutter)                |
| Hosting      | Supabase (Free Tier)                |

---

## ✨ 2. Features

### 👩‍🏫 Admin (Teacher) Panel

**User Management**
- Add/Edit/Delete students manually
- Bulk upload students via CSV (optional)
- Generate & manage student credentials

**Task Management**
- Assign tasks to individual/group of students
- Set due dates and task descriptions
- View all assigned tasks

**Reports & Analytics**
- View student-wise task completion reports
- Performance graphs (Bar/Line charts)
- Leaderboard (Top-performing students)

**Admin Dashboard**
- Total students count
- Tasks assigned today
- Pending vs. completed tasks overview

### 👨‍🎓 Student Panel

**Task Management**
- View assigned tasks
- Mark tasks as completed
- Filter tasks (Pending/Completed)

**Performance Tracking**
- Personal progress graph
- Task completion streaks (Gamification)

**Student Dashboard**
- Profile details
- Task calendar (optional)

---

## 🗃️ 3. Database Structure (Supabase PostgreSQL)

### 🧑‍💻 `users` Table (Admins & Students)
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
````

### ✅ `tasks` Table

```sql
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  assigned_to UUID REFERENCES users(id),
  status TEXT CHECK (status IN ('pending', 'completed')),
  due_date TIMESTAMPTZ,
  created_by UUID REFERENCES users(id)
);
```

### 📊 `reports` Table (Optional)

```sql
CREATE TABLE reports (
  student_id UUID REFERENCES users(id),
  completed_tasks INT DEFAULT 0,
  pending_tasks INT DEFAULT 0,
  performance_score FLOAT
);
```

---

## 🧩 4. System Architecture

> *Insert your architecture diagram here if available as an image (e.g., `![Architecture](assets/architecture.png)`)*

### ⚙️ 4.1 Supabase API Endpoints (Sample)

| Feature            | Supabase Method                   |
| ------------------ | --------------------------------- |
| Fetch Tasks        | `supabase.from('tasks').select()` |
| Mark Task Complete | `supabase.from('tasks').update()` |
| Bulk Add Students  | `supabase.from('users').insert()` |
| Realtime Updates   | `supabase.channel('tasks')`       |

---

## 🚧 5. Development Roadmap

### Phase 1: Core Features

* Supabase setup (PostgreSQL, Realtime)
* Basic task assignment & completion

### Phase 2: Analytics & Reporting

* Performance graphs
* Realtime leaderboard

### Phase 3: Advanced Features (Optional)

* In-app messaging (Supabase Realtime)
* Email automation (Supabase Edge Functions)

---

## 📦 6. Deliverables

* **Admin App (Flutter)** – For managing students & tasks
* **Student App (Flutter)** – For task tracking & progress
* **Supabase Backend** – Handles database and realtime updates

---

## 🚀 7. Why Supabase?

* ✅ Full SQL support with PostgreSQL (unlike NoSQL)
* 🔄 Built-in Realtime features without WebSockets
* 💸 Free Tier available for small to medium projects

---

## ⚠️ 8. Risks & Mitigation

| Risk                      | Mitigation                           |
| ------------------------- | ------------------------------------ |
| Row-level security issues | Enable RLS in Supabase               |
| Realtime sync delays      | Optimize channel subscriptions       |
| CSV import complexity     | Use manual entry or Supabase Storage |

---

## ✅ 9. Conclusion

The **Student Task Tracker App** powered by **Supabase** offers a real-time, scalable, and secure solution for classroom task management—boosting transparency and student accountability with ease.



## 📡 Backend Connectivity

<table>
  <tr>
    <th>Supabase Table Structure</th>
    <th>Realtime Channel</th>
    <th>Task Update API</th>
    <th>User Insertion API</th>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/ad0f0452-b73d-4466-95ea-07a1fb19adbe" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/32de9fb2-e9b2-4459-aa87-0828bb143680" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/e8966b30-da42-470c-baef-857ad05db8ec" width="250"/></td>
    <td><img src="https://github.com/user-attachments/assets/3a0c0e41-afdd-49d1-aaaf-501b4227ddd7" width="250"/></td>
  </tr>
</table>

📱 App Visuals

## 👩‍🏫 Admin Portal

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/f58884e4-f1c2-4109-a5ce-479ea7439cbe" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/bba75894-029c-42b8-828d-e893b886f4dd" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/8b94ba17-2a5c-475a-be1f-114a0021de9e" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/5518c254-a95a-497e-9ae2-dc6f0e05ebf3" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/b5083f59-1153-4a6a-85ec-8ae376419caa" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/ddb736f8-1ca3-41e1-989a-b5c804926f35" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/6643c1ec-5b90-48f7-b59c-8a5e90588499" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/67c01bb9-76b0-4f80-a85f-2db0089a09a3" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/fcc5741e-d792-4806-81e3-b26ff01c98d5" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/92b12f0e-3050-4b3d-aaa4-40bf77a07be8" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/1fbb7935-8adf-4d7b-bd7c-edb22d2109eb" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/6307147c-1af0-428c-b426-37e06e86abec" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/b89455cb-2a00-4e27-a722-03a61112a872" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/bee52455-1f70-4611-8273-1c14803ac1a7" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/9f02887b-bb81-446f-a234-ae84c847e9b7" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/876bd448-d80d-4732-9a91-7b58e928b5e2" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/f04ed63f-e434-426a-84eb-308104f04099" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/051142c6-3dc3-4d69-bbff-62344fbda522" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/3318bc87-3c60-4c60-ac3d-f4d14655a32d" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/0a6ec3f8-3967-41bb-a887-2c3f27f60717" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/855ab76b-0c59-4020-b157-2d083bd8b289" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/d1cf9c41-e992-4b11-9d0c-448cb92799a0" width="200"/></td>
  </tr>
</table>

## 👨‍🎓 Student Portal

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/b4b2b878-74d3-48c6-967f-29e787b8f523" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/4a63e279-2778-400b-aa26-12408612f630" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/d19cfd4d-558c-4153-9245-1902191a431a" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/92692d4e-07e2-4850-84cc-9a3b400cb365" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/65f98e59-b188-4442-aead-5c5f22163c6d" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/1389754c-2509-433c-9a06-c170eabb0c42" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/2e67d320-0ad4-42d3-8629-89b1fb9085ad" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/6f26ff29-a805-4650-856f-09a9644cc1cc" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/b49e8069-9494-464a-b229-fae721234dbd" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/713ae403-8ef3-4207-b468-32cacca67675" width="200"/></td>
    <td><img src="https://github.com/user-attachments/assets/a96a7a75-5017-41ec-a94a-e27a1538a9af" width="200"/></td>
  </tr>
</table>






