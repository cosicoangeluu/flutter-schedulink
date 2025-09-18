-- SQL queries to create tables and insert sample data for the schedulink application

--schedulink_db file name on php

-- Create users table
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'user'
);

-- Insert 5 sample data into users
INSERT INTO users (username, email, password, role) VALUES
('admin', 'admin@example.com', 'hashedpassword1', 'admin'),
('organizer1', 'organizer1@example.com', 'hashedpassword2', 'organizer'),
('user1', 'user1@example.com', 'hashedpassword3', 'user'),
('organizer2', 'organizer2@example.com', 'hashedpassword4', 'organizer'),
('user2', 'user2@example.com', 'hashedpassword5', 'user');

-- Create events table
CREATE TABLE events (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  date DATE,
  time TIME,
  location VARCHAR(255),
  capacity INT,
  organizer_id INT,
  status VARCHAR(50) DEFAULT 'pending'
);

-- Insert 5 sample data into events
INSERT INTO events (title, description, date, time, location, capacity, organizer_id, status) VALUES
('Departamental Orientation', 'Orientation for new students', '2024-12-01', '09:00:00', 'Function Hall', 100, 2, 'approved'),
('Tech Conference', 'Technology trends and talks', '2024-11-15', '10:00:00', 'EMRC', 50, 4, 'pending'),
('Workshop on AI', 'Hands-on workshop on artificial intelligence', '2024-12-05', '14:00:00', 'Lab 101', 30, 2, 'approved'),
('Seminar on Cybersecurity', 'Discussion on latest cybersecurity practices', '2024-11-20', '11:00:00', 'Auditorium', 80, 4, 'pending'),
('Networking Event', 'Meet and greet for professionals', '2024-12-10', '18:00:00', 'Conference Room', 60, 2, 'approved');

-- Create registrations table
CREATE TABLE registrations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  event_id INT NOT NULL,
  participant_name VARCHAR(255),
  email VARCHAR(255),
  phone VARCHAR(20),
  organization VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 5 sample data into registrations
INSERT INTO registrations (event_id, participant_name, email, phone, organization) VALUES
(1, 'Angelu Cosico', 'angelu@example.com', '1234567890', 'BSCS'),
(2, 'Reuven Alcantara', 'reuven@example.com', '0987654321', 'BSCS'),
(3, 'Juan Dela Cruz', 'juan@example.com', '1112223333', 'Engineering'),
(4, 'Pedro Penduko', 'pedro@example.com', '4445556666', 'IT Dept'),
(5, 'Qwerty 123', 'qwe@example.com', '7778889999', 'Business');

-- Create notifications table
CREATE TABLE notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  event_id INT,
  message TEXT,
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 5 sample data into notifications
INSERT INTO notifications (event_id, message, status) VALUES
(1, 'Meeting starts at 9 AM', 'approved'),
(2, 'Conference schedule updated', 'pending'),
(3, 'Workshop materials available online', 'approved'),
(4, 'Seminar registration deadline approaching', 'pending'),
(5, 'Networking event reminder', 'approved');

-- Create resources table
CREATE TABLE resources (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100),
  total_quantity INT,
  available_quantity INT,
  location VARCHAR(255),
  `condition` VARCHAR(100),
  status VARCHAR(50)
);

-- Insert 5 sample data into resources
INSERT INTO resources (name, category, total_quantity, available_quantity, location, `condition`, status) VALUES
('Projector', 'Electronics', 5, 3, 'Storage Room', 'Good', 'available'),
('Whiteboard', 'Office Supplies', 10, 7, 'Meeting Room', 'Fair', 'available'),
('Laptop', 'Electronics', 20, 15, 'IT Lab', 'Excellent', 'available'),
('Chairs', 'Furniture', 50, 40, 'Auditorium', 'Good', 'available'),
('Microphone', 'Audio Equipment', 8, 6, 'Sound Room', 'Fair', 'available');
