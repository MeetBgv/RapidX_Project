import React, { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMapEvents } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { MapPin, Plus, X, Filter, Layers, RefreshCw } from 'lucide-react';

// ─── Fix Leaflet default marker icons (Vite/Webpack build issue) ────────────
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
    iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
    shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

// ─── Custom color-coded hub icons ───────────────────────────────────────────
const createHubIcon = (color, size = 12) => L.divIcon({
    className: '',
    html: `
        <div style="
            width: ${size + 8}px; height: ${size + 8}px;
            background: ${color}; border-radius: 50%;
            border: 2.5px solid white;
            box-shadow: 0 0 0 2px ${color}, 0 4px 10px rgba(0,0,0,0.5);
            display: flex; align-items: center; justify-content: center;
        ">
            <div style="width: ${size - 6}px; height: ${size - 6}px; background: white; border-radius: 50%; opacity: 0.8;"></div>
        </div>
    `,
    iconSize: [size + 8, size + 8],
    iconAnchor: [(size + 8) / 2, (size + 8) / 2],
    popupAnchor: [0, -(size + 8) / 2],
});

const HUB_ICONS = {
    national: createHubIcon('#FFD700', 20),  // Gold - largest
    regional: createHubIcon('#3B82F6', 14),  // Blue - medium
    local:    createHubIcon('#10B981',  10), // Green - smallest
};

const NEW_HUB_ICON = createHubIcon('#F97316', 14); // Orange for pending new hub

// ─── Map click handler component ───────────────────────────────────────────
function MapClickHandler({ onMapClick, isAddingHub }) {
    useMapEvents({
        click(e) {
            if (isAddingHub) {
                onMapClick(e.latlng);
            }
        },
    });
    return null;
}

// ─── Hub Stats bar ──────────────────────────────────────────────────────────
function HubStats({ hubs }) {
    const national = hubs.filter(h => h.hub_type === 'national').length;
    const regional = hubs.filter(h => h.hub_type === 'regional').length;
    const local    = hubs.filter(h => h.hub_type === 'local').length;

    return (
        <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
            {[
                { label: 'National', count: national, color: '#FFD700' },
                { label: 'Regional', count: regional, color: '#3B82F6' },
                { label: 'Local',    count: local,    color: '#10B981' },
                { label: 'Total',    count: hubs.length, color: 'var(--text-primary)' },
            ].map(({ label, count, color }) => (
                <div key={label} style={{
                    background: 'var(--bg-secondary)',
                    borderRadius: 'var(--radius-md)',
                    padding: '0.5rem 1.25rem',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    minWidth: '80px',
                    border: '1px solid var(--border-light)',
                }}>
                    <span style={{ fontSize: '1.4rem', fontWeight: 700, color }}>{count}</span>
                    <span style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>{label}</span>
                </div>
            ))}
        </div>
    );
}

