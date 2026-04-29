import React, { useState, useEffect } from 'react';
import { Shield, Users, Lock, Unlock, RefreshCw } from 'lucide-react';

const Roles = () => {
    const [roles, setRoles] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const fetchRoles = async () => {
        setLoading(true);
        setError(null);
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/roles`);
            if (res.ok) {
                const data = await res.json();
                setRoles(data);
            } else {
                setError('Failed to fetch roles from server');
            }
        } catch (err) {
            setError('Error connecting to backend');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchRoles();
    }, []);

    return (
        <div className="fade-in">
            <div className="page-header">
                <div>
                    <h1 className="page-title">Roles & Access Management</h1>
                    <p className="page-subtitle">Configure system roles and permission mapping.</p>
                </div>
                <div style={{ display: 'flex', gap: '0.5rem' }}>
                    <button className="primary-btn" onClick={fetchRoles} style={{ background: 'var(--bg-secondary)', border: '1px solid var(--border-light)', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                        <RefreshCw size={16} /> Refresh
                    </button>
                    <button className="primary-btn"><Shield size={16} /> Create Custom Role</button>
                </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(400px, 1fr))', gap: '1.5rem' }}>
                {loading ? (
                    <div style={{ padding: '2rem', textAlign: 'center', gridColumn: '1 / -1' }}>Loading roles...</div>
                ) : error ? (
                    <div style={{ padding: '2rem', textAlign: 'center', gridColumn: '1 / -1', color: 'var(--accent-danger)' }}>{error}</div>
                ) : roles.length === 0 ? (
                    <div style={{ padding: '2rem', textAlign: 'center', gridColumn: '1 / -1' }}>No roles found.</div>
                ) : (
                    roles.map((role) => (
                        <div key={role.role_id} className="panel" style={{ position: 'relative', overflow: 'hidden' }}>
                            {role.role_name !== 'admin' && <div style={{ position: 'absolute', top: '10px', right: '10px' }}><span className="status-badge status-neutral">External</span></div>}

                            <h3 className="panel-title" style={{ fontSize: '1.2rem', color: role.role_name === 'admin' ? 'var(--accent-success)' : 'var(--accent-primary)' }}>
                                {role.role_name === 'admin' ? <Shield size={20} /> : <Lock size={20} />}
                                {role.role_name.charAt(0).toUpperCase() + role.role_name.slice(1)}
                            </h3>
                            <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '1.5rem' }}>
                                Details for role: {role.role_name}
                            </p>

                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderTop: '1px solid var(--border-light)', paddingTop: '1rem' }}>
                                <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '0.875rem', fontWeight: 600 }}>
                                    <Users size={16} color="var(--text-muted)" /> ID: {role.role_id}
                                </span>
                                <button className="primary-btn" style={{ padding: '0.4rem 0.8rem', background: 'transparent', border: '1px solid var(--border-light)', color: 'var(--text-primary)', boxShadow: 'none' }}>
                                    Manage Access
                                </button>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
};

export default Roles;
