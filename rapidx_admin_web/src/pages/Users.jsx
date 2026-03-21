import React, { useState, useEffect } from 'react';
import { MoreHorizontal, Edit, Edit2, Trash2 } from 'lucide-react';

const Users = () => {
    const [selectedUser, setSelectedUser] = useState(null);
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [currentLocation, setCurrentLocation] = useState('Location Unavailable');

    useEffect(() => {
        if (selectedUser && selectedUser.current_lat && selectedUser.current_lng) {
            setCurrentLocation('Fetching GPS coordinates...');
            fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${selectedUser.current_lat}&lon=${selectedUser.current_lng}`)
                .then(res => res.json())
                .then(data => setCurrentLocation(data.display_name || 'Location Not Found'))
                .catch(() => setCurrentLocation('Error fetching location'));
        } else {
            setCurrentLocation('Location Unavailable');
        }
    }, [selectedUser]);

    const fetchUsers = async (showLoading = true) => {
        if (showLoading) setLoading(true);
        try {
            const response = await fetch('http://localhost:3000/api/users/all');
            if (!response.ok) {
                throw new Error('Failed to fetch users');
            }
            const data = await response.json();
            setUsers(data);
        } catch (err) {
            setError(err.message);
        } finally {
            if (showLoading) setLoading(false);
        }
    };

    useEffect(() => {
        fetchUsers(true);
        const interval = setInterval(() => fetchUsers(false), 5000);
        return () => clearInterval(interval);
    }, []);

    if (selectedUser) {
        return (
            <div className="fade-in">
                <div className="details-header">
                    <button className="back-btn" onClick={() => setSelectedUser(null)}>←</button>
                    <h1 className="page-title">User Details: #{selectedUser.user_id}</h1>
                </div>

                <div className="grid-2-cols">
                    <div className="panel">
                        <h3 className="panel-title">Basic Information</h3>
                        <div className="info-row"><span className="info-label">First Name</span><span className="info-value">{selectedUser.first_name || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Last Name</span><span className="info-value">{selectedUser.last_name || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Email</span><span className="info-value">{selectedUser.email || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Phone</span><span className="info-value">{selectedUser.phone || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Role</span><span className="info-value">{selectedUser.role_name || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Account Status</span><span className="info-value"><span className={`status-badge ${selectedUser.is_banned ? 'status-danger' : 'status-success'}`}>{selectedUser.is_banned ? 'Banned' : 'Active'}</span></span></div>
                        <div className="info-row"><span className="info-label">Current GPS Location</span><span className="info-value">{currentLocation}</span></div>
                    </div>

                    <div className="panel">
                        <h3 className="panel-title">Addresses</h3>
                        <div className="info-row"><span className="info-label">Address Type</span><span className="info-value">Home <span className="status-badge status-info">Default Address</span></span></div>
                        <div className="info-row"><span className="info-label">Address</span><span className="info-value">123, MG Road</span></div>
                        <div className="info-row"><span className="info-label">City</span><span className="info-value">Mumbai</span></div>
                        <div className="info-row"><span className="info-label">State</span><span className="info-value">Maharashtra</span></div>
                        <div className="info-row"><span className="info-label">Pincode</span><span className="info-value">400001</span></div>
                    </div>

                    <div className="panel" style={{ gridColumn: 'span 2' }}>
                        <h3 className="panel-title" style={{ color: 'var(--accent-danger)' }}>Account Controls</h3>
                        <div style={{ display: 'flex', gap: '1rem', marginTop: '1rem' }}>
                            <button className="primary-btn" style={{ background: 'var(--bg-secondary)', border: '1px solid var(--accent-danger)', color: 'var(--accent-danger)', boxShadow: 'none' }}>Ban / Unban User</button>
                            <button className="primary-btn" style={{ background: 'var(--bg-secondary)', border: '1px solid var(--accent-warning)', color: 'var(--accent-warning)', boxShadow: 'none' }}>Reset Password</button>
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="fade-in">
            <div className="page-header">
                <div>
                    <h1 className="page-title">Users</h1>
                    <p className="page-subtitle">Manage system users, customers, and their accounts.</p>
                </div>
                <button className="primary-btn">+ Add User</button>
            </div>

            <div className="table-container">
                <div className="table-header">
                    <span className="table-title">User List</span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>User ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Created Date</th>
                            <th>Account Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr>
                                <td colSpan="8" style={{ textAlign: 'center', padding: '2rem' }}>Loading users...</td>
                            </tr>
                        ) : error ? (
                            <tr>
                                <td colSpan="8" style={{ textAlign: 'center', padding: '2rem', color: 'var(--accent-danger)' }}>{error}</td>
                            </tr>
                        ) : users.filter(u => u.role_id === 5 || u.role_id === 8).length === 0 ? (
                            <tr>
                                <td colSpan="8" style={{ textAlign: 'center', padding: '2rem' }}>No users found</td>
                            </tr>
                        ) : (
                            users.filter(u => u.role_id === 5 || u.role_id === 8).map((user) => (
                                <tr key={user.user_id}>
                                    <td>#{user.user_id}</td>
                                    <td>{user.first_name || ''} {user.last_name || ''}</td>
                                    <td>{user.email || 'N/A'}</td>
                                    <td>{user.phone || 'N/A'}</td>
                                    <td>{user.role_name || 'N/A'}</td>
                                    <td>{user.created_at ? new Date(user.created_at).toLocaleDateString() : 'N/A'}</td>
                                    <td><span className={`status-badge ${user.is_banned ? 'status-danger' : 'status-success'}`}>{user.is_banned ? 'Banned' : 'Active'}</span></td>
                                    <td>
                                        <div className="td-actions">
                                            <button className="btn-icon" onClick={() => setSelectedUser(user)}><MoreHorizontal size={16} /></button>
                                            <button className="btn-icon"><Edit2 size={16} /></button>
                                            <button className="btn-icon"><Trash2 size={16} color="var(--accent-danger)" /></button>
                                        </div>
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

export default Users;
