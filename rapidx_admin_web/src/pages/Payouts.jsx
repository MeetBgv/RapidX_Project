import React, { useState } from 'react';
import { Banknote, FileText, CheckCircle2 } from 'lucide-react';

const Payouts = () => {
    const [viewDetails, setViewDetails] = useState(false);

    if (viewDetails) {
        return (
            <div className="fade-in">
                <div className="details-header">
                    <button className="back-btn" onClick={() => setViewDetails(false)}>←</button>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                        <h1 className="page-title">Payout Info: #PAY-3902</h1>
                        <span className="status-badge status-success">Completed</span>
                    </div>
                </div>

                <div className="grid-2-cols">
                    <div className="panel">
                        <h3 className="panel-title" style={{ color: 'var(--accent-success)' }}>Payout Overview</h3>
                        <div className="info-row"><span className="info-label">Transaction ID</span><span className="info-value">#PAY-3902</span></div>
                        <div className="info-row"><span className="info-label">Delivery Partner ID</span><span className="info-value">#DP-4491 (Rakesh Kumar)</span></div>
                        <div className="info-row"><span className="info-label">Total Orders</span><span className="info-value">45</span></div>
                        <div className="info-row"><span className="info-label">Amount Paid</span><span className="info-value" style={{ fontSize: '1.25rem', fontWeight: 'bold', color: 'var(--text-primary)' }}>₹3,200</span></div>
                        <div className="info-row"><span className="info-label">Reference Number</span><span className="info-value">UTR-400928AB</span></div>
                        <div className="info-row"><span className="info-label">Initiated Date</span><span className="info-value">Oct 12, 10:00 AM</span></div>
                        <div className="info-row"><span className="info-label">Completed Date</span><span className="info-value">Oct 12, 11:30 AM</span></div>
                    </div>

                    <div className="panel">
                        <h3 className="panel-title">Payout Order Breakdown</h3>
                        <div className="table-container" style={{ boxShadow: 'none', background: 'transparent', border: '1px solid var(--border-light)' }}>
                            <table style={{ fontSize: '0.75rem' }}>
                                <thead>
                                    <tr>
                                        <th>Order ID</th>
                                        <th>Partner Earnings</th>
                                        <th>Paid Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {[1, 2, 3, 4, 5].map(i => (
                                        <tr key={i}>
                                            <td><span style={{ color: 'var(--accent-primary)' }}>#ORD-9938{i}</span></td>
                                            <td>₹{40 + i * 10}</td>
                                            <td><CheckCircle2 size={14} color="var(--accent-success)" /></td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                            <div style={{ padding: '1rem', textAlign: 'center', borderTop: '1px solid var(--border-light)', cursor: 'pointer', color: 'var(--accent-primary)' }}>
                                View all 45 mapped orders...
                            </div>
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
                    <h1 className="page-title">Delivery Partner Payouts</h1>
                    <p className="page-subtitle">Manage, view, and process earnings for partners.</p>
                </div>
                <button className="primary-btn" style={{ background: 'var(--accent-warning)', color: 'black' }}><Banknote size={16} /> Process Pending Payouts</button>
            </div>

            <div className="table-container">
                <div className="table-header">
                    <span className="table-title">Payout List</span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>TXN ID</th>
                            <th>Partner Name (ID)</th>
                            <th>Orders Count</th>
                            <th>Amount</th>
                            <th>Status</th>
                            <th>Reference Number</th>
                            <th>Initiated Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {[1, 2, 3, 4].map((item) => (
                            <tr key={item}>
                                <td><span style={{ fontWeight: 600 }}>#PAY-390{item}</span></td>
                                <td><span style={{ color: 'var(--accent-primary)', cursor: 'pointer' }}>{"Rakesh K. (#DP-" + (item + 400) + ")"}</span></td>
                                <td>{item * 15}</td>
                                <td><span style={{ fontWeight: 600 }}>₹{item * 1250}</span></td>
                                <td>
                                    {item === 1 ? <span className="status-badge status-warning">Processing</span> :
                                        <span className="status-badge status-success">Completed</span>}
                                </td>
                                <td style={{ color: 'var(--text-muted)' }}>{item === 1 ? 'N/A' : 'UTR-4009' + item + 'AB'}</td>
                                <td>Oct {10 + item}, 10:00 AM</td>
                                <td>
                                    <button className="btn-icon" onClick={() => setViewDetails(true)}><FileText size={16} /></button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default Payouts;
