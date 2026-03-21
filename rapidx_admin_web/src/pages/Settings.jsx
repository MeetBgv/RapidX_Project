import React from 'react';
import { Settings as SettingsIcon, Globe, Lock, Sliders, Smartphone, FileText } from 'lucide-react';

const Settings = () => {
    return (
        <div className="fade-in">
            <div className="page-header">
                <div>
                    <h1 className="page-title">System Settings</h1>
                    <p className="page-subtitle">Platform configuration, agreements, and app settings.</p>
                </div>
                <button className="primary-btn" style={{ background: 'var(--accent-success)' }}>Save Changes</button>
            </div>

            <div className="grid-2-cols">
                <div className="panel">
                    <h3 className="panel-title" style={{ color: 'var(--accent-primary)' }}><Globe size={20} /> Platform Configuration</h3>
                    <div className="info-row"><span className="info-label">Platform Name</span><input type="text" className="header-search" defaultValue="RapidX Delivery" style={{ width: '60%', padding: '0.5rem', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-light)', borderRadius: 'var(--radius-sm)' }} /></div>
                    <div className="info-row"><span className="info-label">Contact Email</span><input type="text" className="header-search" defaultValue="support@rapidx.com" style={{ width: '60%', padding: '0.5rem', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-light)', borderRadius: 'var(--radius-sm)' }} /></div>
                    <div className="info-row"><span className="info-label">Contact Phone</span><input type="text" className="header-search" defaultValue="+91 1800-400-3000" style={{ width: '60%', padding: '0.5rem', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-light)', borderRadius: 'var(--radius-sm)' }} /></div>
                    <div className="info-row">
                        <span className="info-label">Maintenance Mode</span>
                        <div style={{ width: '60%', display: 'flex', alignItems: 'center' }}>
                            <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer' }}>
                                <input type="checkbox" style={{ width: '16px', height: '16px' }} />
                                Enable System Maintenance
                            </label>
                        </div>
                    </div>
                </div>

                <div className="panel">
                    <h3 className="panel-title" style={{ color: 'var(--accent-warning)' }}><FileText size={20} /> Legal Documents</h3>
                    <textarea
                        className="header-search"
                        style={{ width: '100%', height: '120px', resize: 'none', padding: '1rem', background: 'rgba(255,255,255,0.05)', margin: '1rem 0', display: 'block' }}
                        defaultValue="Terms & Conditions content..."
                    ></textarea>
                    <textarea
                        className="header-search"
                        style={{ width: '100%', height: '120px', resize: 'none', padding: '1rem', background: 'rgba(255,255,255,0.05)', margin: '1rem 0', display: 'block' }}
                        defaultValue="Privacy Policy content..."
                    ></textarea>
                </div>

                <div className="panel" style={{ gridColumn: 'span 2' }}>
                    <h3 className="panel-title" style={{ color: 'var(--accent-secondary)' }}><Smartphone size={20} /> Application Integrations & API</h3>
                    <p style={{ fontSize: '0.875rem', color: 'var(--text-secondary)', marginBottom: '1.5rem' }}>Manage API keys and external connections (Payment Gateways, SMS, Maps).</p>

                    <div className="grid-3-cols" style={{ gap: '1rem', marginBottom: 0 }}>
                        <div style={{ padding: '1rem', border: '1px solid var(--border-light)', borderRadius: 'var(--radius-md)' }}>
                            <h4 style={{ marginBottom: '0.5rem' }}>Razorpay API</h4>
                            <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginBottom: '1rem' }}>Active connection. Processed 12k txns.</div>
                            <button className="primary-btn" style={{ width: '100%', justifyContent: 'center', background: 'rgba(255,255,255,0.05)', color: 'var(--text-primary)', border: '1px solid var(--border-light)', boxShadow: 'none' }}>Configure</button>
                        </div>
                        <div style={{ padding: '1rem', border: '1px solid var(--border-light)', borderRadius: 'var(--radius-md)' }}>
                            <h4 style={{ marginBottom: '0.5rem' }}>Google Maps Distance Matrix</h4>
                            <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginBottom: '1rem' }}>Active connection. 89% quota used.</div>
                            <button className="primary-btn" style={{ width: '100%', justifyContent: 'center', background: 'rgba(255,255,255,0.05)', color: 'var(--text-primary)', border: '1px solid var(--border-light)', boxShadow: 'none' }}>Configure</button>
                        </div>
                        <div style={{ padding: '1rem', border: '1px solid var(--border-light)', borderRadius: 'var(--radius-md)' }}>
                            <h4 style={{ marginBottom: '0.5rem' }}>Twilio SMS Gateway</h4>
                            <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginBottom: '1rem' }}>Active connection. 1.2M sent.</div>
                            <button className="primary-btn" style={{ width: '100%', justifyContent: 'center', background: 'rgba(255,255,255,0.05)', color: 'var(--text-primary)', border: '1px solid var(--border-light)', boxShadow: 'none' }}>Configure</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Settings;
