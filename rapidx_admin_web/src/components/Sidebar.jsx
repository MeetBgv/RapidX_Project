import React from 'react';
import { NavLink } from 'react-router-dom';
import {
    LayoutDashboard, Users, Briefcase, Truck, PackageCheck,
    Box, CreditCard, Banknote, FileText, AlertCircle,
    Database, Shield, Settings
} from 'lucide-react';

const Sidebar = ({ isOpen }) => {
    const menuItems = [
        { name: 'Dashboard', icon: <LayoutDashboard />, path: '/' },
        { name: 'Users', icon: <Users />, path: '/users' },
        { name: 'Business Clients', icon: <Briefcase />, path: '/businesses' },
        { name: 'Delivery Partners', icon: <Truck />, path: '/partners' },
        { name: 'Orders', icon: <PackageCheck />, path: '/orders' },
        { name: 'Parcels', icon: <Box />, path: '/parcels' },
        { name: 'Payments', icon: <CreditCard />, path: '/payments' },
        { name: 'Partner Payouts', icon: <Banknote />, path: '/payouts' },
        { name: 'Business Billing', icon: <FileText />, path: '/billing' },
        { name: 'Complaints', icon: <AlertCircle />, path: '/complaints' },
        { name: 'Master Data', icon: <Database />, path: '/master-data' },
        { name: 'Roles Management', icon: <Shield />, path: '/roles' },
        { name: 'Settings', icon: <Settings />, path: '/settings' },
    ];

    return (
        <aside className={`sidebar ${!isOpen ? 'closed' : ''}`}>
            <div className="sidebar-header">
                <div className="sidebar-logo">RX</div>
                <div className="sidebar-title">RapidX Admin</div>
            </div>
            <nav className="sidebar-nav">
                {menuItems.map((item, index) => (
                    <NavLink
                        key={index}
                        to={item.path}
                        className={({ isActive }) => (isActive ? 'nav-item active' : 'nav-item')}
                    >
                        {item.icon}
                        <span>{item.name}</span>
                    </NavLink>
                ))}
            </nav>
        </aside>
    );
};

export default Sidebar;
