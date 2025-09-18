const db = require('../config/db');

class Notification {
  static async getAll() {
    const [rows] = await db.execute('SELECT * FROM notifications ORDER BY created_at DESC');
    return rows;
  }

  static async findById(id) {
    const [rows] = await db.execute('SELECT * FROM notifications WHERE id = ?', [id]);
    return rows[0];
  }

  static async create(notificationData) {
    const { event_id, message, status = 'pending' } = notificationData;
    const [result] = await db.execute(
      'INSERT INTO notifications (event_id, message, status) VALUES (?, ?, ?)',
      [event_id, message, status]
    );
    return result.insertId;
  }

  static async updateStatus(id, status) {
    await db.execute('UPDATE notifications SET status = ? WHERE id = ?', [status, id]);
    return true;
  }

  static async delete(id) {
    await db.execute('DELETE FROM notifications WHERE id = ?', [id]);
    return true;
  }
}

module.exports = Notification;
