import React, { useState, useEffect } from 'react';
import { 
    Banknote, FileText, CheckCircle2, ArrowLeft, RefreshCw, 
    Clock, DollarSign, AlertCircle, Search, Filter, CheckCircle, 
    ArrowRightCircle, Wallet, Info, MoreHorizontal
} from 'lucide-react';

const Payouts = () => {
    const [payouts, setPayouts] = useState([]);
    const [loading, setLoading] = useState(true);
    const [stats, setStats] = useState({
        cash_pending_count: 0,
        awaiting_payout_count: 0,
        paid_count: 0,
        total_awaiting: 0,
        total_cash_pending: 0,
        total_paid_out: 0,
        total_admin_earnings: 0
    });
    const [filter, setFilter] = useState('all'); // all, cash_pending, awaiting_payout, paid
    const [searchQuery, setSearchQuery] = useState('');
    const [actionLoading, setActionLoading] = useState(null);

    const fetchPayoutData = async () => {
        setLoading(true);
        try {
            const [payoutsRes, statsRes] = await Promise.all([
                fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/payouts`),
                fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/payouts/stats`)
            ]);

            if (payoutsRes.ok) {
                const data = await payoutsRes.json();
                setPayouts(data);
            }
            if (statsRes.ok) {
                const data = await statsRes.json();
                setStats(data);
            }
        } catch (error) {
            console.error('Error fetching payouts:', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchPayoutData();
    }, []);

    const handleConfirmCash = async (id) => {
        if (!window.confirm('Are you sure you have received the full cash amount from the partner?')) return;
        
        setActionLoading(id);
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/payouts/${id}/confirm-cash`, {
                method: 'POST'
            });
            if (res.ok) {
                fetchPayoutData();
            } else {
                const err = await res.json();
                alert(err.error || 'Failed to confirm cash');
            }
        } catch (error) {
            console.error('Error:', error);
        } finally {
            setActionLoading(null);
        }
    };

    const handleProcessPayout = async (id) => {
        const txnId = window.prompt('Enter Transaction reference number (e.g. UPI Ref, Bank Ref):');
        if (txnId === null) return;
        
        setActionLoading(id);
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/payouts/${id}/pay`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ transaction_id: txnId, notes: 'Paid from Admin Dashboard' })
            });
            if (res.ok) {
                fetchPayoutData();
            } else {
                const err = await res.json();
                alert(err.error || 'Failed to process payout');
            }
        } catch (error) {
            console.error('Error:', error);
        } finally {
            setActionLoading(null);
        }
    };

    const filteredPayouts = payouts.filter(p => {
        const matchesFilter = filter === 'all' || p.status === filter;
        const matchesSearch = searchQuery === '' || 
            `${p.first_name} ${p.last_name}`.toLowerCase().includes(searchQuery.toLowerCase()) ||
            `#ORD-${p.order_id}`.toLowerCase().includes(searchQuery.toLowerCase()) ||
            `#PAY-${p.payout_order_id}`.toLowerCase().includes(searchQuery.toLowerCase());
        return matchesFilter && matchesSearch;
    });

    const getStatusInfo = (status) => {
        switch(status) {
            case 'cash_pending': 
                return { label: 'Cash Pending', class: 'status-warning', icon: <Clock size={12} />, color: '#EF6C00' };
            case 'awaiting_payout': 
                return { label: 'Ready to Pay', class: 'status-info', icon: <DollarSign size={12} />, color: '#0F4C75' };
            case 'paid': 
                return { label: 'Paid', class: 'status-success', icon: <CheckCircle size={12} />, color: '#1BD100' };
            default: 
                return { label: status, class: '', icon: null, color: '#757575' };
        }
    };

    return (
        <div className="fade-in" style={{ paddingBottom: '2rem' }}>
            {/* Header */}
            <div className="page-header" style={{ marginBottom: '1.5rem' }}>
                <div>
                    <h1 className="page-title">Partner Payout Management</h1>
                    <p className="page-subtitle">Manage 80/20 revenue split and cash remittance status.</p>
                </div>
                <div style={{ display: 'flex', gap: '0.75rem' }}>
                    <button className="primary-btn" onClick={fetchPayoutData} style={{ background: 'var(--bg-secondary)', color: 'var(--text-primary)', border: '1px solid var(--border-light)' }}>
                        <RefreshCw size={16} className={loading ? 'spin' : ''} /> Refresh Sync
                    </button>
                    {/* <button className="primary-btn" style={{ background: 'var(--accent-primary)', color: 'white' }}>
                        <Banknote size={16} /> Bulk Payout
                    </button> */}
                </div>
            </div>

            {/* Stats Overview */}
            <div className="grid-4-cols" style={{ marginBottom: '2rem', gap: '1rem' }}>
                <div className="card stat-card" style={{ borderLeft: '4px solid #EF6C00' }}>
                    <div className="stat-label">Cash Remittance Pending</div>
                    <div className="stat-value">₹{Number(stats.total_cash_pending).toLocaleString()}</div>
                    <div className="stat-desc">{stats.cash_pending_count} partners to pay admin</div>
                </div>
                <div className="card stat-card" style={{ borderLeft: '4px solid #0F4C75' }}>
                    <div className="stat-label">Awaiting Payout</div>
                    <div className="stat-value">₹{Number(stats.total_awaiting).toLocaleString()}</div>
                    <div className="stat-desc">{stats.awaiting_payout_count} payouts ready to process</div>
                </div>
                <div className="card stat-card" style={{ borderLeft: '4px solid #1BD100' }}>
                    <div className="stat-label">Total Out-payouts</div>
                    <div className="stat-value">₹{Number(stats.total_paid_out).toLocaleString()}</div>
                    <div className="stat-desc">{stats.paid_count} partners paid successfully</div>
                </div>
                <div className="card stat-card" style={{ borderLeft: '4px solid var(--accent-primary)', background: 'var(--bg-secondary)' }}>
                    <div className="stat-label">Platform Earnings (20%)</div>
                    <div className="stat-value" style={{ color: 'var(--accent-primary)' }}>₹{Number(stats.total_admin_earnings).toLocaleString()}</div>
                    <div className="stat-desc">Net profit from all deliveries</div>
                </div>
            </div>

            {/* Main Content Area */}
            <div className="table-card" style={{ background: 'white', borderRadius: '12px', boxShadow: '0 4px 20px rgba(0,0,0,0.05)', border: '1px solid var(--border-light)' }}>
                {/* Table Filters & Actions */}
                <div className="table-controls" style={{ padding: '1.25rem', borderBottom: '1px solid var(--border-light)', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '1rem' }}>
                    <div style={{ display: 'flex', gap: '0.75rem' }}>
                        {['all', 'cash_pending', 'awaiting_payout', 'paid'].map((f) => (
                            <button 
                                key={f} 
                                className={`filter-chip ${filter === f ? 'active' : ''}`}
                                onClick={() => setFilter(f)}
                                style={{ 
                                    padding: '0.5rem 1rem', 
                                    borderRadius: '20px', 
                                    fontSize: '0.85rem', 
                                    fontWeight: 600,
                                    border: '1px solid var(--border-light)',
                                    background: filter === f ? 'var(--accent-primary)' : 'white',
                                    color: filter === f ? 'white' : 'var(--text-secondary)',
                                    cursor: 'pointer',
                                    transition: 'all 0.2s'
                                }}
                            >
                                {f.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ')}
                            </button>
                        ))}
                    </div>
                    <div style={{ position: 'relative', width: '300px' }}>
                        <Search style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} size={16} />
                        <input 
                            type="text" 
                            placeholder="Search by ID, Name or Order..." 
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            style={{ 
                                width: '100%', 
                                padding: '0.65rem 1rem 0.65rem 2.5rem', 
                                borderRadius: '10px', 
                                border: '1px solid var(--border-light)',
                                outline: 'none',
                                fontSize: '0.9rem'
                            }}
                        />
                    </div>
                </div>

                {/* The Payout Table */}
                <div style={{ overflowX: 'auto' }}>
                    <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
                        <thead style={{ background: '#f8f9fa', borderBottom: '2px solid #edeff2' }}>
                            <tr>
                                <th style={{ padding: '1rem 1.25rem', fontSize: '0.85rem', fontWeight: 600 }}>ORDER INFO</th>
                                <th style={{ padding: '1rem 1.25rem', fontSize: '0.85rem', fontWeight: 600 }}>PARTNER DETAILS</th>
                                <th style={{ padding: '1rem 1.25rem', fontSize: '0.85rem', fontWeight: 600 }}>REVENUE SHARE</th>
                                <th style={{ padding: '1rem 1.25rem', fontSize: '0.85rem', fontWeight: 600 }}>PAYMENT MODE</th>
                                <th style={{ padding: '1rem 1.25rem', fontSize: '0.85rem', fontWeight: 600 }}>CURRENT STATUS</th>
                                <th style={{ padding: '1rem 1.25rem', fontSize: '0.85rem', fontWeight: 600, textAlign: 'right' }}>ACTIONS</th>
                            </tr>
                        </thead>
                        <tbody>
                            {loading ? (
                                <tr>
                                    <td colSpan="6" style={{ padding: '4rem', textAlign: 'center' }}>
                                        <RefreshCw className="spin" size={32} style={{ color: 'var(--accent-primary)', marginBottom: '1rem' }} />
                                        <p style={{ color: 'var(--text-muted)' }}>Fetching latest payout records...</p>
                                    </td>
                                </tr>
                            ) : filteredPayouts.length === 0 ? (
                                <tr>
                                    <td colSpan="6" style={{ padding: '4rem', textAlign: 'center', color: 'var(--text-muted)' }}>
                                        <Info size={40} style={{ opacity: 0.2, marginBottom: '1rem' }} />
                                        <p>No payout records found matching your criteria.</p>
                                    </td>
                                </tr>
                            ) : (
                                filteredPayouts.map((item) => {
                                    const statusInfo = getStatusInfo(item.status);
                                    return (
                                        <tr key={item.payout_order_id} style={{ borderBottom: '1px solid #f1f3f5', transition: 'background 0.2s' }} className="table-row-hover">
                                            <td style={{ padding: '1.25rem' }}>
                                                <div style={{ fontWeight: 700, color: 'var(--text-primary)' }}>#ORD-{item.order_id}</div>
                                                <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Payout ID: #PAY-{item.payout_order_id}</div>
                                                <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{new Date(item.created_at).toLocaleDateString()}</div>
                                            </td>
                                            <td style={{ padding: '1.25rem' }}>
                                                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                                                    <div style={{ width: '36px', height: '36px', borderRadius: '50%', background: 'var(--accent-primary)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold', fontSize: '0.8rem' }}>
                                                        {item.first_name?.[0]}{item.last_name?.[0]}
                                                    </div>
                                                    <div>
                                                        <div style={{ fontWeight: 600 }}>{item.first_name} {item.last_name}</div>
                                                        <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>{item.dp_phone}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td style={{ padding: '1.25rem' }}>
                                                <div style={{ fontWeight: 700, color: 'var(--accent-primary)' }}>₹{item.dp_share} <span style={{ fontSize: '0.7rem', fontWeight: 500, color: 'var(--text-muted)' }}>(Partner 80%)</span></div>
                                                <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>₹{item.admin_share} <span style={{ opacity: 0.6 }}>(Admin 20%)</span></div>
                                                <div style={{ fontSize: '0.75rem', fontWeight: 600 }}>Total: ₹{item.order_amount}</div>
                                            </td>
                                            <td style={{ padding: '1.25rem' }}>
                                                <span style={{ 
                                                    textTransform: 'uppercase', 
                                                    fontSize: '0.7rem', 
                                                    fontWeight: 800, 
                                                    padding: '3px 8px', 
                                                    borderRadius: '4px',
                                                    background: item.payment_method === 'cash' ? '#fff3e0' : '#e3f2fd',
                                                    color: item.payment_method === 'cash' ? '#ef6c00' : '#1976d2',
                                                    border: `1px solid ${item.payment_method === 'cash' ? '#ffe0b2' : '#bbdefb'}`
                                                }}>
                                                    {item.payment_method}
                                                </span>
                                            </td>
                                            <td style={{ padding: '1.25rem' }}>
                                                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                                    <div style={{ color: statusInfo.color }}>{statusInfo.icon}</div>
                                                    <span style={{ fontWeight: 600, fontSize: '0.9rem', color: statusInfo.color }}>{statusInfo.label}</span>
                                                </div>
                                                {item.is_paid && <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', marginTop: '2px' }}>Ref: {item.partner_transaction_id}</div>}
                                            </td>
                                            <td style={{ padding: '1.25rem', textAlign: 'right' }}>
                                                {item.status === 'cash_pending' && (
                                                    <button 
                                                        className="action-btn"
                                                        disabled={actionLoading === item.payout_order_id}
                                                        onClick={() => handleConfirmCash(item.payout_order_id)}
                                                        style={{ 
                                                            padding: '0.5rem 1rem', 
                                                            borderRadius: '8px', 
                                                            fontSize: '0.8rem', 
                                                            fontWeight: 700,
                                                            background: '#EF6C00',
                                                            color: 'white',
                                                            border: 'none',
                                                            cursor: 'pointer',
                                                            boxShadow: '0 2px 8px rgba(239, 108, 0, 0.3)',
                                                            display: 'inline-flex',
                                                            alignItems: 'center',
                                                            gap: '0.5rem'
                                                        }}
                                                    >
                                                        {actionLoading === item.payout_order_id ? <RefreshCw size={14} className="spin" /> : <Wallet size={14} />}
                                                        Confirm Cash Received
                                                    </button>
                                                )}
                                                {item.status === 'awaiting_payout' && (
                                                    <button 
                                                        className="action-btn"
                                                        disabled={actionLoading === item.payout_order_id}
                                                        onClick={() => handleProcessPayout(item.payout_order_id)}
                                                        style={{ 
                                                            padding: '0.5rem 1rem', 
                                                            borderRadius: '8px', 
                                                            fontSize: '0.8rem', 
                                                            fontWeight: 700,
                                                            background: 'var(--accent-primary)',
                                                            color: 'white',
                                                            border: 'none',
                                                            cursor: 'pointer',
                                                            boxShadow: '0 2px 8px rgba(15, 76, 117, 0.3)',
                                                            display: 'inline-flex',
                                                            alignItems: 'center',
                                                            gap: '0.5rem'
                                                        }}
                                                    >
                                                        {actionLoading === item.payout_order_id ? <RefreshCw size={14} className="spin" /> : <Banknote size={14} />}
                                                        Pay Partner ₹{item.dp_share}
                                                    </button>
                                                )}
                                                {item.status === 'paid' && (
                                                    <div style={{ color: '#1BD100', display: 'inline-flex', alignItems: 'center', gap: '0.5rem', fontWeight: 600, fontSize: '0.85rem' }}>
                                                        <CheckCircle size={16} /> Completed
                                                    </div>
                                                )}
                                            </td>
                                        </tr>
                                    );
                                })
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
            
            {/* Legend / Help */}
            <div style={{ marginTop: '2rem', padding: '1.5rem', background: '#e3f2fd', borderRadius: '12px', color: '#1565c0', display: 'flex', gap: '1rem', alignItems: 'flex-start' }}>
                <Info size={24} style={{ flexShrink: 0 }} />
                <div>
                    <div style={{ fontWeight: 700, marginBottom: '0.25rem' }}>Security Note on Cash Payments</div>
                    <p style={{ fontSize: '0.9rem', lineHeight: 1.5, margin: 0, opacity: 0.85 }}>
                        For <b>Cash Payments</b>, the delivery partner collects the full amount from the customer. 
                        The partner must remit the <b>total cash</b> to the admin. 
                        Once the admin confirms the receipt, the <b>80% share</b> is then paid back to the partner. 
                        For <b>Online Payments</b>, the admin already holds the amount and can process the 80% payout immediately after delivery.
                    </p>
                </div>
            </div>
        </div>
    );
};

export default Payouts;
