const pool = require('../config/db');

// ─── Haversine Distance (km between two lat/lng points) ───────────────────────
const haversineKm = (lat1, lng1, lat2, lng2) => {
    const R = 6371; // Earth radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a =
        Math.sin(dLat / 2) ** 2 +
        Math.cos(lat1 * Math.PI / 180) *
        Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLng / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
};

// ─── Find nearest hub to a given coordinate ──────────────────────────────────
const findNearestHub = (lat, lng, hubs) => {
    let nearest = null;
    let minDist = Infinity;
    for (const hub of hubs) {
        const d = haversineKm(lat, lng, hub.lat, hub.lng);
        if (d < minDist) {
            minDist = d;
            nearest = hub;
        }
    }
    return { hub: nearest, distanceKm: minDist };
};

// ─── Build adjacency graph from hubs + connections ───────────────────────────
const buildGraph = (hubs, connections) => {
    const graph = {};
    const hubMap = {};

    // Index hubs by ID
    for (const hub of hubs) {
        graph[hub.hub_id] = [];
        hubMap[hub.hub_id] = hub;
    }

    // Add explicit connections (bidirectional)
    for (const conn of connections) {
        const { hub_a_id, hub_b_id, distance_km } = conn;
        const dist = parseFloat(distance_km);
        if (graph[hub_a_id]) graph[hub_a_id].push({ to: hub_b_id, weight: dist });
        if (graph[hub_b_id]) graph[hub_b_id].push({ to: hub_a_id, weight: dist });
    }

    // Auto-generate missing connections using Haversine if graph is sparse
    // Strategy: national↔national (all pairs), regional→2 nearest nationals, local→nearest regional
    if (connections.length < hubs.length) {
        const nationals  = hubs.filter(h => h.hub_type === 'national');
        const regionals  = hubs.filter(h => h.hub_type === 'regional');
        const locals     = hubs.filter(h => h.hub_type === 'local');

        // National ↔ National: fully connected backbone
        for (let i = 0; i < nationals.length; i++) {
            for (let j = i + 1; j < nationals.length; j++) {
                const d = haversineKm(nationals[i].lat, nationals[i].lng, nationals[j].lat, nationals[j].lng);
                graph[nationals[i].hub_id].push({ to: nationals[j].hub_id, weight: d });
                graph[nationals[j].hub_id].push({ to: nationals[i].hub_id, weight: d });
            }
        }

        // Regional → 2 nearest Nationals
        for (const reg of regionals) {
            const sorted = nationals
                .map(n => ({ hub: n, d: haversineKm(reg.lat, reg.lng, n.lat, n.lng) }))
                .sort((a, b) => a.d - b.d)
                .slice(0, 2);
            for (const { hub, d } of sorted) {
                graph[reg.hub_id].push({ to: hub.hub_id, weight: d });
                graph[hub.hub_id].push({ to: reg.hub_id, weight: d });
            }
        }

        // Local → nearest Regional (or National if no regional)
        for (const loc of locals) {
            const candidates = regionals.length > 0 ? regionals : nationals;
            const sorted = candidates
                .map(h => ({ hub: h, d: haversineKm(loc.lat, loc.lng, h.lat, h.lng) }))
                .sort((a, b) => a.d - b.d)
                .slice(0, 1);
            for (const { hub, d } of sorted) {
                graph[loc.hub_id].push({ to: hub.hub_id, weight: d });
                graph[hub.hub_id].push({ to: loc.hub_id, weight: d });
            }
        }
    }

    return { graph, hubMap };
};

// ─── Dijkstra's Algorithm ─────────────────────────────────────────────────────
const dijkstra = (graph, startId, endId) => {
    const dist  = {};
    const prev  = {};
    const visited = new Set();

    // Initialize all distances to Infinity
    for (const id of Object.keys(graph)) {
        dist[id] = Infinity;
        prev[id] = null;
    }
    dist[startId] = 0;

    // Simple priority queue using array (adequate for ~60 hubs)
    const queue = [{ id: startId, cost: 0 }];

    while (queue.length > 0) {
        // Get node with minimum cost
        queue.sort((a, b) => a.cost - b.cost);
        const { id: current } = queue.shift();

        if (current == endId) break;
        if (visited.has(current)) continue;
        visited.add(current);

        for (const neighbor of (graph[current] || [])) {
            if (visited.has(neighbor.to)) continue;
            const newDist = dist[current] + neighbor.weight;
            if (newDist < dist[neighbor.to]) {
                dist[neighbor.to] = newDist;
                prev[neighbor.to] = current;
                queue.push({ id: neighbor.to, cost: newDist });
            }
        }
    }

    // Reconstruct path
    const path = [];
    let cur = String(endId);
    while (cur !== null && cur !== undefined) {
        path.unshift(Number(cur));
        cur = prev[cur];
    }

    // Validate path
    if (path[0] !== Number(startId)) return null; // No path found

    return {
        path,
        totalKm: parseFloat((dist[String(endId)] === Infinity ? 0 : dist[String(endId)]).toFixed(2))
    };
};

