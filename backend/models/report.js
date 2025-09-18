const db = require('../config/db');

class Report {
  static async getEventReports() {
    const [rows] = await db.execute(`
      SELECT
        e.id,
        e.title,
        e.date,
        COUNT(r.id) as total_registrations,
        SUM(CASE WHEN r.status = 'confirmed' THEN 1 ELSE 0 END) as confirmed_attendees
      FROM events e
      LEFT JOIN registrations r ON e.id = r.event_id
      GROUP BY e.id, e.title, e.date
      ORDER BY e.date DESC
    `);
    return rows;
  }

  static async getDashboardStats() {
    const [eventStats] = await db.execute(`
      SELECT
        COUNT(*) as total_events,
        SUM(CASE WHEN date >= CURDATE() THEN 1 ELSE 0 END) as upcoming_events
      FROM events
    `);

    const [registrationStats] = await db.execute(`
      SELECT
        COUNT(*) as total_registrations,
        SUM(CASE WHEN status = 'confirmed' THEN 1 ELSE 0 END) as confirmed_registrations
      FROM registrations
    `);

    const [notificationStats] = await db.execute(`
      SELECT
        COUNT(*) as total_notifications,
        SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved_notifications,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_notifications
      FROM notifications
    `);

    const [resourceStats] = await db.execute(`
      SELECT
        COUNT(*) as total_resources,
        SUM(total_quantity) as total_quantity,
        SUM(available_quantity) as available_quantity
      FROM resources
    `);

    return {
      events: eventStats[0],
      registrations: registrationStats[0],
      notifications: notificationStats[0],
      resources: resourceStats[0]
    };
  }
}

module.exports = Report;
