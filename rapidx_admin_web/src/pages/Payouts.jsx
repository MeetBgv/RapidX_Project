import React, { useState, useEffect } from 'react';
import { 
    Banknote, FileText, CheckCircle2, ArrowLeft, RefreshCw, 
    Clock, IndianRupee, AlertCircle, Search, Filter, CheckCircle, 
    ArrowRightCircle, Wallet, Info, MoreHorizontal, TrendingUp, TrendingDown,
    CreditCard, Users
} from 'lucide-react';

const Payouts = () => {
    const [payouts, setPayouts] = useState([]);
    const [partnerPayouts, setPartnerPayouts] = useState([]);
    const [viewMode, setViewMode] = useState('partner'); // 'all' or 'partner'
    const [loading, setLoading] = useState(true);
    const [stats, setStats] = useState({
        cash_pending_count: 0,
        awaiting_payout_count: 0,
        paid_count: 0,
        total_awaiting: 0,
        total_cash_pending: 0,
        total_paid_out: 0,
        total_admin_earnings: 0,
        total_cash_held: 0,
        total_online_held: 0,
        grand_total_pending: 0
    });
    const [filter, setFilter] = useState('all'); // all, cash_pending, awaiting_payout, paid
    const [searchQuery, setSearchQuery] = useState('');
    const [actionLoading, setActionLoading] = useState(null);

    const fetchPayoutData = async (showLoading = true) => {
        if (showLoading) setLoading(true);
        try {
            const [payoutsRes, partnerRes, statsRes] = await Promise.all([
                fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/payouts`),
                fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/payouts/partner`),
                fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/payouts/stats`)
            ]);

            if (payoutsRes.ok) {
                const data = await payoutsRes.json();
                setPayouts(data);
            }
            if (partnerRes.ok) {
                const data = await partnerRes.json();
                setPartnerPayouts(data);
            }
            if (statsRes.ok) {
                const data = await statsRes.json();
                setStats(data);
            }
        } catch (error) {
            console.error('Error fetching payouts:', error);
        } finally {
            if (showLoading) setLoading(false);
        }
    };


    useEffect(() => {
        fetchPayoutData(true);
        const poll = setInterval(() => fetchPayoutData(false), 2000);
        return () => clearInterval(poll);
    }, []);

    const handleConfirmBulkCash = async (id, name, amount) => {
        if (!window.confirm(`Confirm you have received the full ₹${Number(amount).toLocaleString()} cash from ${name}?`)) return;
        
        setActionLoading('bulk-' + id);
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/payouts/partner/${id}/confirm-bulk-cash`, {
                method: 'POST'
            });
            if (res.ok) {
                fetchPayoutData();
            }
        } catch (error) {
            console.error('Error confirming bulk cash:', error);
        } finally {
            setActionLoading(null);
        }
    };

    const handlePayPartnerBulk = async (id, name, amount) => {
        if (!window.confirm(`Execute full settlement of ₹${Number(amount).toLocaleString()} for ${name}?`)) return;
        
        setActionLoading('bulk-pay-' + id);
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/payouts/partner/${id}/pay-bulk`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ transaction_id: `BULK-SETTLED-${Date.now()}`, notes: 'Bulk Direct Settlement' })
            });
            if (res.ok) {
                fetchPayoutData();
            } else {
                const err = await res.json();
                alert(err.error || 'Failed to process bulk payout');
            }
        } catch (error) {
            console.error('Error:', error);
        } finally {
            setActionLoading(null);
        }
    };

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
        if (!window.confirm('Process this payout as settled?')) return;
        
        setActionLoading(id);
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/payouts/${id}/pay`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ transaction_id: `DIRECT-SETTLED-${Date.now()}`, notes: 'Direct Settlement from Admin Dashboard' })
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

    const filteredPayouts = payouts.filter(item => {
        const matchesFilter = filter === 'all' || item.status === filter;
        const searchStr = `${item.order_id} ${item.first_name} ${item.last_name} ${item.payout_order_id}`.toLowerCase();
        const matchesSearch = searchStr.includes(searchQuery.toLowerCase());
        return matchesFilter && matchesSearch;
    });

    const filteredPartnerPayouts = partnerPayouts.filter(item => {
        const searchStr = `${item.first_name} ${item.last_name} ${item.phone}`.toLowerCase();
        return searchStr.includes(searchQuery.toLowerCase());
    });

    const getStatusInfo = (status) => {
        switch(status) {
            case 'cash_pending': 
                return { label: 'Cash Pending', class: 'status-warning', icon: <Clock size={14} />, color: 'var(--accent-warning)' };
            case 'awaiting_payout': 
                return { label: 'Ready to Pay', class: 'status-info', icon: <IndianRupee size={14} />, color: 'var(--accent-primary)' };
            case 'paid': 
                return { label: 'Settled', class: 'status-success', icon: <CheckCircle size={14} />, color: 'var(--accent-success)' };
            default: 
                return { label: status, class: 'status-neutral', icon: null, color: 'var(--text-muted)' };
        }
    };

    return (
        <div className="fade-in" style={{ paddingBottom: '3rem' }}>
            {/* Header section - Balanced row layout */}
            <div className="page-header" style={{ marginBottom: '2rem', alignItems: 'flex-start' }}>
                <div>
                    <h1 className="page-title">Financial Payouts</h1>
                    <p className="page-subtitle">Settle partner earnings and monitor revenue splits.</p>
                </div>

                {/* Centered View Mode Toggle */}
                <div style={{ 
                    display: 'flex', 
                    background: 'var(--bg-secondary)', 
                    padding: '0.4rem', 
                    borderRadius: '14px', 
                    border: '1px solid var(--border-light)',
                    boxShadow: 'inset 0 2px 4px rgba(0,0,0,0.1)'
                }}>
                    <button 
                        onClick={() => setViewMode('partner')}
                        style={{ 
                            padding: '0.5rem 1.25rem', 
                            borderRadius: '10px', 
                            border: 'none',
                            background: viewMode === 'partner' ? 'var(--accent-primary)' : 'transparent',
                            color: viewMode === 'partner' ? 'white' : 'var(--text-secondary)',
                            fontWeight: 600,
                            cursor: 'pointer',
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            transition: 'all 0.2s',
                            fontSize: '0.9rem'
                        }}
                    >
                        <Users size={16} /> Partner Mode
                    </button>
                    <button 
                        onClick={() => setViewMode('all')}
                        style={{ 
                            padding: '0.5rem 1.25rem', 
                            borderRadius: '10px', 
                            border: 'none',
                            background: viewMode === 'all' ? 'var(--accent-primary)' : 'transparent',
                            color: viewMode === 'all' ? 'white' : 'var(--text-secondary)',
                            fontWeight: 600,
                            cursor: 'pointer',
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            transition: 'all 0.2s',
                            fontSize: '0.9rem'
                        }}
                    >
                        <FileText size={16} /> Order Mode
                    </button>
                </div>

                <div className="header-actions" style={{ gap: '0.75rem' }}>
                    <button 
                        className="btn-icon" 
                        onClick={fetchPayoutData} 
                        style={{ width: '42px', height: '42px', borderRadius: '12px', background: 'var(--bg-secondary)' }}
                    >
                        <RefreshCw size={18} className={loading ? 'spin' : ''} />
                    </button>
                    <button className="primary-btn" style={{ padding: '0.6rem 1rem' }}>
                        <FileText size={18} /> Export
                    </button>
                </div>
            </div>

            {/* Stats Overview Grid */}
            <div className="grid-4-cols" style={{ marginBottom: '2rem' }}>
                <div className="stat-card" style={{ borderLeft: '4px solid var(--accent-warning)' }}>
                    <div className="stat-info">
                        <div className="stat-title">Cash Held (100%)</div>
                        <div className="stat-value" style={{ fontSize: '1.5rem' }}>₹{Number(stats.total_cash_held).toLocaleString()}</div>
                        <div className="stat-trend" style={{ color: 'var(--accent-warning)', fontSize: '0.75rem' }}>
                            <Clock size={12} /> {stats.cash_pending_count} entries
                        </div>
                    </div>
                </div>
                
                <div className="stat-card" style={{ borderLeft: '4px solid var(--accent-primary)' }}>
                    <div className="stat-info">
                        <div className="stat-title">Online Funds (100%)</div>
                        <div className="stat-value" style={{ fontSize: '1.5rem' }}>₹{Number(stats.total_online_held).toLocaleString()}</div>
                        <div className="stat-trend" style={{ color: 'var(--accent-primary)', fontSize: '0.75rem' }}>
                            <ArrowRightCircle size={12} /> Live on platform
                        </div>
                    </div>
                </div>

                <div className="stat-card" style={{ borderLeft: '4px solid var(--accent-secondary)' }}>
                    <div className="stat-info">
                        <div className="stat-title">Grand Total</div>
                        <div className="stat-value" style={{ fontSize: '1.5rem' }}>₹{Number(stats.grand_total_pending).toLocaleString()}</div>
                        <div className="stat-trend" style={{ fontSize: '0.75rem' }}>
                            <TrendingUp size={12} /> Gross Pipeline
                        </div>
                    </div>
                </div>

                <div className="stat-card success" style={{ background: 'rgba(16, 185, 129, 0.05)', borderLeft: '4px solid var(--accent-success)' }}>
                    <div className="stat-info" style={{ width: '100%' }}>
                        <div className="stat-title">Settlement Forecast (80/20)</div>
                        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', marginTop: '4px' }}>
                            <div>
                                <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', fontWeight: 600 }}>DP SHARE</div>
                                <div style={{ fontSize: '1.1rem', fontWeight: 800, color: 'var(--accent-success)' }}>
                                    ₹{(Number(stats.total_cash_pending) + Number(stats.total_awaiting)).toLocaleString()}
                                </div>
                            </div>
                            <div>
                                <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', fontWeight: 600 }}>ADMIN FEE</div>
                                <div style={{ fontSize: '1.1rem', fontWeight: 800, color: 'var(--text-primary)' }}>
                                    ₹{Number(stats.total_admin_earnings).toLocaleString()}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {/* Main Table Area */}
            <div className="table-container">
                <div className="table-header" style={{ padding: '1rem 1.5rem', background: 'rgba(255, 255, 255, 0.02)' }}>
                    {viewMode === 'all' && (
                        <div style={{ display: 'flex', gap: '8px', background: 'rgba(0,0,0,0.1)', padding: '3px', borderRadius: '10px' }}>
                            {['all', 'cash_pending', 'awaiting_payout', 'paid'].map((f) => (
                                <button 
                                    key={f} 
                                    onClick={() => setFilter(f)}
                                    style={{ 
                                        padding: '0.4rem 1rem', 
                                        borderRadius: '8px', 
                                        fontSize: '0.8rem', 
                                        fontWeight: 600,
                                        border: 'none',
                                        background: filter === f ? 'var(--accent-primary)' : 'transparent',
                                        color: filter === f ? 'white' : 'var(--text-secondary)',
                                        cursor: 'pointer',
                                        transition: 'all 0.2s'
                                    }}
                                >
                                    {f === 'all' ? 'All' : f.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ')}
                                </button>
                            ))}
                        </div>
                    )}
                    
                    {viewMode === 'partner' && (
                        <div style={{ fontWeight: 700, fontSize: '0.9rem', color: 'var(--text-primary)', display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <Users size={16} /> Partner Accounts
                        </div>
                    )}

                    <div style={{ position: 'relative', width: '300px' }}>
                        <Search style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} size={16} />
                        <input 
                            type="text" 
                            placeholder={viewMode === 'partner' ? "Search partners..." : "Search orders..."}
                            className="header-search-input"
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            style={{ 
                                width: '100%', 
                                padding: '0.6rem 1rem 0.6rem 2.5rem', 
                                borderRadius: '10px', 
                                border: '1px solid var(--border-light)',
                                background: 'var(--bg-primary)',
                                color: 'var(--text-primary)',
                                outline: 'none',
                                fontSize: '0.85rem'
                            }}
                        />
                    </div>
                </div>

                <div style={{ overflowX: 'auto' }}>
                    <table>
                        <thead>
                            {viewMode === 'partner' ? (
                                <tr>
                                    <th>Delivery Partner</th>
                                    <th>Pending Cash (Held by DP)</th>
                                    <th>Ready to Pay (Settled)</th>
                                    <th>Earnings Split (DP/ADM)</th>
                                    <th style={{ textAlign: 'right' }}>Bulk Actions</th>
                                </tr>
                            ) : (
                                <tr>
                                    <th>Order Info</th>
                                    <th>Delivery Partner</th>
                                    <th>Financials (80/20)</th>
                                    <th>Method</th>
                                    <th>Status</th>
                                    <th style={{ textAlign: 'right' }}>Actions</th>
                                </tr>
                            )}
                        </thead>
                        <tbody>
                            {loading ? (
                                <tr>
                                    <td colSpan="6" style={{ padding: '5rem', textAlign: 'center' }}>
                                        <RefreshCw className="spin" size={40} style={{ color: 'var(--accent-primary)', marginBottom: '1rem', opacity: 0.5 }} />
                                        <p style={{ color: 'var(--text-muted)', fontWeight: 500 }}>Syncing records...</p>
                                    </td>
                                </tr>
                            ) : viewMode === 'partner' ? (
                                filteredPartnerPayouts.length === 0 ? (
                                    <tr>
                                        <td colSpan="5" style={{ padding: '5rem', textAlign: 'center' }}>
                                            <Users size={64} style={{ margin: '0 auto', opacity: 0.1 }} />
                                            <h3 style={{ color: 'var(--text-primary)', marginTop: '1rem' }}>No partners found</h3>
                                        </td>
                                    </tr>
                                ) : (
                                    filteredPartnerPayouts.map((item) => (
                                        <tr key={item.delivery_partner_id}>
                                            <td style={{ padding: '1.25rem 1.5rem' }}>
                                                <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                                                    <div style={{ 
                                                        width: '45px', 
                                                        height: '45px', 
                                                        borderRadius: '14px', 
                                                        background: 'linear-gradient(135deg, var(--accent-primary), var(--accent-secondary))', 
                                                        color: 'white', 
                                                        display: 'flex', 
                                                        alignItems: 'center', 
                                                        justifyContent: 'center', 
                                                        fontWeight: 700
                                                    }}>
                                                        {item.first_name?.[0]}{item.last_name?.[0]}
                                                    </div>
                                                    <div>
                                                        <div style={{ fontWeight: 700, color: 'var(--text-primary)' }}>{item.first_name} {item.last_name}</div>
                                                        <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>{item.phone}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td style={{ padding: '1.25rem 1.5rem' }}>
                                                <div style={{ 
                                                    padding: '10px 16px', 
                                                    borderRadius: '12px', 
                                                    background: Number(item.total_cash_to_collect) > 0 ? 'rgba(245, 158, 11, 0.08)' : 'var(--bg-secondary)',
                                                    border: Number(item.total_cash_to_collect) > 0 ? '1px solid rgba(245, 158, 11, 0.15)' : '1px solid var(--border-light)'
                                                }}>
                                                    <div style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', marginBottom: '4px' }}>CASH HELD</div>
                                                    <div style={{ fontSize: '1.1rem', fontWeight: 800, color: Number(item.total_cash_to_collect) > 0 ? 'var(--accent-warning)' : 'var(--text-secondary)' }}>
                                                        ₹{Number(item.total_cash_to_collect).toLocaleString()}
                                                    </div>
                                                </div>
                                            </td>
                                            <td style={{ padding: '1.25rem 1.5rem' }}>
                                                <div style={{ 
                                                    padding: '10px 16px', 
                                                    borderRadius: '12px', 
                                                    background: Number(item.total_ready_to_pay) > 0 ? 'rgba(59, 130, 246, 0.08)' : 'var(--bg-secondary)',
                                                    border: Number(item.total_ready_to_pay) > 0 ? '1px solid rgba(59, 130, 246, 0.15)' : '1px solid var(--border-light)'
                                                }}>
                                                    <div style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', marginBottom: '4px' }}>READY TO PAY</div>
                                                    <div style={{ fontSize: '1.1rem', fontWeight: 800, color: Number(item.total_ready_to_pay) > 0 ? 'var(--accent-primary)' : 'var(--text-secondary)' }}>
                                                        ₹{Number(item.total_ready_to_pay).toLocaleString()}
                                                    </div>
                                                </div>
                                            </td>
                                            <td style={{ padding: '1.25rem 1.5rem' }}>
                                                <div style={{ fontSize: '0.85rem', fontWeight: 600 }}>
                                                    <div style={{ color: 'var(--accent-success)' }}>DP: ₹{Number(item.dp_share_in_cash).toLocaleString()}</div>
                                                    <div style={{ color: 'var(--text-muted)', fontSize: '0.75rem' }}>ADM: ₹{Number(item.company_share_in_cash).toLocaleString()}</div>
                                                </div>
                                            </td>
                                            <td style={{ padding: '1.25rem 1.5rem', textAlign: 'right' }}>
                                                {Number(item.total_cash_to_collect) > 0 && (
                                                    <button 
                                                        className="primary-btn"
                                                        disabled={actionLoading === 'bulk-' + item.delivery_partner_id}
                                                        onClick={() => handleConfirmBulkCash(item.delivery_partner_id, item.first_name, item.total_cash_to_collect)}
                                                        style={{ 
                                                            fontSize: '0.8rem', 
                                                            padding: '0.75rem 1.25rem',
                                                            background: 'linear-gradient(135deg, var(--accent-warning), #d97706)',
                                                            display: 'flex',
                                                            alignItems: 'center',
                                                            gap: '8px',
                                                            marginLeft: 'auto'
                                                        }}
                                                    >
                                                        {actionLoading === 'bulk-' + item.delivery_partner_id ? <RefreshCw className="spin" size={16} /> : <CheckCircle size={16} />}
                                                        Confirm All Cash
                                                    </button>
                                                )}
                                                {Number(item.total_cash_to_collect) === 0 && Number(item.total_ready_to_pay) > 0 && (
                                                    <button 
                                                        className="primary-btn"
                                                        disabled={actionLoading === 'bulk-pay-' + item.delivery_partner_id}
                                                        onClick={() => handlePayPartnerBulk(item.delivery_partner_id, item.first_name, item.total_ready_to_pay)}
                                                        style={{ 
                                                            fontSize: '0.8rem', 
                                                            padding: '0.75rem 1.25rem',
                                                            background: 'linear-gradient(135deg, var(--accent-primary), #2563eb)',
                                                            display: 'flex',
                                                            alignItems: 'center',
                                                            gap: '8px',
                                                            marginLeft: 'auto'
                                                        }}
                                                    >
                                                        {actionLoading === 'bulk-pay-' + item.delivery_partner_id ? <RefreshCw className="spin" size={16} /> : <Wallet size={16} />}
                                                        Pay Partner
                                                    </button>
                                                )}
                                                {Number(item.total_cash_to_collect) === 0 && Number(item.total_ready_to_pay) === 0 && (
                                                    <span style={{ fontSize: '0.85rem', color: 'var(--accent-success)', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '6px', justifyContent: 'flex-end' }}>
                                                        <CheckCircle2 size={16} /> All Settled
                                                    </span>
                                                )}
                                            </td>
                                        </tr>
                                    ))
                                )
                            ) : (
                                filteredPayouts.length === 0 ? (
                                    <tr>
                                        <td colSpan="6" style={{ padding: '5rem', textAlign: 'center' }}>
                                            <Search size={64} style={{ margin: '0 auto', opacity: 0.1 }} />
                                            <h3 style={{ color: 'var(--text-primary)', marginTop: '1rem' }}>No transactions found</h3>
                                        </td>
                                    </tr>
                                ) : (
                                    filteredPayouts.map((item) => {
                                        const statusInfo = getStatusInfo(item.status);
                                        return (
                                            <tr key={item.payout_order_id}>
                                                <td style={{ padding: '1rem 1.5rem' }}>
                                                    <div style={{ fontWeight: 700, color: 'var(--text-primary)', marginBottom: '0.25rem' }}>#ORD-{item.order_id}</div>
                                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                                        <FileText size={12} /> ID: {item.payout_order_id}
                                                    </div>
                                                </td>
                                                <td style={{ padding: '1rem 1.5rem' }}>
                                                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                                                        <div style={{ 
                                                            width: '40px', 
                                                            height: '40px', 
                                                            borderRadius: '12px', 
                                                            background: 'rgba(59, 130, 246, 0.1)', 
                                                            color: 'var(--accent-primary)', 
                                                            display: 'flex', 
                                                            alignItems: 'center', 
                                                            justifyContent: 'center', 
                                                            fontWeight: 700
                                                        }}>
                                                            {item.first_name?.[0]}{item.last_name?.[0]}
                                                        </div>
                                                        <div>
                                                            <div style={{ fontWeight: 600, color: 'var(--text-primary)' }}>{item.first_name} {item.last_name}</div>
                                                            <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>{item.dp_phone}</div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td style={{ padding: '1rem 1.5rem' }}>
                                                    <div style={{ display: 'flex', flexDirection: 'column', gap: '2px' }}>
                                                        <div style={{ color: 'var(--accent-success)', fontWeight: 700 }}>₹{Number(item.dp_share).toLocaleString()}</div>
                                                        <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>ADM: ₹{Number(item.admin_share).toLocaleString()}</div>
                                                    </div>
                                                </td>
                                                <td style={{ padding: '1rem 1.5rem' }}>
                                                    <span style={{ 
                                                        textTransform: 'uppercase', 
                                                        fontSize: '0.75rem', 
                                                        fontWeight: 700, 
                                                        padding: '4px 10px', 
                                                        borderRadius: '8px',
                                                        background: item.payment_method === 'cash' ? 'rgba(245, 158, 11, 0.1)' : 'rgba(59, 130, 246, 0.1)',
                                                        color: item.payment_method === 'cash' ? 'var(--accent-warning)' : 'var(--accent-primary)'
                                                    }}>
                                                        {item.payment_method === 'cash' ? 'CASH' : 'ONLINE'}
                                                    </span>
                                                </td>
                                                <td style={{ padding: '1.25rem 1.5rem' }}>
                                                    <div className={`status-badge ${statusInfo.class}`}>
                                                        {statusInfo.label}
                                                    </div>
                                                </td>
                                                <td style={{ padding: '1.25rem 1.5rem', textAlign: 'right' }}>
                                                    {item.status === 'cash_pending' && (
                                                        <button 
                                                            className="primary-btn"
                                                            disabled={actionLoading === item.payout_order_id}
                                                            onClick={() => handleConfirmCash(item.payout_order_id)}
                                                            style={{ fontSize: '0.75rem', padding: '0.5rem 1rem', background: 'var(--accent-warning)' }}
                                                        >
                                                            {actionLoading === item.payout_order_id ? <RefreshCw className="spin" size={14} /> : 'Confirm Cash'}
                                                        </button>
                                                    )}
                                                    {item.status === 'awaiting_payout' && (
                                                        <button 
                                                            className="primary-btn"
                                                            disabled={actionLoading === item.payout_order_id}
                                                            onClick={() => handleProcessPayout(item.payout_order_id)}
                                                            style={{ fontSize: '0.75rem', padding: '0.5rem 1rem', background: 'var(--accent-primary)' }}
                                                        >
                                                            {actionLoading === item.payout_order_id ? <RefreshCw className="spin" size={14} /> : 'Pay Partner'}
                                                        </button>
                                                    )}
                                                </td>
                                            </tr>
                                        );
                                    })
                                )
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
            
            {/* Legend / Help section - Refined */}
            <div style={{ 
                marginTop: '3rem', 
                padding: '2rem', 
                background: 'linear-gradient(to right, rgba(59, 130, 246, 0.05), rgba(139, 92, 246, 0.05))', 
                borderRadius: '20px', 
                border: '1px solid var(--border-light)',
                display: 'flex', 
                gap: '1.5rem', 
                alignItems: 'flex-start' 
            }}>
                <div style={{ 
                    width: '48px', 
                    height: '48px', 
                    borderRadius: '14px', 
                    background: 'var(--bg-secondary)', 
                    display: 'flex', 
                    alignItems: 'center', 
                    justifyContent: 'center',
                    boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
                    color: 'var(--accent-primary)',
                    flexShrink: 0
                }}>
                    <Info size={24} />
                </div>
                <div>
                    <h3 style={{ fontSize: '1.1rem', fontWeight: 700, marginBottom: '0.5rem', color: 'var(--text-primary)' }}>Revenue Model & Compliance</h3>
                    <p style={{ fontSize: '0.95rem', lineHeight: 1.6, margin: 0, color: 'var(--text-secondary)' }}>
                        Payouts follow a standard <b>80/20 split</b>. For <span style={{ color: 'var(--accent-warning)', fontWeight: 600 }}>Cash-on-Delivery</span>, partners must remit the full order amount to the hub before their earnings are processed. For <span style={{ color: 'var(--accent-primary)', fontWeight: 600 }}>Online Payments</span>, earnings can be dispatched immediately post-delivery. All transactions are logged for audit compliance.
                    </p>
                </div>
            </div>
        </div>
    );
};

export default Payouts;