// ─── Main: Compute route for an out-of-city order ────────────────────────────
const computeOrderRoute = async (senderLat, senderLng, receiverLat, receiverLng) => {
    try {
        // Guard — only compute if coordinates are present
        if (!senderLat || !senderLng || !receiverLat || !receiverLng) return null;

        const sLat = parseFloat(senderLat);
        const sLng = parseFloat(senderLng);
        const rLat = parseFloat(receiverLat);
        const rLng = parseFloat(receiverLng);

        // Load all active hubs
        const hubsResult = await pool.query(
            `SELECT hub_id, hub_name, hub_type, region, lat, lng FROM hubs WHERE is_active = true`
        );
        const hubs = hubsResult.rows;
        if (hubs.length === 0) return null;

        // Load all active hub connections
        const connResult = await pool.query(
            `SELECT hub_a_id, hub_b_id, distance_km FROM hub_connections WHERE is_active = true`
        );
        const connections = connResult.rows;

        // Find nearest hubs to sender & receiver
        const { hub: originHub,      distanceKm: lastMilePickup }   = findNearestHub(sLat, sLng, hubs);
        const { hub: destHub,        distanceKm: lastMileDelivery }  = findNearestHub(rLat, rLng, hubs);

        // Build graph & run Dijkstra
        const { graph, hubMap } = buildGraph(hubs, connections);
        let routeResult = null;

        if (originHub.hub_id === destHub.hub_id) {
            // Same hub — direct
            routeResult = { path: [originHub.hub_id], totalKm: 0 };
        } else {
            routeResult = dijkstra(graph, originHub.hub_id, destHub.hub_id);
        }

        if (!routeResult) return null;

        const hubNames = routeResult.path.map(id => hubMap[id]?.hub_name || `Hub #${id}`);
        const hubTypes = routeResult.path.map(id => hubMap[id]?.hub_type || 'unknown');

        return {
            type: 'intercity',
            origin_hub_id:      originHub.hub_id,
            destination_hub_id: destHub.hub_id,
            hub_path:           routeResult.path,
            hub_names:          hubNames,
            hub_types:          hubTypes,
            total_route_km:     parseFloat((lastMilePickup + routeResult.totalKm + lastMileDelivery).toFixed(2)),
            hub_network_km:     routeResult.totalKm,
            last_mile_pickup_km:    parseFloat(lastMilePickup.toFixed(2)),
            last_mile_delivery_km:  parseFloat(lastMileDelivery.toFixed(2)),
            hub_count:          routeResult.path.length,
            computed_at:        new Date().toISOString(),
        };

    } catch (err) {
        console.error('[dijkstraService] Error computing route:', err);
        return null;
    }
};

// ─── Get route for an existing order ─────────────────────────────────────────
const getOrderRoute = async (orderId) => {
    try {
        const result = await pool.query(
            `SELECT order_id, route_data, sender_lat, sender_lng, receiver_lat, receiver_lng,
                    fare_breakdown, sender_city, receiver_city
             FROM orders WHERE order_id = $1`,
            [orderId]
        );
        if (result.rows.length === 0) return null;
        const order = result.rows[0];

        // If route already computed, return it
        if (order.route_data) return order.route_data;

        // Compute it now if coordinates exist
        if (order.sender_lat && order.receiver_lat) {
            const route = await computeOrderRoute(
                order.sender_lat, order.sender_lng,
                order.receiver_lat, order.receiver_lng
            );
            if (route) {
                // Persist for next time
                await pool.query(
                    `UPDATE orders SET route_data = $1 WHERE order_id = $2`,
                    [JSON.stringify(route), orderId]
                );
            }
            return route;
        }

        return null;
    } catch (err) {
        console.error('[dijkstraService] Error getting order route:', err);
        return null;
    }
};

module.exports = {
    computeOrderRoute,
    getOrderRoute,
    haversineKm,
    findNearestHub,
    dijkstra,
};
