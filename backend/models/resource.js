const db = require('../config/db');

class Resource {
  static async getAll() {
    const [rows] = await db.execute('SELECT * FROM resources ORDER BY name ASC');
    return rows;
  }

  static async findById(id) {
    const [rows] = await db.execute('SELECT * FROM resources WHERE id = ?', [id]);
    return rows[0];
  }

  static async create(resourceData) {
    const { name, category, total_quantity, available_quantity, location, condition, status } = resourceData;
    const [result] = await db.execute(
      'INSERT INTO resources (name, category, total_quantity, available_quantity, location, condition, status) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [name, category, total_quantity, available_quantity, location, condition, status]
    );
    return result.insertId;
  }

  static async update(id, resourceData) {
    const { name, category, total_quantity, available_quantity, location, condition, status } = resourceData;
    await db.execute(
      'UPDATE resources SET name = ?, category = ?, total_quantity = ?, available_quantity = ?, location = ?, condition = ?, status = ? WHERE id = ?',
      [name, category, total_quantity, available_quantity, location, condition, status, id]
    );
    return true;
  }

  static async delete(id) {
    await db.execute('DELETE FROM resources WHERE id = ?', [id]);
    return true;
  }
}

module.exports = Resource;
