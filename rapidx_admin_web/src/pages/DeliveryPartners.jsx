import React, { useState, useEffect } from 'react';
import { 
    MoreHorizontal, Edit2, ShieldAlert, BadgeCheck, Phone, Mail, 
    MapPin, Calendar, Truck, User, CreditCard, Landmark, 
    TrendingUp, Award, Wallet, ArrowLeft, ExternalLink, Activity, RefreshCw, Trash2, Ban
} from 'lucide-react';

const DeliveryPartners = () => {
    const [selectedDP, setSelectedDP] = useState(null);
    const [partners, setPartners] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [filterVerifying, setFilterVerifying] = useState(false);
    const [currentLocation, setCurrentLocation] = useState('Location Unavailable');

    useEffect(() => {
        if (selectedDP && selectedDP.current_lat && selectedDP.current_lng) {
            setCurrentLocation('Fetching GPS coordinates...');
            fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${selectedDP.current_lat}&lon=${selectedDP.current_lng}`)
                .then(res => res.json())
                .then(data => setCurrentLocation(data.display_name || 'Location Not Found'))
                .catch(() => setCurrentLocation('Error fetching location'));
        } else {
            setCurrentLocation('Location Unavailable');
        }
    }, [selectedDP]);

    const fetchPartners = async (showLoading = true) => {
        if (showLoading) setLoading(true);
        try {
            const response = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/delivery-partners`);
            if (!response.ok) {
                throw new Error('Failed to fetch delivery partners');
            }
            const data = await response.json();
            setPartners(data);
        } catch (err) {
            setError(err.message);
        } finally {
            if (showLoading) setLoading(false);
        }
    };

    useEffect(() => {
        fetchPartners(true);
        const interval = setInterval(() => fetchPartners(false), 5000);
        return () => clearInterval(interval);
    }, []);

    const handleVerify = async (partnerId) => {
        try {
            const response = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/delivery-partners/${partnerId}/verify`, {
                method: 'POST',
            });
            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(errorData.error || 'Failed to verify partner. They may not have submitted their verification documents yet.');
            }
            // Update local state
            setPartners(partners.map(p => 
                p.user_id === partnerId ? { ...p, is_verified: true } : p
            ));
            if (selectedDP && selectedDP.user_id === partnerId) {
                setSelectedDP({ ...selectedDP, is_verified: true });
            }
            alert('Partner verified successfully!');
        } catch (err) {
            alert(err.message);
        }
    };

    const handleToggleBan = async (partner) => {
        if (!window.confirm(`Are you sure you want to ${partner.is_banned ? 'unban' : 'ban'} this partner?`)) return;
        try {
            const response = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/${partner.user_id}/toggle-ban`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ is_banned: !partner.is_banned })
            });
            if (response.ok) {
                const updatedPartner = { ...partner, is_banned: !partner.is_banned };
                setPartners(partners.map(p => p.user_id === partner.user_id ? updatedPartner : p));
                if (selectedDP?.user_id === partner.user_id) setSelectedDP(updatedPartner);
            }
        } catch (err) {
            alert('Error toggling ban: ' + err.message);
        }
    };

    const handleDeletePartner = async (partner) => {
        if (!window.confirm('Are you sure you want to delete this delivery partner? This cannot be undone.')) return;
        try {
            const response = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/${partner.user_id}`, {
                method: 'DELETE'
            });
            if (response.ok) {
                setPartners(partners.filter(p => p.user_id !== partner.user_id));
                if (selectedDP?.user_id === partner.user_id) setSelectedDP(null);
                alert('Delivery partner deleted successfully');
            } else {
                const data = await response.json();
                alert(data.error || 'Failed to delete delivery partner');
            }
        } catch (err) {
            alert('Error deleting delivery partner: ' + err.message);
        }
    };

    if (selectedDP) {
        return (
            <div className="fade-in" style={{ paddingBottom: '3rem' }}>
                <div className="details-header" style={{ marginBottom: '2.5rem', alignItems: 'center' }}>
                    <button className="back-btn" onClick={() => setSelectedDP(null)}>
                        <ArrowLeft size={20} />
                    </button>
                    <div style={{ position: 'relative' }}>
                        <img 
                            src={`https://ui-avatars.com/api/?name=${selectedDP.first_name}+${selectedDP.last_name}&background=3b82f6&color=fff&bold=true`} 
                            className="profile-avatar-large" 
                            style={{ width: '90px', height: '90px', borderRadius: '24px', border: 'none', boxShadow: '0 8px 16px rgba(0,0,0,0.1)' }}
                            alt="Profile" 
                        />
                        {selectedDP.is_verified && (
                            <div style={{ position: 'absolute', bottom: '-5px', right: '-5px', background: 'var(--accent-success)', color: 'white', border: '3px solid var(--bg-primary)', borderRadius: '50%', width: '28px', height: '28px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                <BadgeCheck size={16} />
                            </div>
                        )}
                    </div>
                    <div style={{ marginLeft: '1.5rem' }}>
                        <h1 className="page-title" style={{ fontSize: '2rem' }}>{selectedDP.first_name || ''} {selectedDP.last_name || ''}</h1>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginTop: '0.5rem' }}>
                            <span style={{ fontSize: '0.9rem', color: 'var(--text-muted)', fontWeight: 500 }}>Partner ID: <span style={{ color: 'var(--text-primary)' }}>DP-{selectedDP.user_id}</span></span>
                            <span style={{ width: '4px', height: '4px', borderRadius: '50%', background: 'var(--text-muted)' }}></span>
                            <span style={{ fontSize: '0.9rem', color: 'var(--text-muted)', fontWeight: 500 }}>Joined: <span style={{ color: 'var(--text-primary)' }}>{new Date(selectedDP.created_at).toLocaleDateString()}</span></span>
                        </div>
                    </div>
                </div>
                
                {/* Status Banners */}
                {!selectedDP.is_verified && (
                    <div style={{ marginBottom: '2rem', padding: '1.5rem', background: 'rgba(245, 158, 11, 0.05)', border: '1px solid rgba(245, 158, 11, 0.2)', borderRadius: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                            <div style={{ width: '40px', height: '40px', borderRadius: '12px', background: 'rgba(245, 158, 11, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--accent-warning)' }}>
                                <ShieldAlert size={20} />
                            </div>
                            <div>
                                <h4 style={{ margin: 0, fontWeight: 700, color: 'var(--text-primary)' }}>Verification Pending</h4>
                                <p style={{ margin: '0.2rem 0 0 0', fontSize: '0.85rem', color: 'var(--text-secondary)' }}>Review the submitted documents below before approving the profile.</p>
                            </div>
                        </div>
                        {selectedDP.vehicle_type !== undefined && (
                            <button 
                                className="primary-btn" 
                                style={{ background: 'var(--accent-success)', boxShadow: '0 4px 12px rgba(16, 185, 129, 0.2)' }}
                                onClick={() => handleVerify(selectedDP.user_id)}
                            >
                                <BadgeCheck size={18} /> Approve Profile
                            </button>
                        )}
                    </div>
                )}

                <div className="grid-3-cols" style={{ gap: '2rem' }}>
                    <div className="panel" style={{ padding: '2rem' }}>
                        <h3 className="panel-title" style={{ marginBottom: '1.5rem' }}>
                            <User size={18} /> Basic Information
                        </h3>
                        <div className="info-row"><span className="info-label">Full Name</span><span className="info-value">{selectedDP.first_name || ''} {selectedDP.last_name || ''}</span></div>
                        <div className="info-row"><span className="info-label">Email Address</span><span className="info-value" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Mail size={14} style={{ opacity: 0.5 }} /> {selectedDP.email || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Phone Number</span><span className="info-value" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Phone size={14} style={{ opacity: 0.5 }} /> {selectedDP.phone || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Current City</span><span className="info-value" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><MapPin size={14} style={{ opacity: 0.5 }} /> {selectedDP.working_city || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Duty Status</span><span className="info-value"><span className={`status-badge ${selectedDP.is_banned ? 'status-danger' : 'status-success'}`}>{selectedDP.is_banned ? 'Banned' : 'Active Duty'}</span></span></div>
                        <div className="info-row" style={{ border: 'none', marginTop: '1rem' }}>
                            <div>
                                <span className="info-label" style={{ display: 'block', marginBottom: '0.5rem' }}>Live GPS Location</span>
                                <span className="info-value" style={{ color: 'var(--accent-primary)', fontSize: '0.8rem', lineHeight: 1.4 }}>{currentLocation}</span>
                            </div>
                        </div>
                    </div>

                    <div className="panel" style={{ padding: '2rem' }}>
                        <h3 className="panel-title" style={{ marginBottom: '1.5rem' }}>
                            <Truck size={18} /> Vehicle & Fleet
                        </h3>
                        <div className="info-row"><span className="info-label">Vehicle Category</span><span className="info-value">{selectedDP.vehicle_type || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Plate Number</span><span className="info-value" style={{ textTransform: 'uppercase', background: 'var(--bg-primary)', padding: '2px 8px', borderRadius: '4px', fontWeight: 600 }}>{selectedDP.vehicle_number || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">License Key</span><span className="info-value">{selectedDP.license_number || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Expiry Date</span><span className="info-value" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Calendar size={14} style={{ opacity: 0.5 }} /> {selectedDP.expiry_date ? new Date(selectedDP.expiry_date).toLocaleDateString() : 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Document ID</span><span className="info-value">{selectedDP.document_type || 'N/A'}</span></div>
                        <div className="info-row" style={{ border: 'none' }}><span className="info-label">ID Number</span><span className="info-value">{selectedDP.document_number || 'N/A'}</span></div>
                    </div>

                    <div className="panel" style={{ padding: '2rem' }}>
                        <h3 className="panel-title" style={{ marginBottom: '1.5rem' }}>
                            <Landmark size={18} /> Banking & Settlements
                        </h3>
                        <div className="info-row"><span className="info-label">Bank Name</span><span className="info-value">{selectedDP.bank_name || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Branch</span><span className="info-value">{selectedDP.branch_name || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Holder Name</span><span className="info-value">{selectedDP.account_holder_name || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Account No.</span><span className="info-value" style={{ fontFamily: 'monospace', fontWeight: 600 }}>{selectedDP.account_number || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">IFSC Code</span><span className="info-value" style={{ fontWeight: 600, color: 'var(--accent-primary)' }}>{selectedDP.ifsc_code || 'N/A'}</span></div>
                        <div className="info-row" style={{ border: 'none' }}><span className="info-label">Type</span><span className="info-value">{selectedDP.account_type || 'N/A'}</span></div>
                    </div>

                    <div className="panel" style={{ gridColumn: 'span 3', padding: '2rem' }}>
                        <h3 className="panel-title" style={{ marginBottom: '2rem' }}>
                            <TrendingUp size={18} /> Performance & Payout Summary
                        </h3>
                        <div className="grid-3-cols" style={{ marginBottom: 0, gap: '2rem' }}>
                            <div style={{ background: 'var(--bg-primary)', padding: '1.5rem', borderRadius: '16px', border: '1px solid var(--border-light)' }}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '1rem' }}>
                                    <div style={{ width: '32px', height: '32px', borderRadius: '8px', background: 'rgba(59, 130, 246, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--accent-primary)' }}>
                                        <Truck size={16} />
                                    </div>
                                    <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Total Deliveries</span>
                                </div>
                                <div style={{ fontSize: '2rem', fontWeight: 800, color: 'var(--text-primary)' }}>
                                    {selectedDP.total_deliveries?.toLocaleString() || 0}
                                </div>
                                <div style={{ marginTop: '0.5rem', fontSize: '0.75rem', color: 'var(--text-muted)', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '4px' }}>
                                    Overall Performance
                                </div>
                            </div>

                            <div style={{ background: 'var(--bg-primary)', padding: '1.5rem', borderRadius: '16px', border: '1px solid var(--border-light)' }}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '1rem' }}>
                                    <div style={{ width: '32px', height: '32px', borderRadius: '8px', background: 'rgba(16, 185, 129, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--accent-success)' }}>
                                        <Wallet size={16} />
                                    </div>
                                    <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Lifetime Earnings</span>
                                </div>
                                <div style={{ fontSize: '2rem', fontWeight: 800, color: 'var(--accent-success)' }}>
                                    ₹{selectedDP.lifetime_earnings?.toLocaleString() || 0}
                                </div>
                                <div style={{ marginTop: '0.5rem', fontSize: '0.75rem', color: 'var(--text-muted)', fontWeight: 500 }}>Total earnings (Pre-tax)</div>
                            </div>

                            <div style={{ background: 'var(--bg-primary)', padding: '1.5rem', borderRadius: '16px', border: '1px solid var(--border-light)' }}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '1rem' }}>
                                    <div style={{ width: '32px', height: '32px', borderRadius: '8px', background: 'rgba(245, 158, 11, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--accent-warning)' }}>
                                        <Activity size={16} />
                                    </div>
                                    <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600 }}>Unsettled Amount</span>
                                </div>
                                <div style={{ fontSize: '2rem', fontWeight: 800, color: 'var(--accent-warning)' }}>
                                    ₹{selectedDP.unsettled_amount?.toLocaleString() || 0}
                                </div>
                                <div style={{ marginTop: '0.5rem' }}>
                                    <button 
                                        className="primary-btn" 
                                        style={{ padding: '0.4rem 0.8rem', fontSize: '0.7rem', background: 'var(--bg-secondary)', color: 'var(--text-primary)', border: '1px solid var(--border-light)', boxShadow: 'none' }}
                                        onClick={() => { /* Navigate to payouts */ }}
                                    >
                                        Review Details <ExternalLink size={10} />
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div className="panel" style={{ gridColumn: 'span 3', padding: '2rem' }}>
                            <h3 className="panel-title" style={{ marginBottom: '1.5rem', color: 'var(--accent-danger)' }}>
                                <ShieldAlert size={18} /> Account Controls
                            </h3>
                            <div style={{ display: 'flex', gap: '1rem' }}>
                                <button 
                                    className="primary-btn" 
                                    style={{ background: 'var(--bg-secondary)', border: '1px solid var(--accent-danger)', color: 'var(--accent-danger)', boxShadow: 'none' }}
                                    onClick={() => handleDeletePartner(selectedDP)}
                                >
                                    <Trash2 size={18} /> Delete Partner Account
                                </button>
                                <button 
                                    className="primary-btn" 
                                    style={{ 
                                        background: 'var(--bg-secondary)', 
                                        border: `1px solid ${selectedDP.is_banned ? 'var(--accent-success)' : 'var(--accent-danger)'}`, 
                                        color: selectedDP.is_banned ? 'var(--accent-success)' : 'var(--accent-danger)', 
                                        boxShadow: 'none',
                                        display: 'flex',
                                        alignItems: 'center',
                                        gap: '0.5rem'
                                    }}
                                    onClick={() => handleToggleBan(selectedDP)}
                                >
                                    <Ban size={18} /> {selectedDP.is_banned ? 'Unban Partner Account' : 'Ban Partner Account'}
                                </button>
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
                    <h1 className="page-title">Fleet Community</h1>
                    <p className="page-subtitle">Oversee delivery partners, verification cycles, and performance metrics.</p>
                </div>
                <div style={{ display: 'flex', gap: '1rem' }}>
                    <button 
                        className="primary-btn" 
                        style={{ 
                            background: filterVerifying ? 'var(--bg-secondary)' : 'var(--accent-primary)', 
                            color: filterVerifying ? 'var(--text-primary)' : 'white', 
                            border: filterVerifying ? '1px solid var(--border-light)' : 'none',
                            boxShadow: filterVerifying ? 'none' : '0 4px 12px rgba(59, 130, 246, 0.2)'
                        }} 
                        onClick={() => setFilterVerifying(!filterVerifying)}
                    >
                        {filterVerifying ? <Activity size={18} /> : <ShieldAlert size={18} />}
                        {filterVerifying ? 'View Full Community' : 'Pending Approvals'}
                    </button>
                </div>
            </div>

            <div className="table-container">
                <div className="table-header" style={{ padding: '1.25rem 1.5rem' }}>
                    <span className="table-title" style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                        {filterVerifying ? <Award size={20} style={{ color: 'var(--accent-warning)' }} /> : <Truck size={20} style={{ color: 'var(--accent-primary)' }} />}
                        {filterVerifying ? 'Verification Audit Queue' : 'Active Partner Directory'}
                    </span>
                    <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)', fontWeight: 500 }}>
                        {partners.length} Total Registered
                    </div>
                </div>
                <div style={{ overflowX: 'auto' }}>
                    <table>
                        <thead>
                            <tr>
                                <th>Partner Identity</th>
                                <th>Vehicle</th>
                                <th>Operation Hub</th>
                                <th>Contract</th>
                                <th>Stability</th>
                                <th>Verification</th>
                                <th>Retention</th>
                                <th style={{ textAlign: 'right' }}>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {loading ? (
                                <tr>
                                    <td colSpan="8" style={{ textAlign: 'center', padding: '5rem' }}>
                                        <RefreshCw className="spin" size={32} style={{ color: 'var(--accent-primary)', opacity: 0.5, marginBottom: '1rem' }} />
                                        <p style={{ color: 'var(--text-muted)' }}>Syncing fleet data...</p>
                                    </td>
                                </tr>
                            ) : error ? (
                                <tr>
                                    <td colSpan="8" style={{ textAlign: 'center', padding: '5rem', color: 'var(--accent-danger)' }}>{error}</td>
                                </tr>
                            ) : (filterVerifying ? partners.filter(p => !p.is_verified) : partners).length === 0 ? (
                                <tr>
                                    <td colSpan="8" style={{ textAlign: 'center', padding: '5rem' }}>
                                        <Activity size={48} style={{ margin: '0 auto', opacity: 0.2, marginBottom: '1rem' }} />
                                        <p style={{ color: 'var(--text-muted)' }}>No matches found in this segment.</p>
                                    </td>
                                </tr>
                            ) : (
                                (filterVerifying ? partners.filter(p => !p.is_verified) : partners).map((partner) => (
                                    <tr key={partner.user_id}>
                                        <td style={{ padding: '1.25rem 1.5rem' }}>
                                            <div style={{ fontWeight: 700, color: 'var(--text-primary)' }}>{partner.first_name || ''} {partner.last_name || ''}</div>
                                            <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
                                                #DP-{partner.user_id}
                                            </div>
                                        </td>
                                        <td style={{ padding: '1.25rem 1.5rem' }}>
                                            <div style={{ fontWeight: 600, fontSize: '0.85rem' }}>{partner.vehicle_type || 'N/A'}</div>
                                            <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', textTransform: 'uppercase' }}>{partner.vehicle_number || 'N/A'}</div>
                                        </td> 
                                        <td>{partner.working_city ? `${partner.working_city}` : 'N/A'}</td>
                                        <td><span style={{ fontSize: '0.8rem', fontWeight: 500 }}>{partner.working_type || 'Standard'}</span></td>
                                        <td>
                                            <span className={`status-badge ${partner.is_banned ? 'status-danger' : 'status-success'}`}>
                                                {partner.is_banned ? 'Banned' : 'Healthy'}
                                            </span>
                                        </td>
                                        <td>
                                            {partner.is_verified ? (
                                                <span className="status-badge status-success" style={{ gap: '4px' }}><BadgeCheck size={12} /> Elite</span>
                                            ) : (
                                                <span className="status-badge status-warning" style={{ gap: '4px' }}><ShieldAlert size={12} /> Review</span>
                                            )}
                                        </td>
                                        <td>{partner.created_at ? new Date(partner.created_at).toLocaleDateString('en-GB', { month: 'short', year: 'numeric' }) : 'N/A'}</td>
                                        <td style={{ textAlign: 'right' }}>
                                            <div className="td-actions" style={{ justifyContent: 'flex-end' }}>
                                                <button className="btn-icon" onClick={() => handleToggleBan(partner)} title={partner.is_banned ? 'Unban Partner' : 'Ban Partner'}>
                                                    <Ban size={16} color={partner.is_banned ? 'var(--accent-success)' : 'var(--accent-danger)'} />
                                                </button>
                                                <button className="btn-icon" onClick={() => handleDeletePartner(partner)} style={{ color: 'var(--accent-danger)' }}>
                                                    <Trash2 size={16} />
                                                </button>
                                                <button className="primary-btn" onClick={() => setSelectedDP(partner)} style={{ padding: '0.4rem 0.8rem', fontSize: '0.75rem', background: 'var(--bg-secondary)', border: '1px solid var(--border-light)', color: 'var(--text-primary)', boxShadow: 'none' }}>
                                                    Manage Details
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
};

export default DeliveryPartners;
