const db = require('../config/db');

class Registration {
  static async getAll() {
    const [rows] = await db.query(`
      SELECT r.*, e.title AS event_title
      FROM registrations r
      LEFT JOIN events e ON r.event_id = e.id
      ORDER BY r.id DESC
    `);
    return rows;
  }

  static async findById(id) {
    try {
      const [rows] = await db.execute('SELECT * FROM registrations WHERE id = ?', [id]);
      return rows[0];
    } catch (error) {
      console.error('Error in Registration.findById:', error);
      throw error;
    }
  }

  static async create(registrationData) {
    const { event_id, participant_name, email, phone, organization, student_id } = registrationData;
    try {
      const params = [event_id, participant_name, email, phone, organization, student_id].map(val => val === undefined ? null : val);
      const [result] = await db.execute(
        'INSERT INTO registrations (event_id, participant_name, email, phone, organization, student_id) VALUES (?, ?, ?, ?, ?, ?)',
        params
      );
      return result.insertId;
    } catch (error) {
      console.error('Error in Registration.create:', error);
      throw error;
    }
  }

  static async update(id, registrationData) {
    const { event_id, participant_name, email, phone, organization, student_id } = registrationData;
    try {
      const params = [event_id, participant_name, email, phone, organization, student_id, id].map(val => val === undefined ? null : val);
      await db.execute(
        'UPDATE registrations SET event_id = ?, participant_name = ?, email = ?, phone = ?, organization = ?, student_id = ? WHERE id = ?',
        params
      );
      return true;
    } catch (error) {
      console.error('Error in Registration.update:', error);
      throw error;
    }
  }

  static async delete(id) {
    try {
      await db.execute('DELETE FROM registrations WHERE id = ?', [id]);
      return true;
    } catch (error) {
      console.error('Error in Registration.delete:', error);
      throw error;
    }
  }
}

module.exports = Registration;
