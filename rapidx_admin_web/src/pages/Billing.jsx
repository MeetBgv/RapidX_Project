import React, { useState, useEffect } from 'react';
import { FileText, Download, ArrowLeft, RefreshCw } from 'lucide-react';

const Billing = () => {
    const [billingAccounts, setBillingAccounts] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selectedBill, setSelectedBill] = useState(null);

    const fetchBilling = async () => {
        setLoading(true);
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/billing`);
            if (res.ok) {
                const data = await res.json();
                setBillingAccounts(data);
            }
        } catch (error) {
            console.error('Error fetching billing accounts:', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchBilling();
    }, []);

    if (selectedBill) {
        return (
            <div className="fade-in">
                <div className="details-header">
                    <button className="back-btn" onClick={() => setSelectedBill(null)}><ArrowLeft size={16} /></button>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                        <h1 className="page-title">Billing Account: #BILL-{selectedBill.billing_account_id}</h1>
                        <span className={`status-badge ${selectedBill.billing_status_name === 'Paid' ? 'status-success' : 'status-warning'}`}>
                            {selectedBill.billing_status_name || 'Pending'}
                        </span>
                    </div>
                </div>

                <div className="grid-2-cols">
                    <div className="panel">
                        <h3 className="panel-title">Billing Details</h3>
                        <div className="info-row"><span className="info-label">Billing ID</span><span className="info-value">#BILL-{selectedBill.billing_account_id}</span></div>
                        <div className="info-row"><span className="info-label">Business ID</span><span className="info-value">#BIZ-{selectedBill.business_id} ({selectedBill.company_name})</span></div>
                        <div className="info-row"><span className="info-label">Billing Cycle</span><span className="info-value">Monthly</span></div>
                        <div className="info-row"><span className="info-label">Period Start Date</span><span className="info-value">{new Date(selectedBill.period_start_date).toLocaleDateString()}</span></div>
                        <div className="info-row"><span className="info-label">Period End Date</span><span className="info-value">{new Date(selectedBill.period_end_date).toLocaleDateString()}</span></div>
                        <div className="info-row"><span className="info-label" style={{ fontWeight: 'bold', color: 'var(--text-primary)' }}>Total Amount</span><span className="info-value" style={{ fontWeight: 'bold', fontSize: '1.1rem' }}>₹{selectedBill.total_amount_calculated}</span></div>
                        <div className="info-row"><span className="info-label">Amount Paid</span><span className="info-value">₹{selectedBill.amount_paid}</span></div>
                        <div className="info-row"><span className="info-label" style={{ color: 'var(--accent-warning)', fontWeight: 'bold' }}>Amount Due</span><span className="info-value" style={{ color: 'var(--accent-warning)', fontWeight: 'bold' }}>₹{selectedBill.amount_due}</span></div>
                        <div className="info-row"><span className="info-label">Generated Date</span><span className="info-value">{new Date(selectedBill.generated_at).toLocaleString()}</span></div>
                    </div>

                    <div className="panel">
                        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%' }}>
                            <button className="primary-btn" style={{ justifyContent: 'center' }}><Download size={16} /> Download Invoice PDF</button>
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
                    <h1 className="page-title">Business Billing</h1>
                    <p className="page-subtitle">Manage, view, and generate B2B client invoices.</p>
                </div>
                <div style={{ display: 'flex', gap: '0.5rem' }}>
                    <button className="primary-btn" onClick={fetchBilling} style={{ background: 'var(--bg-secondary)', border: '1px solid var(--border-light)', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                        <RefreshCw size={16} /> Refresh
                    </button>
                    <button className="primary-btn">Generate Bills</button>
                </div>
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
                        {loading ? (
                            <tr><td colSpan="9" style={{ textAlign: 'center', padding: '2rem' }}>Loading billing accounts...</td></tr>
                        ) : billingAccounts.length === 0 ? (
                            <tr><td colSpan="9" style={{ textAlign: 'center', padding: '2rem' }}>No billing accounts found.</td></tr>
                        ) : (
                            billingAccounts.map((item) => (
                                <tr key={item.billing_account_id}>
                                    <td><span style={{ fontWeight: 600 }}>#BILL-{item.billing_account_id}</span></td>
                                    <td><span style={{ color: 'var(--accent-primary)', cursor: 'pointer' }}>{item.company_name} (#BIZ-{item.business_id})</span></td>
                                    <td>Monthly</td>
                                    <td style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{new Date(item.period_start_date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })} - {new Date(item.period_end_date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</td>
                                    <td><span style={{ fontWeight: 600 }}>₹{item.total_amount_calculated}</span></td>
                                    <td><span style={{ fontWeight: 600, color: item.amount_due > 0 ? 'var(--accent-warning)' : 'inherit' }}>₹{item.amount_due}</span></td>
                                    <td>
                                        <span className={`status-badge ${item.billing_status_name === 'Paid' ? 'status-success' : 'status-warning'}`}>
                                            {item.billing_status_name || 'Pending'}
                                        </span>
                                    </td>
                                    <td style={{ color: item.amount_due > 0 ? 'var(--accent-warning)' : 'var(--text-muted)' }}>{new Date(item.period_end_date).getTime() < Date.now() && item.amount_due > 0 ? 'Overdue' : 'N/A'}</td>
                                    <td>
                                        <button className="btn-icon" onClick={() => setSelectedBill(item)}><FileText size={16} /></button>
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

export default Billing;
