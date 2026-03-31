const express = require('express');
const router = express.Router();
const hubController = require('../controllers/hubController');

// GET /api/hubs – fetch all hubs
router.get('/', hubController.getAllHubs);

// POST /api/hubs – create a new hub
router.post('/', hubController.createHub);

// DELETE /api/hubs/:id – soft-delete (deactivate) a hub
router.delete('/:id', hubController.deleteHub);

module.exports = router;
