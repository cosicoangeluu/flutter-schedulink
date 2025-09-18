const express = require('express');
const Registration = require('../models/registration');
//const authMiddleware = require('../middleware/auth');

const router = express.Router();

// READ - Get all registrations
router.get('/', async (req, res) => {
  try {
    const registrations = await Registration.getAll();
    res.json(registrations);
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

// CREATE - Create new registration
router.post('/', async (req, res) => {
  try {
    console.log('Creating registration with data:', req.body);
    const registrationId = await Registration.create(req.body);
    console.log('Registration created successfully with ID:', registrationId);
    res.status(201).json({ id: registrationId });
  } catch (error) {
    console.error('Error creating registration:', error);
    console.error('Request body:', req.body);
    res.status(500).json({ error: 'Failed to create registration' });
  }
});

// UPDATE - Update registration
router.put('/:id', async (req, res) => {
  try {
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
