const express = require('express');
const Resource = require('../models/Resource');
//const authMiddleware = require('../middleware/auth');

const router = express.Router();

  // READ - Get all resources
router.get('/', async (req, res) => {
  try {
    const resources = await Resource.getAll();
    res.json(resources);
  } catch (error) {
    console.error('Error fetching resources:', error);
    res.status(500).json({ error: 'Failed to load resources' });
  }
});

  // READ - Get resource by ID
router.get('/:id', async (req, res) => {
  try {
    const resource = await Resource.findById(req.params.id);
    if (!resource) {
      return res.status(404).json({ error: 'Resource not found' });
    }
    res.json(resource);
  } catch (error) {
    console.error('Error fetching resource:', error);
    res.status(500).json({ error: 'Failed to load resource' });
  }
});

  // CREATE - Create new resource
router.post('/', async (req, res) => {
  try {
    console.log('Creating resource with data:', req.body);
    const resourceId = await Resource.create(req.body);
    console.log('Resource created successfully with ID:', resourceId);
    res.status(201).json({ id: resourceId });
  } catch (error) {
    console.error('Error creating resource:', error);
    console.error('Request body:', req.body);
    res.status(500).json({ error: 'Failed to create resource' });
  }
});

  // UPDATE - Update resource
router.put('/:id', async (req, res) => {
  try {
    await Resource.update(req.params.id, req.body);
    res.json({ message: 'Resource updated' });
  } catch (error) {
    console.error('Error updating resource:', error);
    res.status(500).json({ error: 'Failed to update resource' });
  }
});

  // DELETE - Delete resource
router.delete('/:id', async (req, res) => {
  try {
    await Resource.delete(req.params.id);
    res.json({ message: 'Resource deleted' });
  } catch (error) {
    console.error('Error deleting resource:', error);
    res.status(500).json({ error: 'Failed to delete resource' });
  }
});

module.exports = router;
