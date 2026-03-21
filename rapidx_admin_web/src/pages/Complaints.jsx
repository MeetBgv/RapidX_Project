import React, { useState } from 'react';
import { MoreHorizontal, AlertOctagon, CheckCircle } from 'lucide-react';

const Complaints = () => {
    const [viewDetails, setViewDetails] = useState(false);

    if (viewDetails) {
        return (
            <div className="fade-in">
                <div className="details-header">
                    <button className="back-btn" onClick={() => setViewDetails(false)}>←</button>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                        <h1 className="page-title">Complaint: #CMP-8302</h1>
                        <span className="status-badge status-danger">Pending Resolution</span>
                    </div>
                </div>

                <div className="grid-2-cols">
                    <div className="panel">
                        <h3 className="panel-title" style={{ color: 'var(--accent-danger)' }}>Complaint Details</h3>
                        <div className="info-row"><span className="info-label">Complaint ID</span><span className="info-value">#CMP-8302</span></div>
                        <div className="info-row"><span className="info-label">Order ID</span><span className="info-value" style={{ color: 'var(--accent-primary)', cursor: 'pointer' }}>#ORD-99382</span></div>
                        <div className="info-row"><span className="info-label">User ID</span><span className="info-value">#USR-10294 (Rahul S.)</span></div>
                        <div className="info-row"><span className="info-label">Complaint Type</span><span className="info-value">Late Delivery</span></div>
                        <div className="info-row"><span className="info-label">Description</span><span className="info-value" style={{ lineHeight: '1.5', marginTop: '4px' }}>The package was promised by 6 PM today but it is still showing as 'In Transit'. Tracking hasn't updated for 4 hours.</span></div>
                        <div className="info-row"><span className="info-label">Created Date</span><span className="info-value">Oct 12, 08:30 PM</span></div>
                        <div className="info-row"><span className="info-label">Resolved Date</span><span className="info-value" style={{ color: 'var(--text-muted)' }}>Not Resolved</span></div>
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
                        {[1, 2, 3, 4, 5].map((item) => (
                            <tr key={item}>
                                <td><span style={{ fontWeight: 600 }}>#CMP-830{item}</span></td>
                                <td><span style={{ color: 'var(--accent-primary)', cursor: 'pointer' }}>#ORD-993{item}4</span></td>
                                <td><span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Rahul S.</span><br />#USR-1029{item}</td>
                                <td>
                                    {item === 1 ? 'Late Delivery' :
                                        item === 2 ? 'Damaged Item' :
                                            item === 3 ? 'Payment Issue' : 'Delivery Partner Issue'}
                                </td>
                                <td style={{ fontSize: '0.75rem', maxWidth: '200px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                                    "The package was promised by 6 PM today but..."
                                </td>
                                <td>
                                    {item <= 2 ? <span className="status-badge status-danger"><AlertOctagon size={12} /> Pending</span> :
                                        <span className="status-badge status-success">Resolved</span>}
                                </td>
                                <td>Oct 12, 08:30 PM</td>
                                <td>
                                    <button className="btn-icon" onClick={() => setViewDetails(true)}><MoreHorizontal size={16} /></button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default Complaints;
