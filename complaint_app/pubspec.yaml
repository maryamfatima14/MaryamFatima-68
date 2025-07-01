-- Create users table for University Complaint App
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    full_name VARCHAR(255),
    email VARCHAR(255),
    department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add department_id column if it doesn't exist (for existing databases)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'department_id') THEN
        ALTER TABLE users ADD COLUMN department_id UUID REFERENCES departments(id) ON DELETE SET NULL;
    END IF;
END $$;

-- Add full_name column if it doesn't exist (for existing databases)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'full_name') THEN
        ALTER TABLE users ADD COLUMN full_name VARCHAR(255);
    END IF;
END $$;

-- Add email column if it doesn't exist (for existing databases)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'email') THEN
        ALTER TABLE users ADD COLUMN email VARCHAR(255);
    END IF;
END $$;

-- Create index for department_id
CREATE INDEX IF NOT EXISTS idx_users_department_id ON users(department_id);

-- Drop existing role constraint if it exists
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;

-- Add the new role constraint
ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN ('Admin', 'HOD', 'BatchAdvisor', 'Student', 'CR', 'GR'));

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Allow all operations on users" ON users;

-- Create policy to allow all operations for now (you can restrict this later)
CREATE POLICY "Allow all operations on users" ON users
    FOR ALL USING (true);

-- Optional: Insert some sample users for testing
-- INSERT INTO users (username, password, role) VALUES
--     ('batchadvisor1@university.com', 'batchadvisor123', 'BatchAdvisor'),
--     ('hod1@university.com', 'hod123', 'HOD'),
--     ('student1@university.com', 'student123', 'Student');

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop existing trigger to avoid conflicts
DROP TRIGGER IF EXISTS update_users_updated_at ON users;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create complaints table
CREATE TABLE IF NOT EXISTS complaints (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES users(id) ON DELETE SET NULL, -- SET NULL to keep complaint if student is deleted
    student_tracking_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Always stores student ID for tracking anonymous complaints
    recipient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    complaint_text TEXT NOT NULL,
    image_url TEXT,
    is_anonymous BOOLEAN NOT NULL DEFAULT false,
    status VARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'In Progress', 'Resolved', 'Rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS) for the complaints table
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;

-- Drop existing complaint policies to avoid conflicts
DROP POLICY IF EXISTS "Allow students to view their own complaints" ON complaints;
DROP POLICY IF EXISTS "Allow students to insert complaints" ON complaints;
DROP POLICY IF EXISTS "Allow public access to complaints" ON complaints;

-- Create policy: Allow public access for now since we're using custom authentication
CREATE POLICY "Allow public access to complaints"
ON complaints FOR ALL
TO public
USING (true)
WITH CHECK (true);

-- Create storage bucket for complaint images (Run this only if you haven't created it via the UI)
-- Note: You'll need to set up bucket policies in the Supabase Dashboard for full access control.
-- For now, let's create a public bucket for simplicity, but for production you'd want more secure policies.
INSERT INTO storage.buckets (id, name, public)
VALUES ('complaint_images', 'complaint_images', true)
ON CONFLICT (id) DO NOTHING;

-- Drop existing policies first to avoid conflicts
DROP POLICY IF EXISTS "Allow authenticated view access" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated insert access" ON storage.objects;
DROP POLICY IF EXISTS "Allow public view access" ON storage.objects;
DROP POLICY IF EXISTS "Allow public insert access" ON storage.objects;

-- Create policies for storage bucket
-- Allow public access for now since we're using custom authentication
CREATE POLICY "Allow public view access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'complaint_images');

-- Allow public upload access for now
CREATE POLICY "Allow public insert access"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'complaint_images');

-- Create complaint_comments table for batch advisor-student communication
CREATE TABLE IF NOT EXISTS complaint_comments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    complaint_id UUID NOT NULL REFERENCES complaints(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES users(id) ON DELETE SET NULL,
    batch_advisor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    student_id UUID REFERENCES users(id) ON DELETE SET NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS) for the complaint_comments table
ALTER TABLE complaint_comments ENABLE ROW LEVEL SECURITY;

-- Drop existing comment policies to avoid conflicts
DROP POLICY IF EXISTS "Allow public access to complaint_comments" ON complaint_comments;

-- Create policy: Allow public access for now since we're using custom authentication
CREATE POLICY "Allow public access to complaint_comments"
ON complaint_comments FOR ALL
TO public
USING (true)
WITH CHECK (true);

-- Update existing teacher users to batch advisors
UPDATE users 
SET role = 'BatchAdvisor' 
WHERE role = 'Teacher';

-- Migrate existing comments to the new column name (if comment column exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'complaint_comments' AND column_name = 'comment') THEN
        UPDATE complaint_comments 
        SET comment_text = comment 
        WHERE comment_text IS NULL AND comment IS NOT NULL;
    END IF;
END $$;

-- Create CR_GR_assignments table to track CR/GR assignments
CREATE TABLE IF NOT EXISTS cr_gr_assignments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    department_id UUID REFERENCES departments(id) ON DELETE CASCADE,
    batch_id UUID REFERENCES batches(id) ON DELETE CASCADE,
    assignment_type VARCHAR(10) NOT NULL CHECK (assignment_type IN ('CR', 'GR')),
    assigned_by UUID REFERENCES users(id) ON DELETE SET NULL, -- Batch Advisor who assigned
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_cr_gr_user_id ON cr_gr_assignments(user_id);
CREATE INDEX IF NOT EXISTS idx_cr_gr_department_id ON cr_gr_assignments(department_id);
CREATE INDEX IF NOT EXISTS idx_cr_gr_batch_id ON cr_gr_assignments(batch_id);
CREATE INDEX IF NOT EXISTS idx_cr_gr_type ON cr_gr_assignments(assignment_type);

-- Enable Row Level Security (RLS) for cr_gr_assignments
ALTER TABLE cr_gr_assignments ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations for now
CREATE POLICY "Allow public access to cr_gr_assignments"
ON cr_gr_assignments FOR ALL
TO public
USING (true)
WITH CHECK (true); 
