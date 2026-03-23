-- Create paper_requests table for students to request papers
-- This table stores requests from students for papers they need

CREATE TABLE IF NOT EXISTS paper_requests (
    request_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    subject_name VARCHAR(150) NOT NULL,
    subject_code VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'completed')),
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key to users table
    CONSTRAINT fk_paper_requests_user_id FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create index for faster queries
CREATE INDEX idx_paper_requests_status ON paper_requests(status);
CREATE INDEX idx_paper_requests_year ON paper_requests(year);
CREATE INDEX idx_paper_requests_user_id ON paper_requests(user_id);

-- Add comments
COMMENT ON TABLE paper_requests IS 'Stores student requests for papers they need';
COMMENT ON COLUMN paper_requests.user_id IS 'ID of the user who requested the paper';
COMMENT ON COLUMN paper_requests.status IS 'Request status: pending, approved, rejected, or completed';
COMMENT ON COLUMN paper_requests.year IS 'Year of the paper (validated: currentYear-20 to currentYear)';
COMMENT ON COLUMN paper_requests.description IS 'Additional details about the paper request';
COMMENT ON COLUMN paper_requests.requested_at IS 'Timestamp when the request was created (auto-set by database)';
