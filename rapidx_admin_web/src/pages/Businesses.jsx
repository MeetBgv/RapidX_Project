import React, { useState, useEffect } from 'react';
import { MoreHorizontal, Edit2, Trash2, Shield, RefreshCw } from 'lucide-react';

const Businesses = () => {
    const [selectedBusiness, setSelectedBusiness] = useState(null);
    const [businesses, setBusinesses] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const fetchBusinesses = async (showLoading = true) => {
        if (showLoading) setLoading(true);
        try {
            const response = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/businesses`);
            if (!response.ok) {
                throw new Error('Failed to fetch businesses');
            }
            const data = await response.json();
            setBusinesses(data);
        } catch (err) {
            setError(err.message);
        } finally {
            if (showLoading) setLoading(false);
        }
    };

    useEffect(() => {
        fetchBusinesses(true);
        const interval = setInterval(() => fetchBusinesses(false), 10000);
        return () => clearInterval(interval);
    }, []);

    if (selectedBusiness) {
        const business = selectedBusiness;
        return (
            <div className="fade-in">
                <div className="details-header">
                    <button className="back-btn" onClick={() => setSelectedBusiness(null)}>←</button>
                    <h1 className="page-title">Business Details: #{business.business_id}</h1>
                </div>

                <div className="grid-2-cols">
                    <div className="panel">
                        <h3 className="panel-title">Business Information</h3>
                        <div className="info-row"><span className="info-label">Company Name</span><span className="info-value">{business.company_name}</span></div>
                        <div className="info-row"><span className="info-label">Business Type</span><span className="info-value">{business.business_type || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Registration Number</span><span className="info-value">{business.reg_no || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Contact Phone</span><span className="info-value">{business.business_phone || 'N/A'}</span></div>
                    </div>

                    <div className="panel">
                        <h3 className="panel-title">Billing Information</h3>
                        <div className="info-row"><span className="info-label">Billing Cycle</span><span className="info-value"><span className="status-badge status-info">{business.billing_cycle || 'N/A'}</span></span></div>
                        <div className="info-row"><span className="info-label">Payment Method</span><span className="info-value">{business.payment_method || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Account Status</span><span className="info-value"><span className={`status-badge ${business.account_status === 'Active' ? 'status-success' : 'status-warning'}`}>{business.account_status || 'Pending'}</span></span></div>
                    </div>

                    <div className="panel">
                        <h3 className="panel-title">Business Admin</h3>
                        <div className="info-row"><span className="info-label">Admin Name</span><span className="info-value">{business.admin_first_name} {business.admin_last_name}</span></div>
                        <div className="info-row"><span className="info-label">Admin Email</span><span className="info-value" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Shield size={14} /> {business.admin_email}</span></div>
                    </div>

                    <div className="panel">
                        <h3 className="panel-title">Operations</h3>
                        <div style={{ marginTop: '1rem', display: 'flex', gap: '1rem' }}>
                            <button className="primary-btn" style={{ flex: 1, padding: '0.4rem', justifyContent: 'center' }}>View Order History</button>
                            <button className="primary-btn" style={{ flex: 1, padding: '0.4rem', justifyContent: 'center' }}>View Billing History</button>
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
                    <h1 className="page-title">Business Clients</h1>
                    <p className="page-subtitle">B2B client accounts, tracking and billing.</p>
                </div>
                <button className="primary-btn" onClick={() => fetchBusinesses(true)} style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <RefreshCw size={16} /> Refresh
                </button>
            </div>

            <div className="table-container">
                <div className="table-header">
                    <span className="table-title">Business List</span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Business ID</th>
                            <th>Company Name</th>
                            <th>Business Type</th>
                            <th>Registration Number</th>
                            <th>Phone</th>
                            <th>Account Status</th>
                            <th>Billing Cycle</th>
                            <th>Payment Method</th>
                            <th>Created Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr>
                                <td colSpan="10" style={{ textAlign: 'center', padding: '2rem' }}>Loading businesses...</td>
                            </tr>
                        ) : error ? (
                            <tr>
                                <td colSpan="10" style={{ textAlign: 'center', padding: '2rem', color: 'var(--accent-danger)' }}>{error}</td>
                            </tr>
                        ) : businesses.length === 0 ? (
                            <tr>
                                <td colSpan="10" style={{ textAlign: 'center', padding: '2rem' }}>No businesses found</td>
                            </tr>
                        ) : (
                            businesses.map((business) => (
                                <tr key={business.business_id}>
                                    <td>#{business.business_id}</td>
                                    <td>{business.company_name}</td>
                                    <td>{business.business_type || 'N/A'}</td>
                                    <td>{business.reg_no || 'N/A'}</td>
                                    <td>{business.business_phone || 'N/A'}</td>
                                    <td>
                                        <span className={`status-badge ${business.account_status === 'Active' ? 'status-success' : 'status-warning'}`}>
                                            {business.account_status || 'Pending'}
                                        </span>
                                    </td>
                                    <td>{business.billing_cycle || 'N/A'}</td>
                                    <td>{business.payment_method || 'N/A'}</td>
                                    <td>{business.created_at ? new Date(business.created_at).toLocaleDateString() : 'N/A'}</td>
                                    <td>
                                        <div className="td-actions">
                                            <button className="btn-icon" onClick={() => setSelectedBusiness(business)}><MoreHorizontal size={16} /></button>
                                            <button className="btn-icon"><Edit2 size={16} /></button>
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

export default Businesses;
