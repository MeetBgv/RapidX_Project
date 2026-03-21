import React, { useState } from 'react';
import { MoreHorizontal, Edit2, Trash2, Shield } from 'lucide-react';

const Businesses = () => {
    const [viewDetails, setViewDetails] = useState(false);

    if (viewDetails) {
        return (
            <div className="fade-in">
                <div className="details-header">
                    <button className="back-btn" onClick={() => setViewDetails(false)}>←</button>
                    <h1 className="page-title">Business Details: BIZ-0023</h1>
                </div>

                <div className="grid-2-cols">
                    <div className="panel">
                        <h3 className="panel-title">Business Information</h3>
                        <div className="info-row"><span className="info-label">Company Name</span><span className="info-value">Tech Retailers Pvt Ltd</span></div>
                        <div className="info-row"><span className="info-label">Business Type</span><span className="info-value">Retail</span></div>
                        <div className="info-row"><span className="info-label">Registration Number</span><span className="info-value">GSTIN29AABCT1234F1Z5</span></div>
                        <div className="info-row"><span className="info-label">Contact Phone</span><span className="info-value">+91 8888877777</span></div>
                    </div>

                    <div className="panel">
                        <h3 className="panel-title">Billing Information</h3>
                        <div className="info-row"><span className="info-label">Billing Cycle</span><span className="info-value"><span className="status-badge status-info">Monthly</span></span></div>
                        <div className="info-row"><span className="info-label">Payment Method</span><span className="info-value">Bank Transfer</span></div>
                        <div className="info-row"><span className="info-label">Pending Payments</span><span className="info-value" style={{ color: 'var(--accent-warning)', fontWeight: 'bold' }}>₹15,400.00</span></div>
                    </div>

                    <div className="panel">
                        <h3 className="panel-title">Business Admin & Addresses</h3>
                        <div className="info-row"><span className="info-label">Account Admin User</span><span className="info-value" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Shield size={14} /> admin@techretail.com</span></div>
                        <div className="info-row"><span className="info-label">Registered Address</span><span className="info-value">45, Indiranagar, Bangalore, Karnataka, 560038</span></div>
                    </div>

                    <div className="panel">
                        <h3 className="panel-title">Business Orders & Billing</h3>
                        <div className="info-row"><span className="info-label">Total Orders</span><span className="info-value">1,452</span></div>
                        <div className="info-row"><span className="info-label">Generated Bills</span><span className="info-value">14</span></div>
                        <div className="info-row"><span className="info-label">Payment Status</span><span className="info-value"><span className="status-badge status-warning">Overdue</span></span></div>
                        <div style={{ marginTop: '1rem', display: 'flex', gap: '1rem' }}>
                            <button className="primary-btn" style={{ flex: 1, padding: '0.4rem', justifyContent: 'center' }}>View Order History</button>
                            <button className="primary-btn" style={{ flex: 1, padding: '0.4rem', justifyContent: 'center' }}>View Billing History</button>
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
                    <h1 className="page-title">Business Clients</h1>
                    <p className="page-subtitle">B2B client accounts, tracking and billing.</p>
                </div>
                <button className="primary-btn">+ Register Business</button>
            </div>

            <div className="table-container">
                <div className="table-header">
                    <span className="table-title">Business List</span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Business ID</th>
                            <th>Company Name</th>
                            <th>Business Type</th>
                            <th>Registration Number</th>
                            <th>Phone</th>
                            <th>Account Status</th>
                            <th>Billing Cycle</th>
                            <th>Payment Method</th>
                            <th>Pending Payments</th>
                            <th>Created Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {[1, 2, 3].map((item) => (
                            <tr key={item}>
                                <td>#BIZ-00{20 + item}</td>
                                <td>Company {item} Ltd</td>
                                <td>E-Commerce</td>
                                <td>REG-00{item}XAY</td>
                                <td>+91 99000111{item}</td>
                                <td><span className="status-badge status-success">Active</span></td>
                                <td>Monthly</td>
                                <td>Net Banking</td>
                                <td>₹{item * 4000}</td>
                                <td>Aug 10, 2026</td>
                                <td>
                                    <div className="td-actions">
                                        <button className="btn-icon" onClick={() => setViewDetails(true)}><MoreHorizontal size={16} /></button>
                                        <button className="btn-icon"><Edit2 size={16} /></button>
                                    </div>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default Businesses;
