import React from 'react';
import { Database, Plus, Edit2, Trash2 } from 'lucide-react';

const MasterData = () => {
    const masterCategories = [
        { title: "Account Status", items: ["Active", "Inactive", "Blocked", "Pending Verification"] },
        { title: "Business Types", items: ["Retail", "Wholesale", "Service", "Manufacturing", "E-Commerce"] },
        { title: "Billing Cycles", items: ["Daily", "Weekly", "Monthly"] },
        { title: "Payment Methods", items: ["Cash on Delivery", "UPI", "Net Banking", "Bank Transfer"] },
        { title: "Payment Status", items: ["Pending", "Success", "Failed", "Refunded"] },
        { title: "Parcel Types", items: ["Document", "Electronics", "Food", "Grocery", "Clothing", "Fragile", "Other"] },
        { title: "Parcel Sizes", items: ["Small", "Medium", "Large", "Extra Large"] },
        { title: "Delivery Status", items: ["Order Placed", "Assigned", "Picked Up", "In Transit", "Out for Delivery", "Delivered", "Cancelled", "Returned"] },
        { title: "Vehicle Types", items: ["Bike", "Car", "Mini Tempo", "Tempo"] },
        { title: "Working Types", items: ["Full Time", "Part Time"] },
        { title: "Document Types", items: ["Aadhaar Card", "PAN Card"] },
        { title: "Complaint Types", items: ["Late Delivery", "Damaged Item", "Wrong Delivery", "Payment Issue", "Delivery Partner Issue", "App Issue", "Other"] }
    ];

    return (
        <div className="fade-in">
            <div className="page-header">
                <div>
                    <h1 className="page-title">Master Data Management</h1>
                    <p className="page-subtitle">Configure application-wide dropdown values and categories.</p>
                </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '1.5rem' }}>
                {masterCategories.map((category, idx) => (
                    <div key={idx} className="panel">
                        <h3 className="panel-title" style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid var(--border-light)', paddingBottom: '1rem' }}>
                            <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Database size={16} color="var(--accent-primary)" /> {category.title}</span>
                            <button className="btn-icon" style={{ width: '24px', height: '24px' }}><Plus size={14} /></button>
                        </h3>
                        <ul style={{ listStyle: 'none', marginTop: '1rem', display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                            {category.items.map((item, i) => (
                                <li key={i} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '0.5rem', background: 'rgba(255,255,255,0.02)', borderRadius: 'var(--radius-sm)' }}>
                                    <span style={{ fontSize: '0.875rem' }}>{item}</span>
                                    <div style={{ display: 'flex', gap: '0.25rem' }}>
                                        <Edit2 size={12} style={{ cursor: 'pointer', color: 'var(--text-secondary)' }} />
                                        <Trash2 size={12} style={{ cursor: 'pointer', color: 'var(--accent-danger)' }} />
                                    </div>
                                </li>
                            ))}
                        </ul>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default MasterData;