// ─────────────────────────────────────────────────────────────────────────────
const Hubs = () => {
    const [hubs, setHubs]               = useState([]);
    const [loading, setLoading]         = useState(true);
    const [error, setError]             = useState(null);
    const [filterType, setFilterType]   = useState('all');
    const [filterRegion, setFilterRegion] = useState('all');

    // Adding hub state
    const [isAddingHub, setIsAddingHub] = useState(false);
    const [pendingLatLng, setPendingLatLng] = useState(null);
    const [showForm, setShowForm]       = useState(false);
    const [formData, setFormData]       = useState({ hub_name: '', hub_type: 'local', region: 'north' });
    const [submitting, setSubmitting]   = useState(false);
    const [formError, setFormError]     = useState('');

    const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;
    const SUPABASE_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY;

    const supabaseHeaders = {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
    };

    // ── Fetch hubs directly from Supabase REST API ──────────────────────────
    const fetchHubs = async () => {
        setLoading(true);
        setError(null);
        try {
            const res = await fetch(
                `${SUPABASE_URL}/rest/v1/hubs?select=hub_id,hub_name,hub_type,region,lat,lng,is_active&order=hub_type.asc,hub_name.asc`,
                { headers: supabaseHeaders }
            );
            if (!res.ok) throw new Error(`Failed to fetch hubs (${res.status})`);
            const data = await res.json();
            setHubs(data);
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    // eslint-disable-next-line react-hooks/exhaustive-deps
    useEffect(() => { fetchHubs(); }, []);

    // ── Filter hubs for display ─────────────────────────────────────────────
    const visibleHubs = hubs.filter(h => {
        if (filterType !== 'all' && h.hub_type !== filterType) return false;
        if (filterRegion !== 'all' && h.region !== filterRegion) return false;
        return true;
    });

    // ── Map click → open form ───────────────────────────────────────────────
    const handleMapClick = (latlng) => {
        setPendingLatLng(latlng);
        setShowForm(true);
        setFormError('');
        setFormData(prev => ({ ...prev, hub_name: '' }));
    };

    // ── Submit new hub directly to Supabase ────────────────────────────────
    const handleSubmitHub = async (e) => {
        e.preventDefault();
        if (!formData.hub_name.trim()) {
            setFormError('Hub name is required.');
            return;
        }
        setSubmitting(true);
        setFormError('');
        try {
            const res = await fetch(`${SUPABASE_URL}/rest/v1/hubs`, {
                method: 'POST',
                headers: supabaseHeaders,
                body: JSON.stringify({
                    hub_name: formData.hub_name.trim(),
                    hub_type: formData.hub_type,
                    region:   formData.region,
                    lat:      pendingLatLng.lat,
                    lng:      pendingLatLng.lng,
                }),
            });
            if (!res.ok) {
                const err = await res.json();
                throw new Error(err.message || 'Failed to create hub');
            }
            const [newHub] = await res.json();
            setHubs(prev => [...prev, newHub]);

            // Reset
            setShowForm(false);
            setPendingLatLng(null);
            setIsAddingHub(false);
        } catch (err) {
            setFormError(err.message);
        } finally {
            setSubmitting(false);
        }
    };

    // ── Deactivate hub (soft delete) via Supabase PATCH ────────────────────
    const handleDeleteHub = async (hubId) => {
        if (!window.confirm('Deactivate this hub?')) return;
        try {
            const res = await fetch(
                `${SUPABASE_URL}/rest/v1/hubs?hub_id=eq.${hubId}`,
                {
                    method: 'PATCH',
                    headers: supabaseHeaders,
                    body: JSON.stringify({ is_active: false }),
                }
            );
            if (!res.ok) throw new Error('Failed to deactivate hub');
            setHubs(prev => prev.map(h => h.hub_id === hubId ? { ...h, is_active: false } : h));
        } catch (err) {
            alert(err.message);
        }
    };

    const cancelAdding = () => {
        setIsAddingHub(false);
        setPendingLatLng(null);
        setShowForm(false);
        setFormError('');
    };

    // ─────────────────────────────────────────────────────────────────────────
    return (
        <div className="fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem', height: '100%' }}>

            {/* ── Page Header ────────────────────────────────────────────── */}
            <div className="page-header">
                <div>
                    <h1 className="page-title">Hub Network</h1>
                    <p className="page-subtitle">View and manage delivery hubs across India on the map.</p>
                </div>
                <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'center' }}>
                    <button
                        className="btn-icon"
                        onClick={fetchHubs}
                        title="Refresh"
                        style={{ width: 36, height: 36 }}
                    >
                        <RefreshCw size={16} />
                    </button>
                    {isAddingHub ? (
                        <button
                            className="primary-btn"
                            onClick={cancelAdding}
                            style={{ background: 'var(--bg-secondary)', border: '1px solid var(--accent-danger)', color: 'var(--accent-danger)', boxShadow: 'none' }}
                        >
                            <X size={14} style={{ marginRight: 6 }} /> Cancel Adding
                        </button>
                    ) : (
                        <button className="primary-btn" onClick={() => setIsAddingHub(true)}>
                            <Plus size={14} style={{ marginRight: 6 }} /> Add Hub
                        </button>
                    )}
                </div>
            </div>

            {/* ── Stats Row ──────────────────────────────────────────────── */}
            {!loading && <HubStats hubs={hubs} />}

            {/* ── Filters + Legend ─────────────────────────────────────── */}
            <div style={{
                display: 'flex', gap: '1rem', alignItems: 'center',
                flexWrap: 'wrap',
                background: 'var(--bg-secondary)',
                borderRadius: 'var(--radius-md)',
                padding: '0.75rem 1rem',
                border: '1px solid var(--border-light)',
            }}>
                <Filter size={14} color="var(--text-secondary)" />
                <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginRight: 4 }}>Filter:</span>

                {/* Hub Type */}
                <select
                    value={filterType}
                    onChange={e => setFilterType(e.target.value)}
                    style={selectStyle}
                >
                    <option value="all">All Types</option>
                    <option value="national">National</option>
                    <option value="regional">Regional</option>
                    <option value="local">Local</option>
                </select>

                {/* Region */}
                <select
                    value={filterRegion}
                    onChange={e => setFilterRegion(e.target.value)}
                    style={selectStyle}
                >
                    <option value="all">All Regions</option>
                    <option value="north">North</option>
                    <option value="south">South</option>
                    <option value="east">East</option>
                    <option value="west">West</option>
                    <option value="central">Central</option>
                </select>

                <div style={{ marginLeft: 'auto', display: 'flex', gap: '1rem', alignItems: 'center' }}>
                    {[
                        { label: 'National', color: '#FFD700' },
                        { label: 'Regional', color: '#3B82F6' },
                        { label: 'Local',    color: '#10B981' },
                    ].map(({ label, color }) => (
                        <div key={label} style={{ display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
                            <div style={{ width: 10, height: 10, borderRadius: '50%', background: color, border: '1.5px solid white', boxShadow: `0 0 0 1.5px ${color}` }} />
                            <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{label}</span>
                        </div>
                    ))}
                </div>
            </div>

            {/* ── Add Hub Banner ─────────────────────────────────────────── */}
            {isAddingHub && !showForm && (
                <div style={{
                    background: 'rgba(249,115,22,0.1)',
                    border: '1px solid rgba(249,115,22,0.4)',
                    borderRadius: 'var(--radius-md)',
                    padding: '0.75rem 1.25rem',
                    fontSize: '0.875rem',
                    color: '#F97316',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.5rem',
                }}>
                    <MapPin size={16} />
                    <strong>Click anywhere on the map</strong> to place a new hub marker.
                </div>
            )}

            {/* ── Map + Sidebar ─────────────────────────────────────────── */}
            <div style={{ display: 'flex', gap: '1rem', flex: 1, minHeight: '520px' }}>

                {/* Map */}
                <div style={{
                    flex: 1,
                    borderRadius: 'var(--radius-lg)',
                    overflow: 'hidden',
                    border: '1px solid var(--border-light)',
                    cursor: isAddingHub ? 'crosshair' : 'grab',
                    position: 'relative',
                }}>
                    {loading && (
                        <div style={{
                            position: 'absolute', inset: 0, zIndex: 999,
                            background: 'rgba(0,0,0,0.5)', display: 'flex',
                            alignItems: 'center', justifyContent: 'center',
                            color: 'white', fontSize: '0.9rem',
                        }}>
                            Loading hubs...
                        </div>
                    )}
                    {error && (
                        <div style={{
                            position: 'absolute', inset: 0, zIndex: 999,
                            background: 'rgba(0,0,0,0.7)', display: 'flex',
                            alignItems: 'center', justifyContent: 'center',
                            color: 'var(--accent-danger)', fontSize: '0.9rem', padding: '2rem', textAlign: 'center',
                        }}>
                            {error}
                        </div>
                    )}

                    <MapContainer
                        center={[20.5937, 78.9629]} // Center of India
                        zoom={5}
                        style={{ width: '100%', height: '100%' }}
                        zoomControl={true}
                    >
                        <TileLayer
                            url="https://tile.openstreetmap.org/{z}/{x}/{y}.png"
                            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                            maxZoom={19}
                        />

                        <MapClickHandler
                            onMapClick={handleMapClick}
                            isAddingHub={isAddingHub}
                        />

                        {/* Pending new hub marker */}
                        {pendingLatLng && (
                            <Marker position={pendingLatLng} icon={NEW_HUB_ICON}>
                                <Popup>New Hub Location<br />{pendingLatLng.lat.toFixed(4)}, {pendingLatLng.lng.toFixed(4)}</Popup>
                            </Marker>
                        )}

                        {/* Existing hub markers */}
                        {visibleHubs.map(hub => (
                            <Marker
                                key={hub.hub_id}
                                position={[hub.lat, hub.lng]}
                                icon={HUB_ICONS[hub.hub_type] || HUB_ICONS.local}
                            >
                                <Popup>
                                    <div style={{ minWidth: 160 }}>
                                        <div style={{ fontWeight: 700, fontSize: '0.95rem', marginBottom: 4 }}>
                                            {hub.hub_name}
                                        </div>
                                        <div style={{ fontSize: '0.8rem', color: '#555', marginBottom: 2 }}>
                                            <b>Type:</b> {hub.hub_type.charAt(0).toUpperCase() + hub.hub_type.slice(1)}
                                        </div>
                                        <div style={{ fontSize: '0.8rem', color: '#555', marginBottom: 2 }}>
                                            <b>Region:</b> {hub.region.charAt(0).toUpperCase() + hub.region.slice(1)}
                                        </div>
                                        <div style={{ fontSize: '0.75rem', color: '#888', marginBottom: 8 }}>
                                            {hub.lat.toFixed(4)}, {hub.lng.toFixed(4)}
                                        </div>
                                        <button
                                            onClick={() => handleDeleteHub(hub.hub_id)}
                                            style={{
                                                width: '100%', padding: '4px', fontSize: '0.75rem',
                                                background: 'rgba(239,68,68,0.1)',
                                                border: '1px solid rgba(239,68,68,0.3)',
                                                borderRadius: 4, color: '#ef4444', cursor: 'pointer',
                                            }}
                                        >
                                            Deactivate Hub
                                        </button>
                                    </div>
                                </Popup>
                            </Marker>
                        ))}
                    </MapContainer>
                </div>

                {/* ── Add Hub Form Sidebar ───────────────────────────────── */}
                {showForm && pendingLatLng && (
                    <div style={{
                        width: '280px',
                        background: 'var(--bg-secondary)',
                        borderRadius: 'var(--radius-lg)',
                        border: '1px solid var(--border-light)',
                        padding: '1.5rem',
                        display: 'flex',
                        flexDirection: 'column',
                        gap: '1rem',
                        animation: 'fadeIn 0.2s ease',
                    }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                            <h3 style={{ margin: 0, fontSize: '1rem', fontWeight: 700 }}>New Hub</h3>
                            <button className="btn-icon" onClick={cancelAdding} style={{ width: 28, height: 28 }}>
                                <X size={14} />
                            </button>
                        </div>

                        {/* Coordinates display */}
                        <div style={{
                            background: 'rgba(249,115,22,0.08)',
                            border: '1px solid rgba(249,115,22,0.25)',
                            borderRadius: 'var(--radius-sm)',
                            padding: '0.6rem',
                            fontSize: '0.75rem',
                            color: '#F97316',
                        }}>
                            <MapPin size={12} style={{ marginRight: 6, verticalAlign: 'middle' }} />
                            {pendingLatLng.lat.toFixed(5)}, {pendingLatLng.lng.toFixed(5)}
                        </div>

                        <form onSubmit={handleSubmitHub} style={{ display: 'flex', flexDirection: 'column', gap: '0.85rem' }}>

                            <div>
                                <label style={labelStyle}>Hub Name *</label>
                                <input
                                    type="text"
                                    placeholder="e.g. Hyderabad Hub"
                                    value={formData.hub_name}
                                    onChange={e => setFormData(p => ({ ...p, hub_name: e.target.value }))}
                                    style={inputStyle}
                                    autoFocus
                                />
                            </div>

                            <div>
                                <label style={labelStyle}>Hub Type</label>
                                <select
                                    value={formData.hub_type}
                                    onChange={e => setFormData(p => ({ ...p, hub_type: e.target.value }))}
                                    style={inputStyle}
                                >
                                    <option value="national">National</option>
                                    <option value="regional">Regional</option>
                                    <option value="local">Local</option>
                                </select>
                            </div>

                            <div>
                                <label style={labelStyle}>Region</label>
                                <select
                                    value={formData.region}
                                    onChange={e => setFormData(p => ({ ...p, region: e.target.value }))}
                                    style={inputStyle}
                                >
                                    <option value="north">North</option>
                                    <option value="south">South</option>
                                    <option value="east">East</option>
                                    <option value="west">West</option>
                                    <option value="central">Central</option>
                                </select>
                            </div>

                            {formError && (
                                <div style={{ fontSize: '0.8rem', color: 'var(--accent-danger)', background: 'rgba(239,68,68,0.1)', borderRadius: 'var(--radius-sm)', padding: '0.5rem 0.75rem' }}>
                                    {formError}
                                </div>
                            )}

                            <button
                                type="submit"
                                className="primary-btn"
                                disabled={submitting}
                                style={{ marginTop: '0.25rem' }}
                            >
                                {submitting ? 'Saving...' : '✓ Save Hub'}
                            </button>
                        </form>
                    </div>
                )}
            </div>

            {/* ── Hubs Table ──────────────────────────────────────────────── */}
            <div className="table-container" style={{ marginTop: '0.5rem' }}>
                <div className="table-header">
                    <span className="table-title">
                        <Layers size={14} style={{ marginRight: 6, verticalAlign: 'middle' }} />
                        Hub List ({visibleHubs.length})
                    </span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Hub ID</th>
                            <th>Hub Name</th>
                            <th>Type</th>
                            <th>Region</th>
                            <th>Latitude</th>
                            <th>Longitude</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr><td colSpan="7" style={{ textAlign: 'center', padding: '2rem' }}>Loading hubs...</td></tr>
                        ) : error ? (
                            <tr><td colSpan="7" style={{ textAlign: 'center', padding: '2rem', color: 'var(--accent-danger)' }}>{error}</td></tr>
                        ) : visibleHubs.length === 0 ? (
                            <tr><td colSpan="7" style={{ textAlign: 'center', padding: '2rem' }}>No hubs match the selected filters.</td></tr>
                        ) : (
                            visibleHubs.map(hub => (
                                <tr key={hub.hub_id}>
                                    <td>#{hub.hub_id}</td>
                                    <td style={{ fontWeight: 600 }}>{hub.hub_name}</td>
                                    <td>
                                        <span className={`status-badge ${
                                            hub.hub_type === 'national' ? 'status-warning' :
                                            hub.hub_type === 'regional' ? 'status-info' : 'status-success'
                                        }`}>
                                            {hub.hub_type.charAt(0).toUpperCase() + hub.hub_type.slice(1)}
                                        </span>
                                    </td>
                                    <td style={{ textTransform: 'capitalize' }}>{hub.region}</td>
                                    <td style={{ fontFamily: 'monospace', fontSize: '0.82rem', color: 'var(--text-secondary)' }}>{hub.lat.toFixed(4)}</td>
                                    <td style={{ fontFamily: 'monospace', fontSize: '0.82rem', color: 'var(--text-secondary)' }}>{hub.lng.toFixed(4)}</td>
                                    <td>
                                        <span className={`status-badge ${hub.is_active ? 'status-success' : 'status-danger'}`}>
                                            {hub.is_active ? 'Active' : 'Inactive'}
                                        </span>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

// ─── Style helpers ───────────────────────────────────────────────────────────
const selectStyle = {
    background: 'var(--bg-tertiary, #1a1a2e)',
    border: '1px solid var(--border-light)',
    color: 'var(--text-primary)',
    borderRadius: 'var(--radius-sm)',
    padding: '0.3rem 0.6rem',
    fontSize: '0.8rem',
    cursor: 'pointer',
};

const inputStyle = {
    width: '100%',
    background: 'var(--bg-primary)',
    border: '1px solid var(--border-light)',
    color: 'var(--text-primary)',
    borderRadius: 'var(--radius-sm)',
    padding: '0.55rem 0.75rem',
    fontSize: '0.85rem',
    boxSizing: 'border-box',
    outline: 'none',
};

const labelStyle = {
    display: 'block',
    fontSize: '0.75rem',
    color: 'var(--text-secondary)',
    marginBottom: '0.35rem',
    fontWeight: 600,
    textTransform: 'uppercase',
    letterSpacing: '0.05em',
};

export default Hubs;
