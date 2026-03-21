import React from 'react';
import { Shield, Users, Lock, Unlock } from 'lucide-react';

const Roles = () => {
    const roles = [
        { title: "Administrator", desc: "Full system access over all modules", users: 5 },
        { title: "Financial Administrator", desc: "Access to Payments, Payouts, and Billing only", users: 3 },
        { title: "Orders Administrator", desc: "Access to Orders, Parcels, and Complaints", users: 8 },
        { title: "Deliveries Administrator", desc: "Access to Delivery Partners and Live Tracking", users: 12 },
        { title: "Business Admin", desc: "External role. Access to business dashboard.", users: 1042 },
        { title: "Business Employee", desc: "External role. Access to B2B sub-accounts.", users: 3450 },
        { title: "Customer", desc: "External role. Standard app users.", users: 12456 },
        { title: "Delivery Partner", desc: "External role. Riders and drivers.", users: 3120 }
    ];

    return (
        <div className="fade-in">
            <div className="page-header">
                <div>
                    <h1 className="page-title">Roles & Access Management</h1>
                    <p className="page-subtitle">Configure system roles and permission mapping.</p>
                </div>
                <button className="primary-btn"><Shield size={16} /> Create Custom Role</button>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(400px, 1fr))', gap: '1.5rem' }}>
                {roles.map((role, idx) => (
                    <div key={idx} className="panel" style={{ position: 'relative', overflow: 'hidden' }}>
                        {idx >= 4 && <div style={{ position: 'absolute', top: '10px', right: '10px' }}><span className="status-badge status-neutral">External</span></div>}

                        <h3 className="panel-title" style={{ fontSize: '1.2rem', color: idx < 4 ? 'var(--accent-success)' : 'var(--accent-primary)' }}>
                            {idx === 0 ? <Shield size={20} /> : idx < 4 ? <Unlock size={20} /> : <Lock size={20} />}
                            {role.title}
                        </h3>
                        <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '1.5rem' }}>
                            {role.desc}
                        </p>

                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderTop: '1px solid var(--border-light)', paddingTop: '1rem' }}>
                            <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '0.875rem', fontWeight: 600 }}>
                                <Users size={16} color="var(--text-muted)" /> {role.users.toLocaleString()} assigned users
                            </span>
                            <button className="primary-btn" style={{ padding: '0.4rem 0.8rem', background: 'transparent', border: '1px solid var(--border-light)', color: 'var(--text-primary)', boxShadow: 'none' }}>
                                Manage Access
                            </button>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default Roles;
