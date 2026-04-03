import React, { useState, useEffect } from 'react';
import { MoreHorizontal, AlertOctagon, CheckCircle, ArrowLeft, RefreshCw } from 'lucide-react';

const Complaints = () => {
    const [complaints, setComplaints] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selectedComplaint, setSelectedComplaint] = useState(null);

    const fetchComplaints = async () => {
        setLoading(true);
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/complaints`);
            if (res.ok) {
                const data = await res.json();
                setComplaints(data);
            }
        } catch (error) {
            console.error('Error fetching complaints:', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchComplaints();
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
                        <div className="info-row"><span className="info-label">Resolved Date</span><span className="info-value" style={{ color: 'var(--text-muted)' }}>{selectedComplaint.resolved_at ? new Date(selectedComplaint.resolved_at).toLocaleString() : 'Not Resolved'}</span></div>
                    </div>

                    <div className="panel">
                        <h3 className="panel-title">Resolution Log</h3>
                        <div style={{ background: 'rgba(255,255,255,0.02)', padding: '1rem', borderRadius: 'var(--radius-md)', marginBottom: '1rem', borderLeft: '3px solid var(--accent-primary)' }}>
                            <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginBottom: '4px' }}>Oct 12, 08:45 PM - Agent: Support01</div>
                            <div style={{ fontSize: '0.875rem' }}>Contacted delivery partner. He mentioned flat tire on the way. Waiting for update.</div>
                        </div>

                        <textarea
                            className="header-search"
                            style={{ width: '100%', height: '100px', resize: 'none', padding: '1rem', background: 'var(--bg-primary)', margin: '1rem 0' }}
                            placeholder="Add resolution notes..."
                        ></textarea>

                        <div style={{ display: 'flex', gap: '1rem' }}>
                            <button className="primary-btn" style={{ flex: 1, background: 'var(--bg-secondary)', border: '1px solid var(--border-light)' }}>Add Note Log</button>
                            <button className="primary-btn" style={{ flex: 1, background: 'var(--accent-success)' }}><CheckCircle size={16} /> Mark Resolved</button>
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
