const express = require('express');
const Registration = require('../models/registration');
const db = require('../config/db');

const router = express.Router();

async function eventExists(eventId) {
  try {
    const [rows] = await db.execute('SELECT id FROM events WHERE id = ?', [eventId]);
    return rows.length > 0;
  } catch (error) {
    console.error('Error checking event existence:', error);
    return false;
  }
}

// READ - Get all registrations
router.get('/', async (req, res) => {
  try {
    const registrations = await Registration.getAll();
    console.log('Registrations fetched:', registrations);
    // Ensure all fields are returned
    const formatted = registrations.map(reg => ({
      id: reg.id,
      event_id: reg.event_id,
      event_title: reg.event_title,
      participant_name: reg.participant_name,
      email: reg.email,
      phone: reg.phone,
      organization: reg.organization,
      student_id: reg.student_id,
    }));
    res.json(formatted);
  } catch (error) {
    console.error('Error fetching registrations:', error);
    res.status(500).json({ error: 'Failed to load registrations' });
  }
});

// READ - Get registration by ID
router.get('/:id', async (req, res) => {
  try {
    const registration = await Registration.findById(req.params.id);
    if (!registration) {
      return res.status(404).json({ error: 'Registration not found' });
    }
    res.json(registration);
  } catch (error) {
    console.error('Error fetching registration:', error);
    res.status(500).json({ error: 'Failed to load registration' });
  }
});

  
router.post('/', async (req, res) => {
  console.log('Incoming registration data:', req.body);
  try {
    const { event_title, participant_name, email, phone, organization, student_id } = req.body;
    if (!event_title || !participant_name || !email) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Case-insensitive event title lookup
    const [rows] = await db.execute(
      'SELECT id FROM events WHERE LOWER(title) = LOWER(?)',
      [event_title.trim()]
    );
    if (rows.length === 0) {
      console.error('Event not found for title:', event_title);
      return res.status(400).json({ error: 'Event not found' });
    }
    const event_id = rows[0].id;

    console.log('Creating registration with data:', req.body);
    const registrationId = await Registration.create({
      event_id,
      participant_name,
      email,
      phone,
      organization,
      student_id,
    });
    res.status(201).json({ id: registrationId });
  } catch (error) {
    console.error('Error creating registration:', error);
    res.status(500).json({ error: 'Failed to register participant' });
  }
});

// UPDATE - Update registration
router.put('/:id', async (req, res) => {
  try {
    const { event_id, participant_name, email } = req.body;
    if (!event_id || !participant_name || !email) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    await Registration.update(req.params.id, req.body);
    res.json({ message: 'Registration updated' });
  } catch (error) {
    console.error('Error updating registration:', error);
    res.status(500).json({ error: 'Failed to update registration' });
  }
});

// DELETE - Delete registration
router.delete('/:id', async (req, res) => {
  try {
    await Registration.delete(req.params.id);
    res.json({ message: 'Registration deleted' });
  } catch (error) {
    console.error('Error deleting registration:', error);
    res.status(500).json({ error: 'Failed to delete registration' });
  }
});

module.exports = router;
