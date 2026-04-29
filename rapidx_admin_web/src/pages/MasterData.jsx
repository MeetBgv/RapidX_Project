import React, { useState, useEffect } from 'react';
import { Database, Plus, Edit2, Trash2, RefreshCw, X } from 'lucide-react';

const MasterData = () => {
    const [masterCategories, setMasterCategories] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [showCategoryModal, setShowCategoryModal] = useState(false);
    const [showValueModal, setShowValueModal] = useState(null); // Will hold the master_id
    const [newCategoryName, setNewCategoryName] = useState('');
    const [newValueName, setNewValueName] = useState('');

    const processMasterData = (data) => {
        const grouped = data.reduce((acc, curr) => {
            const category = curr.category_title || 'Uncategorized';
            const masterId = curr.master_id;
            if (!acc[category]) {
                acc[category] = { master_id: masterId, items: [] };
            }
            acc[category].items.push({ id: curr.value_id, name: curr.value_name });
            return acc;
        }, {});

        const categoriesArray = Object.keys(grouped).map(key => ({
            title: key,
            master_id: grouped[key].master_id,
            items: grouped[key].items
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
                setError('Failed to fetch master data from server');
            }
        } catch (err) {
            setError('Error connecting to backend');
        } finally {
            setLoading(false);
        }
    };

    const handleAddCategory = async (e) => {
        e.preventDefault();
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/masterdata/category`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ type_name: newCategoryName })
            });
            if (res.ok) {
                alert('Category created successfully');
                setShowCategoryModal(false);
                setNewCategoryName('');
                fetchMasterData();
            }
        } catch (err) { alert(err.message); }
    };

    const handleAddValue = async (e) => {
        e.preventDefault();
        try {
            const res = await fetch(`${import.meta.env.VITE_API_BASE_URL}/api/users/masterdata/value`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ master_id: showValueModal, value_name: newValueName })
            });
            if (res.ok) {
                alert('Value added successfully');
                setShowValueModal(null);
                setNewValueName('');
                fetchMasterData();
            }
        } catch (err) { alert(err.message); }
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
                    <button className="primary-btn" onClick={() => setShowCategoryModal(true)}><Plus size={16} /> Add Category</button>
                </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '1.5rem' }}>
                {loading ? (
                    <div style={{ padding: '2rem', textAlign: 'center', gridColumn: '1 / -1' }}>Loading master data...</div>
                ) : error ? (
                    <div style={{ padding: '2rem', textAlign: 'center', gridColumn: '1 / -1', color: 'var(--accent-danger)' }}>{error}</div>
                ) : masterCategories.length === 0 ? (
                    <div style={{ padding: '2rem', textAlign: 'center', gridColumn: '1 / -1' }}>No master data found.</div>
                ) : (
                    masterCategories.map((category, idx) => (
                        <div key={idx} className="panel">
                            <h3 className="panel-title" style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid var(--border-light)', paddingBottom: '1rem' }}>
                                <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Database size={16} color="var(--accent-primary)" /> {category.title}</span>
                                <button className="btn-icon" style={{ width: '24px', height: '24px' }} onClick={() => setShowValueModal(category.master_id)}><Plus size={14} /></button>
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

            {/* Add Category Modal */}
            {showCategoryModal && (
                <div className="modal-overlay">
                    <div className="modal-content" style={{ maxWidth: '400px' }}>
                        <div className="modal-header">
                            <h2 className="modal-title">New Master Category</h2>
                            <button className="close-btn" onClick={() => setShowCategoryModal(false)}><X /></button>
                        </div>
                        <form onSubmit={handleAddCategory}>
                            <div className="info-row" style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', border: 'none' }}>
                                <label>Category Name (e.g., Delivery Status)</label>
                                <input type="text" className="search-input" value={newCategoryName} onChange={(e) => setNewCategoryName(e.target.value)} required />
                            </div>
                            <div style={{ marginTop: '2rem', display: 'flex', gap: '1rem' }}>
                                <button type="submit" className="primary-btn" style={{ flex: 1 }}>Create Category</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Add Value Modal */}
            {showValueModal && (
                <div className="modal-overlay">
                    <div className="modal-content" style={{ maxWidth: '400px' }}>
                        <div className="modal-header">
                            <h2 className="modal-title">Add Master Value</h2>
                            <button className="close-btn" onClick={() => setShowValueModal(null)}><X /></button>
                        </div>
                        <form onSubmit={handleAddValue}>
                            <div className="info-row" style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', border: 'none' }}>
                                <label>Value Name (e.g., In Transit)</label>
                                <input type="text" className="search-input" value={newValueName} onChange={(e) => setNewValueName(e.target.value)} required />
                            </div>
                            <div style={{ marginTop: '2rem', display: 'flex', gap: '1rem' }}>
                                <button type="submit" className="primary-btn" style={{ flex: 1 }}>Add Value</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default MasterData;
