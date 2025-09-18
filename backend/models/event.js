const db = require('../config/db');

class Event {
  static async getAll() {
    const [rows] = await db.execute(`
      SELECT e.*, COUNT(r.id) as registered_count
      FROM events e
      LEFT JOIN registrations r ON e.id = r.event_id
      GROUP BY e.id
      ORDER BY e.date DESC
    `);
    return rows;
  }

  static async findById(id) {
    const [rows] = await db.execute('SELECT * FROM events WHERE id = ?', [id]);
    return rows[0];
  }

  static async create(eventData) {
    const { title, description, date, time, location, capacity, organizer_id, status = 'pending' } = eventData;
    const [result] = await db.execute(
      'INSERT INTO events (title, description, date, time, location, capacity, organizer_id, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [title, description, date, time, location, capacity, organizer_id, status]
    );
    return result.insertId;
  }

  static async update(id, eventData) {
    const { title, description, date, time, location, capacity, status } = eventData;
    await db.execute(
      'UPDATE events SET title = ?, description = ?, date = ?, time = ?, location = ?, capacity = ?, status = ? WHERE id = ?',
      [title, description, date, time, location, capacity, status, id]
    );
    return true;
  }

  static async delete(id) {
    await db.execute('DELETE FROM events WHERE id = ?', [id]);
    return true;
  }

  static async updateStatus(id, status) {
    await db.execute('UPDATE events SET status = ? WHERE id = ?', [status, id]);
    return true;
  }
}

module.exports = Event;
