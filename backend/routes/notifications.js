const express = require('express');
const Notification = require('../models/Notification');
//const authMiddleware = require('../middleware/auth');

const router = express.Router();

  // READ - Get all notifications
// Get all notifications
router.get('/', async (req, res) => {
  try {
    const notifications = await Notification.getAll();
    res.json(notifications);
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ error: 'Failed to load notifications' });
  }
});

  // READ - Get notification by ID
// Get notification by ID
router.get('/:id', async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);
    if (!notification) {
      return res.status(404).json({ error: 'Notification not found' });
    }
    res.json(notification);
  } catch (error) {
    console.error('Error fetching notification:', error);
    res.status(500).json({ error: 'Failed to load notification' });
  }
});

  // CREATE - Create new notification
// Create new notification
router.post('/', async (req, res) => {
  try {
    console.log('Creating notification with data:', req.body);
    const notificationId = await Notification.create(req.body);
    console.log('Notification created successfully with ID:', notificationId);
    res.status(201).json({ id: notificationId });
  } catch (error) {
    console.error('Error creating notification:', error);
    console.error('Request body:', req.body);
    res.status(500).json({ error: 'Failed to create notification' });
  }
});

  // UPDATE - Approve notification
// Approve notification
router.put('/:id/approve', async (req, res) => {
  try {
    await Notification.updateStatus(req.params.id, 'approved');
    res.json({ message: 'Notification approved' });
  } catch (error) {
    console.error('Error approving notification:', error);
    res.status(500).json({ error: 'Failed to approve notification' });
  }
});

  // UPDATE - Decline notification
// Decline notification
router.put('/:id/decline', async (req, res) => {
  try {
    await Notification.updateStatus(req.params.id, 'declined');
    res.json({ message: 'Notification declined' });
  } catch (error) {
    console.error('Error declining notification:', error);
    res.status(500).json({ error: 'Failed to decline notification' });
  }
});

  // DELETE - Delete notification
// Delete notification
router.delete('/:id', async (req, res) => {
  try {
    await Notification.delete(req.params.id);
    res.json({ message: 'Notification deleted' });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({ error: 'Failed to delete notification' });
  }
});

module.exports = router;
