const pool = require('../config/db');

// ─── GET /api/hubs ──────────────────────────────────────────────────────────
// Returns all hubs from the database, ordered by hub_type and hub_name.
const getAllHubs = async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT hub_id, hub_name, hub_type, region, lat, lng, is_active, created_at
             FROM hubs
             ORDER BY 
               CASE hub_type WHEN 'national' THEN 1 WHEN 'regional' THEN 2 ELSE 3 END,
               region, hub_name`
        );
        res.status(200).json(result.rows);
    } catch (error) {
        console.error('Error in getAllHubs:', error);
        res.status(500).json({ error: 'Server error while fetching hubs' });
    }
};

// ─── POST /api/hubs ──────────────────────────────────────────────────────────
// Creates a new hub. Body: { hub_name, hub_type, region, lat, lng }
const createHub = async (req, res) => {
    try {
        const { hub_name, hub_type, region, lat, lng } = req.body;

        if (!hub_name || !hub_type || !region || lat == null || lng == null) {
            return res.status(400).json({ error: 'Missing required fields: hub_name, hub_type, region, lat, lng' });
        }

        const validTypes = ['national', 'regional', 'local'];
        const validRegions = ['north', 'west', 'east', 'south', 'central'];

        if (!validTypes.includes(hub_type)) {
            return res.status(400).json({ error: `Invalid hub_type. Must be one of: ${validTypes.join(', ')}` });
        }
        if (!validRegions.includes(region)) {
            return res.status(400).json({ error: `Invalid region. Must be one of: ${validRegions.join(', ')}` });
        }

        const result = await pool.query(
            `INSERT INTO hubs (hub_name, hub_type, region, lat, lng)
             VALUES ($1, $2, $3, $4, $5)
             RETURNING *`,
            [hub_name, hub_type, region, lat, lng]
        );

        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('Error in createHub:', error);
        res.status(500).json({ error: 'Server error while creating hub' });
    }
};

// ─── DELETE /api/hubs/:id ────────────────────────────────────────────────────
// Soft-deletes a hub by setting is_active = FALSE.
const deleteHub = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            `UPDATE hubs SET is_active = FALSE WHERE hub_id = $1 RETURNING *`,
            [id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Hub not found' });
        }
        res.status(200).json({ message: 'Hub deactivated successfully', hub: result.rows[0] });
    } catch (error) {
        console.error('Error in deleteHub:', error);
        res.status(500).json({ error: 'Server error while deleting hub' });
    }
};

module.exports = {
    getAllHubs,
    createHub,
    deleteHub,
};
