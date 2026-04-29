import React, { useState, useEffect } from 'react';
import { MoreHorizontal, Edit, Edit2, Trash2, X, UserPlus, Ban } from 'lucide-react';

const Users = () => {
    const [selectedUser, setSelectedUser] = useState(null);
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [currentLocation, setCurrentLocation] = useState('Location Unavailable');
    const [showAddModal, setShowAddModal] = useState(false);
    const [formData, setFormData] = useState({
        first_name: '',
        last_name: '',
        email: '',
        phone: '',
        password: 'Password@123',
        role_id: 5 // Default: Customer
    });

    const fetchUsers = async (showLoading = true) => {
        if (showLoading) setLoading(true);
        try {
            const response = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/all`);
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

    const handleToggleBan = async (user) => {
        if (!window.confirm(`Are you sure you want to ${user.is_banned ? 'unban' : 'ban'} this user?`)) return;
        try {
            const response = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/${user.user_id}/toggle-ban`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ is_banned: !user.is_banned })
            });
            if (response.ok) {
                const updatedUser = { ...user, is_banned: !user.is_banned };
                setUsers(users.map(u => u.user_id === user.user_id ? updatedUser : u));
                if (selectedUser?.user_id === user.user_id) setSelectedUser(updatedUser);
            }
        } catch (err) {
            alert('Error toggling ban: ' + err.message);
        }
    };

    const handleDeleteUser = async (user) => {
        if (!window.confirm('Are you sure you want to delete this user? This cannot be undone.')) return;
        try {
            const response = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/${user.user_id}`, {
                method: 'DELETE'
            });
            const data = await response.json();
            if (response.ok) {
                setUsers(users.filter(u => u.user_id !== user.user_id));
                alert('User deleted successfully');
            } else {
                alert(data.error || 'Failed to delete user');
            }
        } catch (err) {
            alert('Error deleting user: ' + err.message);
        }
    };

    const handleAddUser = async (e) => {
        e.preventDefault();
        try {
            const response = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/admin-create`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData)
            });
            if (response.ok) {
                alert('User created successfully');
                setShowAddModal(false);
                fetchUsers(true);
            } else {
                const data = await response.json();
                alert('Failed to create user: ' + data.error);
            }
        } catch (err) {
            alert('Error creating user: ' + err.message);
        }
    };

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
                            <button 
                                className="primary-btn" 
                                style={{ background: 'var(--bg-secondary)', border: '1px solid var(--accent-danger)', color: 'var(--accent-danger)', boxShadow: 'none' }}
                                onClick={() => handleToggleBan(selectedUser)}
                            >
                                {selectedUser.is_banned ? 'Unban User' : 'Ban User'}
                            </button>
                            <button className="primary-btn" style={{ background: 'var(--bg-secondary)', border: '1px solid var(--accent-warning)', color: 'var(--accent-warning)', boxShadow: 'none' }}>Verify Account</button>
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
                <button className="primary-btn" onClick={() => setShowAddModal(true)}>+ Add User</button>
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
                        {loading && users.length === 0 ? (
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
                                            <button className="btn-icon" onClick={() => handleToggleBan(user)} title={user.is_banned ? 'Unban User' : 'Ban User'}>
                                                <Ban size={16} color={user.is_banned ? 'var(--accent-success)' : 'var(--accent-danger)'} />
                                            </button>
                                            <button className="btn-icon" onClick={() => handleDeleteUser(user)}><Trash2 size={16} color="var(--accent-danger)" /></button>
                                        </div>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>

            {/* Add User Modal */}
            {showAddModal && (
                <div className="modal-overlay">
                    <div className="modal-content" style={{ maxWidth: '500px' }}>
                        <div className="modal-header">
                            <h2 className="modal-title">Add New User</h2>
                            <button className="close-btn" onClick={() => setShowAddModal(false)}><X /></button>
                        </div>
                        <form onSubmit={handleAddUser}>
                            <div className="info-row" style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', border: 'none' }}>
                                <label>First Name</label>
                                <input type="text" className="search-input" style={{ width: '100%' }} onChange={(e) => setFormData({...formData, first_name: e.target.value})} required />
                            </div>
                            <div className="info-row" style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', border: 'none' }}>
                                <label>Last Name</label>
                                <input type="text" className="search-input" style={{ width: '100%' }} onChange={(e) => setFormData({...formData, last_name: e.target.value})} required />
                            </div>
                            <div className="info-row" style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', border: 'none' }}>
                                <label>Email</label>
                                <input type="email" className="search-input" style={{ width: '100%' }} onChange={(e) => setFormData({...formData, email: e.target.value})} required />
                            </div>
                            <div className="info-row" style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', border: 'none' }}>
                                <label>Phone</label>
                                <input type="text" className="search-input" style={{ width: '100%' }} onChange={(e) => setFormData({...formData, phone: e.target.value})} required />
                            </div>
                            <div className="info-row" style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', border: 'none' }}>
                                <label>Role</label>
                                <select className="search-input" style={{ width: '100%' }} onChange={(e) => setFormData({...formData, role_id: parseInt(e.target.value)})}>
                                    <option value="5">Customer</option>
                                    <option value="8">Business Employee</option>
                                </select>
                            </div>
                            <div style={{ marginTop: '2rem', display: 'flex', gap: '1rem' }}>
                                <button type="submit" className="primary-btn" style={{ flex: 1 }}>Create User</button>
                                <button type="button" className="primary-btn" style={{ flex: 1, background: 'var(--bg-secondary)', color: 'var(--text-primary)' }} onClick={() => setShowAddModal(false)}>Cancel</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Users;
