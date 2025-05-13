Real-time Student Task Tracker App with Supabase

1. Project Overview
1.1 Objective
To develop a real-time task management system using Supabase where:

Teachers (Admin) can manage students, assign tasks, and track progress.

Students can view their assigned tasks, update status, and monitor their performance.

1.2 Technology Stack
Component	Technology
Frontend	Flutter (Cross-platform)
Backend	Supabase (PostgreSQL + Realtime)
Excel Import	Manual entry or CSV upload (Supabase Storage)
Charts	fl_chart (Flutter)
Hosting	Supabase (Free Tier)

2. Features
2.1 Core Features
Admin (Teacher) Panel
User Management

Add/Edit/Delete students manually

Bulk upload students via CSV (optional)

Generate & manage student credentials

Task Management

Assign tasks to individual/group of students

Set due dates and task descriptions

View all assigned tasks

Reports & Analytics

View student-wise task completion reports

Performance graphs (Bar/Line charts)

Leaderboard (Top-performing students)

Admin Dashboard

Total students count

Tasks assigned today

Pending vs. completed tasks overview

Student Panel
Task Management

View assigned tasks

Mark tasks as completed

Filter tasks (Pending/Completed)

Performance Tracking

Personal progress graph

Task completion streaks (Gamification)

Student Dashboard

Profile details

Task calendar (Optional)

3. Database Structure (Supabase PostgreSQL)
3.1 Tables
users Table (Admins & Students)
sql
Copy
Edit
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
tasks Table
sql
Copy
Edit
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  assigned_to UUID REFERENCES users(id),
  status TEXT CHECK (status IN ('pending', 'completed')),
  due_date TIMESTAMPTZ,
  created_by UUID REFERENCES users(id)
);
reports Table (Optional)
sql
Copy
Edit
CREATE TABLE reports (
  student_id UUID REFERENCES users(id),
  completed_tasks INT DEFAULT 0,
  pending_tasks INT DEFAULT 0,
  performance_score FLOAT
);
4. System Architecture
Figure 1: System Architecture Diagram (Add image here if available)

4.1 Supabase API Endpoints (Sample)
Feature	Supabase Method
Fetch Tasks	supabase.from('tasks').select()
Mark Task Complete	supabase.from('tasks').update()
Bulk Add Students	supabase.from('users').insert()
Realtime Updates	supabase.channel('tasks')

5. Development Roadmap
Phase 1: Core Features

Supabase setup (PostgreSQL, Realtime)

Basic task assignment & completion

Phase 2: Analytics & Reporting

Performance graphs

Realtime leaderboard

Phase 3: Advanced Features (Optional)

In-app messaging (Supabase Realtime)

Email automation (Supabase Edge Functions)

6. Deliverables
Admin App (Flutter) – For managing students & tasks.

Student App (Flutter) – For task tracking & progress.

Supabase Backend – Handles database and realtime updates.

7. Why Supabase?
PostgreSQL Database – Full SQL support, unlike MongoDB.

Realtime Updates – No need for WebSockets.

Free Tier – Good for small to medium projects.

8. Risks & Mitigation
Risk	Mitigation
Row-level security issues	Enable RLS in Supabase
Realtime sync delays	Optimize subscriptions
CSV import complexity	Use manual entry or Supabase Storage

9. Conclusion
This Student Task Tracker with Supabase provides a real-time, scalable, and secure solution for teachers and students to efficiently manage and monitor academic tasks
