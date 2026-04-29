import React, { useState, useEffect } from 'react';
import { MoreHorizontal, AlertOctagon, CheckCircle, ArrowLeft, RefreshCw } from 'lucide-react';

const Complaints = () => {
    const [complaints, setComplaints] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selectedComplaint, setSelectedComplaint] = useState(null);
    const [adminNote, setAdminNote] = useState('');

    const fetchComplaints = async (isAuto = false) => {
        if (!isAuto) setLoading(true);
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/complaints`);
            if (res.ok) {
                const data = await res.json();
                setComplaints(data);
            }
        } catch (error) {
            console.error('Error fetching complaints:', error);
        } finally {
            if (!isAuto) setLoading(false);
        }
    };

    const handleResolve = async () => {
        if (!adminNote.trim()) {
            alert('Please provide resolution notes.');
            return;
        }

        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/complaints/${selectedComplaint.complaint_id}/resolve`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ admin_note: adminNote })
            });

            if (res.ok) {
                alert('Complaint resolved successfully');
                setSelectedComplaint(null);
                setAdminNote('');
                fetchComplaints();
            } else {
                const errData = await res.json().catch(() => ({}));
                alert('Failed to resolve: ' + (errData.error || errData.message || 'Server error'));
            }
        } catch (err) {
            alert('Error resolving complaint: ' + err.message);
        }
    };

    useEffect(() => {
        fetchComplaints();
        const interval = setInterval(() => {
            fetchComplaints(true);
        }, 10000); // 10s auto-refresh
        return () => clearInterval(interval);
    }, []);

    if (selectedComplaint) {
        return (
            <div className="fade-in">
                <div className="details-header">
                    <button className="back-btn" onClick={() => setSelectedComplaint(null)}><ArrowLeft size={16} /></button>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                        <h1 className="page-title">Complaint: #CMP-{selectedComplaint.complaint_id}</h1>
                        <span className={`status-badge ${selectedComplaint.complaint_status_name === 'Resolved' ? 'status-success' : 'status-danger'}`}>
                            {selectedComplaint.complaint_status_name || 'Pending'}
                        </span>
                    </div>
                </div>

                <div className="grid-2-cols">
                    <div className="panel">
                        <h3 className="panel-title" style={{ color: 'var(--accent-danger)' }}>Complaint Details</h3>
                        <div className="info-row"><span className="info-label">Complaint ID</span><span className="info-value">#CMP-{selectedComplaint.complaint_id}</span></div>
                        <div className="info-row"><span className="info-label">Order ID</span><span className="info-value" style={{ color: 'var(--accent-primary)', cursor: 'pointer' }}>#ORD-{selectedComplaint.order_id}</span></div>
                        <div className="info-row"><span className="info-label">User ID</span><span className="info-value">#USR-{selectedComplaint.user_id} ({selectedComplaint.first_name || ''} {selectedComplaint.last_name || ''})</span></div>
                        <div className="info-row"><span className="info-label">Complaint Type</span><span className="info-value">{selectedComplaint.complaint_type_name || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Description</span><span className="info-value" style={{ lineHeight: '1.5', marginTop: '4px' }}>{selectedComplaint.description}</span></div>
                        <div className="info-row"><span className="info-label">Created Date</span><span className="info-value">{new Date(selectedComplaint.created_at).toLocaleString()}</span></div>
                        <div className="info-row"><span className="info-label">Status</span><span className="info-value" style={{ color: 'var(--text-muted)' }}>{selectedComplaint.complaint_status_name}</span></div>
                        {selectedComplaint.admin_note && (
                            <div className="info-row"><span className="info-label">Admin Resolution Note</span><span className="info-value">{selectedComplaint.admin_note}</span></div>
                        )}
                    </div>

                    <div className="panel">
                        <h3 className="panel-title">Resolution Actions</h3>
                        {selectedComplaint.complaint_status_name !== 'Resolved' ? (
                            <>
                                <div style={{ fontSize: '0.875rem', marginBottom: '8px' }}>Add resolution details below:</div>
                                <textarea
                                    className="header-search"
                                    style={{ width: '100%', height: '120px', resize: 'none', padding: '1rem', background: 'var(--bg-primary)', margin: '0.5rem 0' }}
                                    placeholder="Enter final resolution steps or why it was closed..."
                                    value={adminNote}
                                    onChange={(e) => setAdminNote(e.target.value)}
                                ></textarea>

                                <div style={{ display: 'flex', gap: '1rem' }}>
                                    <button className="primary-btn" style={{ flex: 1, background: 'var(--accent-success)' }} onClick={handleResolve}><CheckCircle size={16} /> Mark Resolved</button>
                                </div>
                            </>
                        ) : (
                            <div style={{ textAlign: 'center', padding: '2rem' }}>
                                <CheckCircle size={48} color="var(--accent-success)" style={{ marginBottom: '1rem' }} />
                                <h3>Resolved</h3>
                                <p style={{ color: 'var(--text-muted)' }}>This complaint has been addressed by an administrator.</p>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="fade-in">
            <div className="page-header">
                <div>
                    <h1 className="page-title">Complaints & Support</h1>
                    <p className="page-subtitle">Resolve disputes from users, partners, and businesses.</p>
                </div>
                <button className="primary-btn" onClick={fetchComplaints} style={{ background: 'var(--bg-secondary)', border: '1px solid var(--border-light)', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <RefreshCw size={16} /> Refresh
                </button>
            </div>

            <div className="table-container">
                <div className="table-header">
                    <span className="table-title">Complaint List</span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Complaint ID</th>
                            <th>Order ID</th>
                            <th>User / Reporter</th>
                            <th>Type</th>
                            <th>Description Snippet</th>
                            <th>Status</th>
                            <th>Created Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr><td colSpan="8" style={{ textAlign: 'center', padding: '2rem' }}>Loading complaints...</td></tr>
                        ) : complaints.length === 0 ? (
                            <tr><td colSpan="8" style={{ textAlign: 'center', padding: '2rem' }}>No complaints found.</td></tr>
                        ) : (
                            complaints.map((item) => (
                                <tr key={item.complaint_id}>
                                    <td><span style={{ fontWeight: 600 }}>#CMP-{item.complaint_id}</span></td>
                                    <td><span style={{ color: 'var(--accent-primary)', cursor: 'pointer' }}>#ORD-{item.order_id}</span></td>
                                    <td><span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{item.first_name} {item.last_name}</span><br />#USR-{item.user_id}</td>
                                    <td>
                                        {item.complaint_type_name || 'N/A'}
                                    </td>
                                    <td style={{ fontSize: '0.75rem', maxWidth: '200px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                                        {item.description}
                                    </td>
                                    <td>
                                        <span className={`status-badge ${item.complaint_status_name === 'Resolved' ? 'status-success' : 'status-danger'}`}>
                                            {item.complaint_status_name === 'Pending' && <AlertOctagon size={12} style={{ marginRight: '4px' }} />}
                                            {item.complaint_status_name || 'Pending'}
                                        </span>
                                    </td>
                                    <td>{new Date(item.created_at).toLocaleString()}</td>
                                    <td>
                                        <button className="btn-icon" onClick={() => setSelectedComplaint(item)}><MoreHorizontal size={16} /></button>
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

export default Complaints;
