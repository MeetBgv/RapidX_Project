import React from 'react';
import { Search } from 'lucide-react';

const Parcels = () => {
    return (
        <div className="fade-in">
            <div className="page-header">
                <div>
                    <h1 className="page-title">Parcels Management</h1>
                    <p className="page-subtitle">View parcel types, dimensions, and mappings to orders.</p>
                </div>
            </div>

            <div className="table-container">
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
                        {[1, 2, 3, 4, 5, 6].map((item) => (
                            <tr key={item}>
                                <td><span style={{ fontWeight: 600 }}>PRC-{14000 + item}</span></td>
                                <td><span style={{ color: 'var(--accent-primary)', cursor: 'pointer' }}>#ORD-9938{item}</span></td>
                                <td>{['Document', 'Electronics', 'Food', 'Clothing', 'Fragile', 'Other'][item - 1]}</td>
                                <td><span className={`status-badge ${['status-info', 'status-warning', 'status-danger', 'status-success', 'status-warning', 'status-neutral'][item - 1]}`}>
                                    {['Small', 'Medium', 'Large', 'Extra Large', 'Medium', 'Small'][item - 1]}
                                </span></td>
                                <td>Up to {item * 5} kg</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default Parcels;
