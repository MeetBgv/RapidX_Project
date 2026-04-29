import React, { useState, useEffect } from 'react';
import { CreditCard, Download, ExternalLink, RefreshCw } from 'lucide-react';
import { AreaChart, Area, ResponsiveContainer, Tooltip } from 'recharts';

const Payments = () => {
    const [payments, setPayments] = useState([]);
    const [loading, setLoading] = useState(true);
    const [stats, setStats] = useState({ todaysRevenue: 0, weeklyRevenue: 0, totalRevenue: 0, revenueTrendData: [] });

    const fetchPayments = async () => {
        setLoading(true);
        try {
            const [paymentsRes, payoutsRes, ordersRes] = await Promise.all([
                fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/payments`),
                fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/payouts`),
                fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/orders`)
            ]);

            if (paymentsRes.ok && payoutsRes.ok && ordersRes.ok) {
                const paymentsData = await paymentsRes.json();
                const payoutsData = await payoutsRes.json();
                const ordersData = await ordersRes.json();
                
                const allTransactions = [
                    ...paymentsData.map(p => ({
                        id: `TXN-${p.transaction_id}`,
                        order_biz_id: p.is_business ? `#BIZ-${p.business_id}` : `#ORD-${p.order_id}`,
                        method: (p.payment_method_name || 'N/A').toUpperCase(),
                        amount: p.amount,
                        reference: p.transaction_reference || 'N/A',
                        status: p.payment_status_name || 'Pending',
                        date: new Date(p.created_at)
                    })),
                    ...ordersData.map(o => ({
                        id: `ORD-${o.order_id}`,
                        order_biz_id: `#ORD-${o.order_id}`,
                        method: (o.payment_method || 'CASH').toUpperCase(),
                        amount: o.order_amount,
                        reference: 'Delivery Order',
                        status: (o.status_name?.toLowerCase() === 'delivered') ? 'Completed' : (o.status_name?.toLowerCase() === 'cancelled' ? 'Failed' : (o.status_name || 'Pending')),
                        date: new Date(o.created_at)
                    }))
                ];

                const uniqueTransactions = [];
                const seenIds = new Set();
                allTransactions.sort((a, b) => b.date - a.date).forEach(t => {
                    if (seenIds.has(t.id)) return;
                    seenIds.add(t.id);
                    uniqueTransactions.push(t);
                });

                setPayments(uniqueTransactions);

                const todayStart = new Date();
                todayStart.setHours(0, 0, 0, 0);

                const weekStart = new Date(todayStart);
                weekStart.setDate(weekStart.getDate() - 7);

                let todaysRevenue = 0;
                let weeklyRevenue = 0;
                let totalRevenue = 0;
                
                const dailyData = {};
                for (let i = 6; i >= 0; i--) {
                    const d = new Date();
                    d.setDate(d.getDate() - i);
                    const dateStr = d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
                    dailyData[dateStr] = 0;
                }

                payoutsData.forEach(p => {
                    const pDate = new Date(p.created_at);
                    const revenue = Number(p.admin_share) || 0;

                    totalRevenue += revenue;

                    if (pDate >= todayStart) {
                        todaysRevenue += revenue;
                    }

                    if (pDate >= weekStart) {
                        weeklyRevenue += revenue;
                    }
                    
                    const dateStr = pDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
                    if (dailyData[dateStr] !== undefined) {
                        dailyData[dateStr] += revenue;
                    }
                });

                const revenueTrendData = Object.keys(dailyData).map(k => ({
                    time: k,
                    amount: dailyData[k]
                }));

                setStats({ todaysRevenue, weeklyRevenue, totalRevenue, revenueTrendData });
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
                        <div style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Today's Revenue</div>
                        <div style={{ fontSize: '1.5rem', fontWeight: '700', color: 'var(--text-primary)' }}>₹{stats.todaysRevenue.toLocaleString()}</div>
                    </div>
                </div>
                <div className="panel" style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                    <div className="stat-icon purple"><CreditCard /></div>
                    <div>
                        <div style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Weekly Revenue</div>
                        <div style={{ fontSize: '1.5rem', fontWeight: '700', color: 'var(--text-primary)' }}>₹{stats.weeklyRevenue.toLocaleString()}</div>
                    </div>
                </div>
                <div className="panel" style={{ display: 'flex', flexDirection: 'column', padding: '1rem 1.5rem', height: '100px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.25rem' }}>
                        <div style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Total Revenue Trend</div>
                        <div style={{ fontSize: '1rem', fontWeight: '700', color: 'var(--text-primary)' }}>₹{stats.totalRevenue?.toLocaleString() || 0}</div>
                    </div>
                    <ResponsiveContainer width="100%" height="100%">
                        <AreaChart data={stats.revenueTrendData}>
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
                                formatter={(value) => [`₹${value}`, 'Revenue']}
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
                                <tr key={item.id}>
                                    <td><span style={{ fontWeight: 600 }}>{item.id}</span></td>
                                    <td><span style={{ color: 'var(--accent-primary)', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px' }}>
                                        {item.order_biz_id} <ExternalLink size={10} />
                                    </span></td>
                                    <td>{item.method}</td>
                                    <td><span style={{ fontWeight: 600 }}>₹{item.amount}</span></td>
                                    <td style={{ color: 'var(--text-muted)' }}>{item.reference}</td>
                                    <td>
                                        <span className={`status-badge ${item.status === 'Failed' ? 'status-danger' : item.status === 'Completed' ? 'status-success' : 'status-warning'}`}>
                                            {item.status}
                                        </span>
                                    </td>
                                    <td>{item.date.toLocaleString()}</td>
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
