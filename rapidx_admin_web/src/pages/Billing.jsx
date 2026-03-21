import React, { useState } from 'react';
import { FileText, Download } from 'lucide-react';

const Billing = () => {
    const [viewDetails, setViewDetails] = useState(false);

    if (viewDetails) {
        return (
            <div className="fade-in">
                <div className="details-header">
                    <button className="back-btn" onClick={() => setViewDetails(false)}>←</button>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                        <h1 className="page-title">Billing Account: #BILL-1002</h1>
                        <span className="status-badge status-warning">Overdue (Due: Oct 15)</span>
                    </div>
                </div>

                <div className="grid-2-cols">
                    <div className="panel">
                        <h3 className="panel-title">Billing Details</h3>
                        <div className="info-row"><span className="info-label">Billing ID</span><span className="info-value">#BILL-1002</span></div>
                        <div className="info-row"><span className="info-label">Business ID</span><span className="info-value">#BIZ-0021 (Tech Retailers)</span></div>
                        <div className="info-row"><span className="info-label">Billing Cycle</span><span className="info-value">Monthly</span></div>
                        <div className="info-row"><span className="info-label">Period Start Date</span><span className="info-value">Sep 01, 2026</span></div>
                        <div className="info-row"><span className="info-label">Period End Date</span><span className="info-value">Sep 30, 2026</span></div>
                        <div className="info-row"><span className="info-label" style={{ fontWeight: 'bold', color: 'var(--text-primary)' }}>Total Amount</span><span className="info-value" style={{ fontWeight: 'bold', fontSize: '1.1rem' }}>₹14,200.00</span></div>
                        <div className="info-row"><span className="info-label">Amount Paid</span><span className="info-value">₹4,200.00</span></div>
                        <div className="info-row"><span className="info-label" style={{ color: 'var(--accent-warning)', fontWeight: 'bold' }}>Amount Due</span><span className="info-value" style={{ color: 'var(--accent-warning)', fontWeight: 'bold' }}>₹10,000.00</span></div>
                        <div className="info-row"><span className="info-label">Interest Amount</span><span className="info-value">₹0.00</span></div>
                        <div className="info-row"><span className="info-label">Generated Date</span><span className="info-value">Oct 05, 2026</span></div>
                    </div>

                    <div className="panel">
                        <h3 className="panel-title">Billing Orders</h3>
                        <div className="table-container" style={{ boxShadow: 'none', background: 'transparent', border: '1px solid var(--border-light)' }}>
                            <table style={{ fontSize: '0.75rem' }}>
                                <thead>
                                    <tr>
                                        <th>Billing Order ID</th>
                                        <th>Order ID</th>
                                        <th>Amount</th>
                                        <th>Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {[1, 2, 3, 4, 5].map(i => (
                                        <tr key={i}>
                                            <td><span style={{ color: 'var(--accent-primary)' }}>#BO-{1000 + i}</span></td>
                                            <td>#ORD-983{i}</td>
                                            <td>₹{140 + i * 10}</td>
                                            <td>Sep {10 + i}, 2026</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                        <button className="primary-btn" style={{ marginTop: '1.5rem', width: '100%', justifyContent: 'center' }}><Download size={16} /> Download Invoice PDF</button>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="fade-in">
            <div className="page-header">
                <div>
                    <h1 className="page-title">Business Billing</h1>
                    <p className="page-subtitle">Manage, view, and generate B2B client invoices.</p>
                </div>
                <button className="primary-btn">Generate Bills</button>
            </div>

            <div className="table-container">
                <div className="table-header">
                    <span className="table-title">Billing Accounts</span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Bill ID</th>
                            <th>Business Name (ID)</th>
                            <th>Cycle</th>
                            <th>Period</th>
                            <th>Amount</th>
                            <th>Due</th>
                            <th>Status</th>
                            <th>Due Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {[1, 2, 3, 4].map((item) => (
                            <tr key={item}>
                                <td><span style={{ fontWeight: 600 }}>#BILL-100{item}</span></td>
                                <td><span style={{ color: 'var(--accent-primary)', cursor: 'pointer' }}>{"Tech Retailers (#BIZ-002" + item + ")"}</span></td>
                                <td>Monthly</td>
                                <td style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Sep 1 - Sep 30</td>
                                <td><span style={{ fontWeight: 600 }}>₹{item * 14200}</span></td>
                                <td><span style={{ fontWeight: 600, color: item === 1 ? 'var(--accent-warning)' : 'inherit' }}>₹{item === 1 ? 10000 : 0}</span></td>
                                <td>
                                    {item === 1 ? <span className="status-badge status-warning">Overdue</span> :
                                        <span className="status-badge status-success">Paid</span>}
                                </td>
                                <td style={{ color: item === 1 ? 'var(--accent-warning)' : 'var(--text-muted)' }}>Oct 15, 2026</td>
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

export default Billing;
