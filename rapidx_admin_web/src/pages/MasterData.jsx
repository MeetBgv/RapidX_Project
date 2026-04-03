import React, { useState, useEffect } from 'react';
import { Database, Plus, Edit2, Trash2, RefreshCw } from 'lucide-react';

const MasterData = () => {
    const [masterCategories, setMasterCategories] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const MOCK_MASTER_DATA = [
        { value_id: 1, value_name: 'Active', category_title: 'Account Status' },
        { value_id: 2, value_name: 'Pending Verification', category_title: 'Account Status' },
        { value_id: 3, value_name: 'Express Delivery', category_title: 'Delivery Type' },
        { value_id: 4, value_name: 'Standard Delivery', category_title: 'Delivery Type' },
        { value_id: 5, value_name: 'Two Wheeler', category_title: 'Vehicle Type' },
        { value_id: 6, value_name: 'Four Wheeler', category_title: 'Vehicle Type' }
    ];

    const processMasterData = (data) => {
        const grouped = data.reduce((acc, curr) => {
            const category = curr.category_title || 'Uncategorized';
            if (!acc[category]) {
                acc[category] = [];
            }
            acc[category].push({ id: curr.value_id, name: curr.value_name });
            return acc;
        }, {});

        const categoriesArray = Object.keys(grouped).map(key => ({
            title: key,
            items: grouped[key]
        }));

        setMasterCategories(categoriesArray);
    };

    const fetchMasterData = async () => {
        setLoading(true);
        setError(null);
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/masterdata`);
            if (res.ok) {
                const data = await res.json();
                processMasterData(data);
            } else {
                console.warn(`Backend masterdata fetch failed (${res.status}). Using fallback mock data.`);
                processMasterData(MOCK_MASTER_DATA);
            }
        } catch (err) {
            console.warn('Backend masterdata unreachable. Using fallback mock data.', err);
            processMasterData(MOCK_MASTER_DATA);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchMasterData();
    }, []);

    return (
        <div className="fade-in">
            <div className="page-header">
                <div>
                    <h1 className="page-title">Master Data Management</h1>
                    <p className="page-subtitle">Configure application-wide dropdown values and categories.</p>
                </div>
                <div style={{ display: 'flex', gap: '0.5rem' }}>
                    <button className="primary-btn" onClick={fetchMasterData} style={{ background: 'var(--bg-secondary)', border: '1px solid var(--border-light)', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                        <RefreshCw size={16} /> Refresh
                    </button>
                    <button className="primary-btn"><Plus size={16} /> Add Category</button>
                </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '1.5rem' }}>
                {loading ? (
                    <div style={{ padding: '2rem', textAlign: 'center', gridColumn: '1 / -1' }}>Loading master data...</div>
                ) : masterCategories.length === 0 ? (
                    <div style={{ padding: '2rem', textAlign: 'center', gridColumn: '1 / -1' }}>No master data found.</div>
                ) : (
                    masterCategories.map((category, idx) => (
                        <div key={idx} className="panel">
                            <h3 className="panel-title" style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid var(--border-light)', paddingBottom: '1rem' }}>
                                <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Database size={16} color="var(--accent-primary)" /> {category.title}</span>
                                <button className="btn-icon" style={{ width: '24px', height: '24px' }}><Plus size={14} /></button>
                            </h3>
                            <ul style={{ listStyle: 'none', marginTop: '1rem', display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                                {category.items.map((item) => (
                                    <li key={item.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '0.5rem', background: 'rgba(255,255,255,0.02)', borderRadius: 'var(--radius-sm)' }}>
                                        <span style={{ fontSize: '0.875rem' }}>{item.name} <span style={{ color: 'var(--text-muted)', fontSize: '0.7rem' }}>(#{item.id})</span></span>
                                        <div style={{ display: 'flex', gap: '0.25rem' }}>
                                            <Edit2 size={12} style={{ cursor: 'pointer', color: 'var(--text-secondary)' }} />
                                            <Trash2 size={12} style={{ cursor: 'pointer', color: 'var(--accent-danger)' }} />
                                        </div>
                                    </li>
                                ))}
                            </ul>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
};

export default MasterData;
