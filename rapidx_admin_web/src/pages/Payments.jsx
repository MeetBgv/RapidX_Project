import React from 'react';
import { CreditCard, Download, ExternalLink } from 'lucide-react';
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
    return (
        <div className="fade-in">
            <div className="page-header">
                <div>
                    <h1 className="page-title">Payments</h1>
                    <p className="page-subtitle">Track incoming payments from customers and business clients.</p>
                </div>
                <button className="primary-btn" style={{ background: 'var(--accent-success)' }}>
                    <Download size={16} /> Export Transactions
                </button>
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
                        {[1, 2, 3, 4, 5, 6].map((item) => (
                            <tr key={item}>
                                <td><span style={{ fontWeight: 600 }}>TXN-902{item}</span></td>
                                <td><span style={{ color: 'var(--accent-primary)', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px' }}>{item % 2 == 0 ? `#ORD-930${item}` : `#BIZ-002${item}`} <ExternalLink size={10} /></span></td>
                                <td>{item % 2 == 0 ? 'UPI' : 'Bank Transfer'}</td>
                                <td><span style={{ fontWeight: 600 }}>₹{item * 1450}</span></td>
                                <td style={{ color: 'var(--text-muted)' }}>{item % 2 == 0 ? 'pay_Mz93k2...' : 'UTR-992J3K...'}</td>
                                <td>
                                    {item === 3 ? <span className="status-badge status-danger">Failed</span> :
                                        <span className="status-badge status-success">Success</span>}
                                </td>
                                <td>Today, 10:{10 + item * 5} AM</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default Payments;
