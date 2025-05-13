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

<div align="center" style="display: flex; justify-content: center; gap: 30px; flex-wrap: wrap;">

  <div style="margin: 10px;">
    <h4 align="center">Supabase Table Structure</h4>
    <img src="https://github.com/user-attachments/assets/ad0f0452-b73d-4466-95ea-07a1fb19adbe" width="250px"/>
  </div>

  <div style="margin: 10px;">
    <h4 align="center">Realtime Channel</h4>
    <img src="https://github.com/user-attachments/assets/32de9fb2-e9b2-4459-aa87-0828bb143680" width="250px"/>
  </div>

  <div style="margin: 10px;">
    <h4 align="center">Task Update API</h4>
    <img src="https://github.com/user-attachments/assets/e8966b30-da42-470c-baef-857ad05db8ec" width="250px"/>
  </div>

  <div style="margin: 10px;">
    <h4 align="center">User Insertion API</h4>
    <img src="https://github.com/user-attachments/assets/3a0c0e41-afdd-49d1-aaaf-501b4227ddd7" width="250px"/>
  </div>

</div>

