const express = require('express');
const Report = require('../models/report');

const router = express.Router();

  // READ - Get event reports
// Get event reports
router.get('/events', async (req, res) => {
  try {
    const reports = await Report.getEventReports();
    res.json(reports);
  } catch (error) {
    console.error('Error fetching event reports:', error);
    res.status(500).json({ error: 'Failed to load event reports' });
  }
});

  // READ - Get dashboard statistics
// Get dashboard statistics
router.get('/dashboard', async (req, res) => {
  try {
    const stats = await Report.getDashboardStats();
    res.json(stats);
  } catch (error) {
    console.error('Error fetching dashboard stats:', error);
    res.status(500).json({ error: 'Failed to load dashboard statistics' });
  }
});

module.exports = router;
