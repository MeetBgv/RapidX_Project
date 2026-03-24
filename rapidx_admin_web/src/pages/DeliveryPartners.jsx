import React, { useState, useEffect } from 'react';
import { MoreHorizontal, Edit2, ShieldAlert, BadgeCheck } from 'lucide-react';

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

    if (selectedDP) {
        return (
            <div className="fade-in">
                <div className="details-header">
                    <button className="back-btn" onClick={() => setSelectedDP(null)}>←</button>
                    <img src={`https://ui-avatars.com/api/?name=${selectedDP.first_name}+${selectedDP.last_name}&background=10b981&color=fff`} className="profile-avatar-large" alt="Profile" />
                    <div>
                        <h1 className="page-title">{selectedDP.first_name || ''} {selectedDP.last_name || ''}</h1>
                        <p className="page-subtitle">
                            Partner ID: DP-{selectedDP.user_id} • 
                            {selectedDP.is_verified ? (
                                <span className="status-badge status-success" style={{ marginLeft: '8px' }}><BadgeCheck size={12} /> Verified</span>
                            ) : (
                                <span className="status-badge status-warning" style={{ marginLeft: '8px' }}><ShieldAlert size={12} /> Pending</span>
                            )}
                        </p>
                    </div>
                </div>
                
                {!selectedDP.is_verified && selectedDP.vehicle_type === undefined && (
                    <div style={{ marginBottom: '16px', padding: '12px 16px', background: 'rgba(245, 158, 11, 0.1)', border: '1px solid var(--accent-warning)', borderRadius: '8px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <ShieldAlert size={16} style={{ color: 'var(--accent-warning)', flexShrink: 0 }} />
                        <span style={{ fontSize: '0.875rem', color: 'var(--accent-warning)' }}>
                            This delivery partner has not completed their profile setup yet. Vehicle, document, and bank details will appear once they submit their registration form.
                        </span>
                    </div>
                )}

                {!selectedDP.is_verified && selectedDP.vehicle_type !== undefined && (
                    <div style={{ marginBottom: '20px', display: 'flex', justifyContent: 'flex-end' }}>
                        <button 
                            className="primary-btn" 
                            style={{ background: 'var(--accent-success)' }}
                            onClick={() => handleVerify(selectedDP.user_id)}
                        >
                            <BadgeCheck size={16} style={{ marginRight: '8px' }} />
                            Approve & Verify Profile
                        </button>
                    </div>
                )}

                <div className="grid-3-cols">
                    <div className="panel">
                        <h3 className="panel-title">Profile & Work Preferences</h3>
                        <div className="info-row"><span className="info-label">Full Name</span><span className="info-value">{selectedDP.first_name || ''} {selectedDP.last_name || ''}</span></div>
                        <div className="info-row"><span className="info-label">Email</span><span className="info-value">{selectedDP.email || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Phone</span><span className="info-value">{selectedDP.phone || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Working City</span><span className="info-value">{selectedDP.working_city || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Working State</span><span className="info-value">{selectedDP.working_state || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Time Slot</span><span className="info-value">{selectedDP.time_slot || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Working Type</span><span className="info-value">{selectedDP.working_type || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Account Status</span><span className="info-value"><span className={`status-badge ${selectedDP.is_banned ? 'status-danger' : 'status-success'}`}>{selectedDP.is_banned ? 'Banned' : 'Active'}</span></span></div>
                        <div className="info-row"><span className="info-label">Current GPS Location</span><span className="info-value">{currentLocation}</span></div>
                    </div>

                    <div className="panel">
                        <h3 className="panel-title">Vehicle Details & Documents</h3>
                        <div className="info-row"><span className="info-label">Vehicle Type</span><span className="info-value">{selectedDP.vehicle_type || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Vehicle Number</span><span className="info-value" style={{ textTransform: 'uppercase' }}>{selectedDP.vehicle_number || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">License Number</span><span className="info-value">{selectedDP.license_number || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">License Expiry</span><span className="info-value">{selectedDP.expiry_date ? new Date(selectedDP.expiry_date).toLocaleDateString() : 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Doc Type (Identity)</span><span className="info-value">{selectedDP.document_type || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Doc Number</span><span className="info-value">{selectedDP.document_number || 'N/A'}</span></div>
                    </div>

                    <div className="panel">
                        <h3 className="panel-title">Bank Details</h3>
                        <div className="info-row"><span className="info-label">Bank Name</span><span className="info-value">{selectedDP.bank_name || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Branch Name</span><span className="info-value">{selectedDP.branch_name || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Account Holder Name</span><span className="info-value">{selectedDP.account_holder_name || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Account Number</span><span className="info-value">{selectedDP.account_number || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Account Type</span><span className="info-value">{selectedDP.account_type || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">IFSC Code</span><span className="info-value">{selectedDP.ifsc_code || 'N/A'}</span></div>
                    </div>

                    <div className="panel" style={{ gridColumn: 'span 3' }}>
                        <h3 className="panel-title">Performance & Payouts</h3>
                        <div className="grid-3-cols" style={{ marginBottom: 0 }}>
                            <div className="info-row" style={{ border: 'none' }}><span className="info-label">Total Orders Delivered</span><span className="info-value" style={{ fontSize: '1.5rem', display: 'flex', alignItems: 'center' }}>1,402</span></div>
                            <div className="info-row" style={{ border: 'none' }}><span className="info-label">Total Earnings</span><span className="info-value" style={{ fontSize: '1.5rem', display: 'flex', alignItems: 'center', color: 'var(--accent-success)' }}>₹1,85,400</span></div>
                            <div className="info-row" style={{ border: 'none' }}><span className="info-label">Pending Payout Amount</span><span className="info-value" style={{ fontSize: '1.5rem', display: 'flex', alignItems: 'center', color: 'var(--accent-warning)' }}>₹4,200</span></div>
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
                    <h1 className="page-title">Delivery Partners</h1>
                    <p className="page-subtitle">Verify, manage, and track all riders on the platform.</p>
                </div>
                <button className="primary-btn" style={{ background: filterVerifying ? 'var(--bg-secondary)' : 'var(--accent-success)', color: filterVerifying ? 'var(--text-primary)' : 'white', border: filterVerifying ? '1px solid var(--border-color)' : 'none' }} onClick={() => setFilterVerifying(!filterVerifying)}>
                    {filterVerifying ? 'Show All Profiles' : 'Verify Pending Profiles'}
                </button>
            </div>

            <div className="table-container">
                <div className="table-header">
                    <span className="table-title">{filterVerifying ? 'Pending Verifications' : 'Partner List'}</span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Partner ID</th>
                            <th>Name</th>
                            <th>Phone</th>
                            <th>Vehicle Type</th>
                            <th>Location</th>
                            <th>Type</th>
                            <th>Status</th>
                            <th>Verification</th>
                            <th>Created Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr>
                                <td colSpan="10" style={{ textAlign: 'center', padding: '2rem' }}>Loading partners...</td>
                            </tr>
                        ) : error ? (
                            <tr>
                                <td colSpan="10" style={{ textAlign: 'center', padding: '2rem', color: 'var(--accent-danger)' }}>{error}</td>
                            </tr>
                        ) : partners.length === 0 ? (
                            <tr>
                                <td colSpan="10" style={{ textAlign: 'center', padding: '2rem' }}>No delivery partners found</td>
                            </tr>
                        ) : (
                            (filterVerifying ? partners.filter(p => !p.is_verified) : partners).map((partner) => (
                                <tr key={partner.user_id}>
                                    <td>#DP-{partner.user_id}</td>
                                    <td>{partner.first_name || ''} {partner.last_name || ''}</td>
                                    <td>{partner.phone || 'N/A'}</td>
                                    <td>{partner.vehicle_type || 'N/A'}</td> 
                                    <td>{partner.working_city ? `${partner.working_city}, ${partner.working_state || ''}` : 'N/A'}</td>
                                    <td>{partner.working_type || 'N/A'}</td>
                                    <td><span className={`status-badge ${partner.is_banned ? 'status-danger' : 'status-success'}`}>{partner.is_banned ? 'Banned' : 'Active'}</span></td>
                                    <td>{partner.is_verified ? <span className="status-badge status-success"><BadgeCheck size={12} /> Verified</span> : <span className="status-badge status-warning"><ShieldAlert size={12} /> Pending</span>}</td>
                                    <td>{partner.created_at ? new Date(partner.created_at).toLocaleDateString() : 'N/A'}</td>
                                    <td>
                                        <div className="td-actions">
                                            <button className="btn-icon" onClick={() => setSelectedDP(partner)} title="View Details">
                                                <MoreHorizontal size={16} />
                                            </button>
                                            {!partner.is_verified && filterVerifying && (
                                                 <button className="btn-icon" onClick={() => handleVerify(partner.user_id)} title="Verify Partner">
                                                     <span style={{ color: 'var(--accent-success)', display: 'flex', alignItems: 'center' }}><BadgeCheck size={16}/></span>
                                                 </button>
                                            )}
                                        </div>
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

export default DeliveryPartners;
