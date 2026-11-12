-- PaperWise Database Schema for Neon Postgres
-- Firebase columns (firebase_uid, auth_provider) are excluded as they are not used

-- Drop tables if they exist (for clean setup)
DROP TABLE IF EXISTS difficulty_votes CASCADE;
DROP TABLE IF EXISTS votes CASCADE;
DROP TABLE IF EXISTS paper_requests CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS papers CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Users table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'student')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for users table
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- Papers table
CREATE TABLE papers (
    paper_id SERIAL PRIMARY KEY,
    subject_name VARCHAR(150) NOT NULL,
    subject_code VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    chapter VARCHAR(100),
    file_url TEXT NOT NULL,
    uploaded_by INTEGER NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    exam_type VARCHAR(50),
    description TEXT,
    FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create indexes for papers table
CREATE INDEX idx_papers_subject_code ON papers(subject_code);
CREATE INDEX idx_papers_year ON papers(year);
CREATE INDEX idx_papers_uploaded_by ON papers(uploaded_by);
CREATE INDEX idx_papers_exam_type ON papers(exam_type);

-- Votes table (marks paper as useful)
CREATE TABLE votes (
    vote_id SERIAL PRIMARY KEY,
    paper_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    voted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(paper_id, user_id),
    FOREIGN KEY (paper_id) REFERENCES papers(paper_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create indexes for votes table
CREATE INDEX idx_votes_paper_id ON votes(paper_id);
CREATE INDEX idx_votes_user_id ON votes(user_id);

-- Difficulty votes table
CREATE TABLE difficulty_votes (
    vote_id SERIAL PRIMARY KEY,
    paper_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    difficulty VARCHAR(10) NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
    voted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(paper_id, user_id),
    FOREIGN KEY (paper_id) REFERENCES papers(paper_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create indexes for difficulty_votes table
CREATE INDEX idx_difficulty_votes_paper_id ON difficulty_votes(paper_id);
CREATE INDEX idx_difficulty_votes_user_id ON difficulty_votes(user_id);
CREATE INDEX idx_difficulty_votes_difficulty ON difficulty_votes(difficulty);

-- Paper requests table
CREATE TABLE paper_requests (
    request_id SERIAL PRIMARY KEY,
    subject_name VARCHAR(150) NOT NULL,
    subject_code VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    exam_type VARCHAR(50),
    additional_notes TEXT,
    requested_by INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'rejected')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (requested_by) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create indexes for paper_requests table
CREATE INDEX idx_paper_requests_status ON paper_requests(status);
CREATE INDEX idx_paper_requests_requested_by ON paper_requests(requested_by);
CREATE INDEX idx_paper_requests_created_at ON paper_requests(created_at DESC);

-- Notifications table
CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    message TEXT NOT NULL,
    link VARCHAR(255),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create indexes for notifications table
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- Insert default admin user
-- ⚠️ SECURITY WARNING: Password is stored as PLAIN TEXT
-- Set a strong password immediately after running this schema
-- Implement bcrypt password hashing as first priority after deployment
INSERT INTO users (username, email, password, role) VALUES
('admin', 'admin@paperwise.com', 'CHANGE_THIS_PASSWORD_IMMEDIATELY', 'admin');

-- After loading schema, run:
-- UPDATE users SET password = 'YourStrongPassword123!' WHERE username = 'admin';
