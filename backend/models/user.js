const db = require('../config/db');

class User {
  static async findByUsername(username) {
    const [rows] = await db.execute('SELECT * FROM users WHERE username = ?', [username]);
    return rows[0];
  }

  static async findById(id) {
    const [rows] = await db.execute('SELECT id, username, email, role FROM users WHERE id = ?', [id]);
    return rows[0];
  }

  static async create(userData) {
    const { username, email, password, role = 'user' } = userData;
    const [result] = await db.execute(
      'INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
      [username, email, password, role]
    );
    return result.insertId;
  }

  static async getAll() {
    const [rows] = await db.execute('SELECT id, username, email, role FROM users');
    return rows;
  }
}

module.exports = User;
