const db = require('../config/db');

class Registration {
  static async getAll() {
    const [rows] = await db.execute('SELECT * FROM registrations ORDER BY created_at DESC');
    return rows;
  }

  static async findById(id) {
    const [rows] = await db.execute('SELECT * FROM registrations WHERE id = ?', [id]);
    return rows[0];
  }

  static async create(registrationData) {
    const { event_id, participant_name, email, phone, organization } = registrationData;
    const [result] = await db.execute(
      'INSERT INTO registrations (event_id, participant_name, email, phone, organization) VALUES (?, ?, ?, ?, ?)',
      [event_id, participant_name, email, phone, organization]
    );
    return result.insertId;
  }

  static async update(id, registrationData) {
    const { event_id, participant_name, email, phone, organization } = registrationData;
    await db.execute(
      'UPDATE registrations SET event_id = ?, participant_name = ?, email = ?, phone = ?, organization = ? WHERE id = ?',
      [event_id, participant_name, email, phone, organization, id]
    );
    return true;
  }

  static async delete(id) {
    await db.execute('DELETE FROM registrations WHERE id = ?', [id]);
    return true;
  }
}

module.exports = Registration;
