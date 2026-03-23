-- ============================================================================
-- PaperWise Database Setup Script for PostgreSQL
-- ============================================================================
-- This script creates the database, tables, and inserts test data
-- Run this script as PostgreSQL superuser (postgres)
-- ============================================================================

-- Create database (run this first, then connect to the new database)
CREATE DATABASE paperwise_db
    WITH 
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TEMPLATE = template0;

-- Connect to the database
\c paperwise_db

-- ============================================================================
-- Create users table
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'student')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- ============================================================================
-- Create papers table
-- ============================================================================
CREATE TABLE IF NOT EXISTS papers (
    paper_id SERIAL PRIMARY KEY,
    subject_name VARCHAR(150) NOT NULL,
    subject_code VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL,
    chapter VARCHAR(100),
    file_url VARCHAR(255) NOT NULL,
    uploaded_by INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_uploaded_by FOREIGN KEY (uploaded_by) 
        REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create indexes for papers table
CREATE INDEX idx_papers_subject_code ON papers(subject_code);
CREATE INDEX idx_papers_year ON papers(year);
CREATE INDEX idx_papers_uploaded_by ON papers(uploaded_by);

-- ============================================================================
-- Create votes table
-- ============================================================================
CREATE TABLE IF NOT EXISTS votes (
    id SERIAL PRIMARY KEY,
    paper_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vote_paper FOREIGN KEY (paper_id) 
        REFERENCES papers(paper_id) ON DELETE CASCADE,
    CONSTRAINT fk_vote_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT unique_vote UNIQUE (paper_id, user_id)
);

-- Create indexes for votes table
CREATE INDEX IF NOT EXISTS idx_votes_paper_id ON votes(paper_id);
CREATE INDEX IF NOT EXISTS idx_votes_user_id ON votes(user_id);

-- ============================================================================
-- Insert test data
-- ============================================================================
-- WARNING: Passwords are stored in PLAIN TEXT for development only
-- NEVER use plain text passwords in production!
-- ============================================================================

-- Test user passwords:
-- admin: admin123A!
-- student: student123A!
-- john_doe: password123A!
-- jane_smith: password123A!

-- Admin user (password: admin123A!)
INSERT INTO users (username, email, password, role) 
VALUES ('admin', 'admin@paperwise.com', 'admin123A!', 'admin')
ON CONFLICT (username) DO NOTHING;

-- Student users
INSERT INTO users (username, email, password, role) 
VALUES 
    ('student', 'student@paperwise.com', 'student123A!', 'student'),
    ('john_doe', 'john.doe@paperwise.com', 'password123A!', 'student'),
    ('jane_smith', 'jane.smith@paperwise.com', 'password123A!', 'student')
ON CONFLICT (username) DO NOTHING;

-- ============================================================================
-- Verify data
-- ============================================================================
SELECT 
    user_id,
    username,
    email,
    role,
    created_at
FROM users
ORDER BY user_id;

-- ============================================================================
-- Display table information
-- ============================================================================
\d users

-- ============================================================================
-- Grant permissions (optional - adjust as needed)
-- ============================================================================
-- If you want to create a specific application user:
-- CREATE USER paperwise_app WITH PASSWORD 'your_secure_password';
-- GRANT CONNECT ON DATABASE paperwise_db TO paperwise_app;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO paperwise_app;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO paperwise_app;

-- ============================================================================
-- Test queries
-- ============================================================================
-- Test login validation (plain text password)
SELECT 1 FROM users WHERE username = 'admin' AND password = 'admin123A!';

-- Test user retrieval
SELECT user_id, username, email, role, created_at 
FROM users 
WHERE username = 'admin';

-- Count users by role
SELECT role, COUNT(*) as user_count 
FROM users 
GROUP BY role;
