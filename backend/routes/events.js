const express = require('express');
const Event = require('../models/Event');

const router = express.Router();

  // READ - Get all events
router.get('/', async (req, res) => {
  try {
    const events = await Event.getAll();
    res.json(events);
  } catch (error) {
    console.error('Error fetching events:', error);
    res.status(500).json({ error: 'Failed to load events' });
  }
});

  // READ - Get event by ID
router.get('/:id', async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) {
      return res.status(404).json({ error: 'Event not found' });
    }
    res.json(event);
  } catch (error) {
    console.error('Error fetching event:', error);
    res.status(500).json({ error: 'Failed to load event' });
  }
});

  // CREATE - Create new event
router.post('/', async (req, res) => {
  try {
    console.log('Creating event with data:', req.body);
    const eventId = await Event.create(req.body);
    console.log('Event created successfully with ID:', eventId);
    res.status(201).json({ id: eventId });
  } catch (error) {
    console.error('Error creating event:', error);
    console.error('Request body:', req.body);
    res.status(500).json({ error: 'Failed to create event' });
  }
});

  // UPDATE - Update event
router.put('/:id', async (req, res) => {
  try {
    await Event.update(req.params.id, req.body);
    res.json({ message: 'Event updated' });
  } catch (error) {
    console.error('Error updating event:', error);
    res.status(500).json({ error: 'Failed to update event' });
  }
});

  // UPDATE - Update event status
router.put('/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    await Event.updateStatus(req.params.id, status);
    res.json({ message: 'Event status updated' });
  } catch (error) {
    console.error('Error updating event status:', error);
    res.status(500).json({ error: 'Failed to update event status' });
  }
});

  // DELETE - Delete event
router.delete('/:id', async (req, res) => {
  try {
    await Event.delete(req.params.id);
    res.json({ message: 'Event deleted' });
  } catch (error) {
    console.error('Error deleting event:', error);
    res.status(500).json({ error: 'Failed to delete event' });
  }
});

module.exports = router;
