require('dotenv').config();
const db = require('./config/db');
const bcrypt = require('bcrypt');

async function seedDatabase() {
  try {
    console.log('Starting database seeding...');

    // Create tables
    await createTables();

    // Insert sample data
    await insertSampleData();

    console.log('Database seeding completed successfully!');
  } catch (error) {
    console.error('Error seeding database:', error);
  } finally {
    process.exit();
  }
}

async function createTables() {
  console.log('Creating tables...');

  // Users table
  await db.execute(`
    CREATE TABLE IF NOT EXISTS users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      username VARCHAR(50) UNIQUE NOT NULL,
      email VARCHAR(100) UNIQUE NOT NULL,
      password VARCHAR(255) NOT NULL,
      role ENUM('admin', 'user') DEFAULT 'user',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Events table
  await db.execute(`
    CREATE TABLE IF NOT EXISTS events (
      id INT AUTO_INCREMENT PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      description TEXT,
      date DATE NOT NULL,
      time TIME NOT NULL,
      location VARCHAR(255),
      capacity INT,
      organizer_id INT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (organizer_id) REFERENCES users(id)
    )
  `);

  // Registrations table
  await db.execute(`
    CREATE TABLE IF NOT EXISTS registrations (
      id INT AUTO_INCREMENT PRIMARY KEY,
      event_id INT NOT NULL,
      participant_name VARCHAR(255) NOT NULL,
      email VARCHAR(100) NOT NULL,
      phone VARCHAR(20),
      organization VARCHAR(255),
      status ENUM('pending', 'confirmed', 'cancelled') DEFAULT 'pending',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
    )
  `);

  // Notifications table
  await db.execute(`
    CREATE TABLE IF NOT EXISTS notifications (
      id INT AUTO_INCREMENT PRIMARY KEY,
      event_id INT NOT NULL,
      message TEXT NOT NULL,
      status ENUM('pending', 'approved', 'declined') DEFAULT 'pending',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
    )
  `);

  // Resources table
  await db.execute(`
    CREATE TABLE IF NOT EXISTS resources (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      category VARCHAR(100),
      total_quantity INT DEFAULT 0,
      available_quantity INT DEFAULT 0,
      location VARCHAR(255),
      \`condition\` ENUM('good', 'fair', 'poor') DEFAULT 'good',
      status ENUM('available', 'in_use', 'maintenance') DEFAULT 'available',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  console.log('Tables created successfully!');
}

async function insertSampleData() {
  console.log('Inserting sample data...');

  // Hash password for admin user
  const hashedPassword = await bcrypt.hash('admin123', 10);

  // Insert admin user
  await db.execute(
    'INSERT IGNORE INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
    ['admin', 'admin@schedulink.com', hashedPassword, 'admin']
  );

  // Insert sample events
  const events = [
    ['Tech Conference 2024', 'Annual technology conference', '2024-06-15', '09:00:00', 'Main Auditorium', 200, 1],
    ['Workshop: Flutter Development', 'Hands-on Flutter workshop', '2024-06-20', '14:00:00', 'Room 101', 50, 1],
    ['Networking Event', 'Professional networking session', '2024-06-25', '18:00:00', 'Lobby', 100, 1],
    ['Seminar: AI Trends', 'Latest trends in artificial intelligence', '2024-07-01', '10:00:00', 'Conference Room A', 75, 1]
  ];

  for (const event of events) {
    await db.execute(
      'INSERT IGNORE INTO events (title, description, date, time, location, capacity, organizer_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
      event
    );
  }

  // Insert sample registrations
  const registrations = [
    [1, 'John Doe', 'john@example.com', '123-456-7890', 'Tech Corp'],
    [1, 'Jane Smith', 'jane@example.com', '098-765-4321', 'Dev Inc'],
    [2, 'Bob Johnson', 'bob@example.com', '555-123-4567', 'Startup XYZ'],
    [3, 'Alice Brown', 'alice@example.com', '444-987-6543', 'Consulting Ltd']
  ];

  for (const reg of registrations) {
    await db.execute(
      'INSERT IGNORE INTO registrations (event_id, participant_name, email, phone, organization) VALUES (?, ?, ?, ?, ?)',
      reg
    );
  }

  // Insert sample notifications
  const notifications = [
    [1, 'Request for additional AV equipment for Tech Conference'],
    [2, 'Need extra chairs for Flutter workshop'],
    [3, 'Catering setup required for networking event']
  ];

  for (const notif of notifications) {
    await db.execute(
      'INSERT IGNORE INTO notifications (event_id, message) VALUES (?, ?)',
      notif
    );
  }

  // Insert sample resources
  const resources = [
    ['Chairs', 'Furniture', 100, 85, 'Storage Room A', 'good', 'available'],
    ['Tables', 'Furniture', 20, 18, 'Storage Room B', 'good', 'available'],
    ['Projector', 'Equipment', 5, 4, 'AV Room', 'good', 'available'],
    ['Microphones', 'Equipment', 10, 8, 'AV Room', 'fair', 'available'],
    ['Speakers', 'Equipment', 8, 6, 'AV Room', 'good', 'in_use']
  ];

  for (const resource of resources) {
    await db.execute(
      'INSERT IGNORE INTO resources (name, category, total_quantity, available_quantity, location, `condition`, status) VALUES (?, ?, ?, ?, ?, ?, ?)',
      resource
    );
  }

  console.log('Sample data inserted successfully!');
}

seedDatabase();
