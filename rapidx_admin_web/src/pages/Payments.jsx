import React, { useState, useEffect } from 'react';
import { CreditCard, Download, ExternalLink, RefreshCw } from 'lucide-react';
import { AreaChart, Area, ResponsiveContainer, Tooltip } from 'recharts';

const paymentVolumeData = [
    { time: '08:00', amount: 12000 },
    { time: '09:00', amount: 24000 },
    { time: '10:00', amount: 35000 },
    { time: '11:00', amount: 28000 },
    { time: '12:00', amount: 42000 },
    { time: '13:00', amount: 54200 },
];

const Payments = () => {
    const [payments, setPayments] = useState([]);
    const [loading, setLoading] = useState(true);

    const fetchPayments = async () => {
        setLoading(true);
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/payments`);
            if (res.ok) {
                const data = await res.json();
                setPayments(data);
            }
        } catch (error) {
            console.error('Error fetching payments:', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchPayments();
    }, []);

    return (
        <div className="fade-in">
            <div className="page-header">
                <div>
                    <h1 className="page-title">Payments</h1>
                    <p className="page-subtitle">Track incoming payments from customers and business clients.</p>
                </div>
                <div style={{ display: 'flex', gap: '0.5rem' }}>
                    <button className="primary-btn" onClick={fetchPayments} style={{ background: 'var(--bg-secondary)', border: '1px solid var(--border-light)', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                        <RefreshCw size={16} /> Refresh
                    </button>
                    <button className="primary-btn" style={{ background: 'var(--accent-success)' }}>
                        <Download size={16} /> Export Transactions
                    </button>
                </div>
            </div>

            <div className="grid-3-cols">
                <div className="panel" style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                    <div className="stat-icon green"><CreditCard /></div>
                    <div>
                        <div style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Today's Collection</div>
                        <div style={{ fontSize: '1.5rem', fontWeight: '700', color: 'var(--text-primary)' }}>₹54,200</div>
                    </div>
                </div>
                <div className="panel" style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                    <div className="stat-icon purple"><CreditCard /></div>
                    <div>
                        <div style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Weekly Recurring</div>
                        <div style={{ fontSize: '1.5rem', fontWeight: '700', color: 'var(--text-primary)' }}>₹4,12,000</div>
                    </div>
                </div>
                <div className="panel" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: '1rem 1.5rem', height: '100px' }}>
                    <div style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>Today's Volume Trend</div>
                    <ResponsiveContainer width="100%" height="100%">
                        <AreaChart data={paymentVolumeData}>
                            <defs>
                                <linearGradient id="colorAmount" x1="0" y1="0" x2="0" y2="1">
                                    <stop offset="5%" stopColor="#8b5cf6" stopOpacity={0.8} />
                                    <stop offset="95%" stopColor="#8b5cf6" stopOpacity={0} />
                                </linearGradient>
                            </defs>
                            <Tooltip
                                contentStyle={{ backgroundColor: 'var(--bg-secondary)', borderColor: 'var(--border-light)', borderRadius: 'var(--radius-md)', padding: '4px 8px', fontSize: '12px' }}
                                itemStyle={{ color: 'var(--text-primary)' }}
                                labelStyle={{ display: 'none' }}
                                formatter={(value) => [`₹${value}`, 'Volume']}
                            />
                            <Area type="monotone" dataKey="amount" stroke="#8b5cf6" strokeWidth={2} fillOpacity={1} fill="url(#colorAmount)" />
                        </AreaChart>
                    </ResponsiveContainer>
                </div>
            </div>

            <div className="table-container">
                <div className="table-header">
                    <span className="table-title">Recent Transactions</span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>TXN ID</th>
                            <th>Order/Biz ID</th>
                            <th>Method</th>
                            <th>Amount</th>
                            <th>Reference</th>
                            <th>Status</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr><td colSpan="7" style={{ textAlign: 'center', padding: '2rem' }}>Loading payments...</td></tr>
                        ) : payments.length === 0 ? (
                            <tr><td colSpan="7" style={{ textAlign: 'center', padding: '2rem' }}>No recent payments.</td></tr>
                        ) : (
                            payments.map((item) => (
                                <tr key={item.transaction_id}>
                                    <td><span style={{ fontWeight: 600 }}>TXN-{item.transaction_id}</span></td>
                                    <td><span style={{ color: 'var(--accent-primary)', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px' }}>
                                        {item.is_business ? `#BIZ-${item.business_id}` : `#ORD-${item.order_id}`} <ExternalLink size={10} />
                                    </span></td>
                                    <td>{item.payment_method_name || 'N/A'}</td>
                                    <td><span style={{ fontWeight: 600 }}>₹{item.amount}</span></td>
                                    <td style={{ color: 'var(--text-muted)' }}>{item.transaction_reference}</td>
                                    <td>
                                        <span className={`status-badge ${item.payment_status_name === 'Failed' ? 'status-danger' : item.payment_status_name === 'Completed' ? 'status-success' : 'status-warning'}`}>
                                            {item.payment_status_name || 'Pending'}
                                        </span>
                                    </td>
                                    <td>{new Date(item.created_at).toLocaleString()}</td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default Payments;
