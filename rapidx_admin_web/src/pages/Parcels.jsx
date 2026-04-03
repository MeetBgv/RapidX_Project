import React, { useState, useEffect } from 'react';
import { Search, RefreshCw } from 'lucide-react';

const Parcels = () => {
    const [parcels, setParcels] = useState([]);
    const [loading, setLoading] = useState(true);

    const fetchParcels = async () => {
        setLoading(true);
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/parcels`);
            if (res.ok) {
                const data = await res.json();
                setParcels(data);
            }
        } catch (error) {
            console.error('Error fetching parcels:', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchParcels();
    }, []);

    return (
        <div className="fade-in">
            <div className="page-header">
                <div>
                    <h1 className="page-title">Parcels Management</h1>
                    <p className="page-subtitle">View parcel types, dimensions, and mappings to orders.</p>
                </div>
                <button className="primary-btn" onClick={fetchParcels} style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <RefreshCw size={16} /> Refresh
                </button>
            </div>

            <div className="table-container" style={{ marginTop: '1.5rem' }}>
                <div className="table-header">
                    <span className="table-title">Parcel Database</span>
                    <div className="header-search" style={{ width: '250px', border: '1px solid rgba(255,255,255,0.1)' }}>
                        <Search size={14} color="var(--text-secondary)" />
                        <input type="text" placeholder="Search parcel ID..." style={{ fontSize: '0.8rem' }} />
                    </div>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Parcel ID</th>
                            <th>Order ID</th>
                            <th>Parcel Type</th>
                            <th>Parcel Size</th>
                            <th>Weight Config</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr><td colSpan="5" style={{ textAlign: 'center', padding: '2rem' }}>Loading parcels...</td></tr>
                        ) : parcels.length === 0 ? (
                            <tr><td colSpan="5" style={{ textAlign: 'center', padding: '2rem' }}>No parcels found.</td></tr>
                        ) : (
                            parcels.map((item) => (
                                <tr key={item.parcel_id}>
                                    <td><span style={{ fontWeight: 600 }}>PRC-{item.parcel_id}</span></td>
                                    <td><span style={{ color: 'var(--accent-primary)', cursor: 'pointer' }}>#ORD-{item.order_id}</span></td>
                                    <td>{item.parcel_type_name || 'N/A'}</td>
                                    <td><span className="status-badge status-info">
                                        {item.parcel_size_name || 'N/A'}
                                    </span></td>
                                    <td>{item.weight} kg</td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default Parcels;
