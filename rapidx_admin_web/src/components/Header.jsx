import React from 'react';
import { Search, Bell, MessageSquare, ChevronDown, Menu, Sun, Moon } from 'lucide-react';

const Header = ({ toggleSidebar, isDarkMode, toggleTheme }) => {
    return (
        <header className="top-header">
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                <button className="action-btn" onClick={toggleSidebar}>
                    <Menu size={20} />
                </button>
                <div className="header-search">
                    <Search size={18} color="var(--text-secondary)" />
                    <input type="text" placeholder="Search orders, clients, or partners..." />
                </div>
            </div>

            <div className="header-actions">
                <button className="action-btn" onClick={toggleTheme} title={isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode"}>
                    {isDarkMode ? <Sun size={20} /> : <Moon size={20} />}
                </button>
                <button className="action-btn">
                    <MessageSquare size={20} />
                    <span className="badge">3</span>
                </button>
                <button className="action-btn">
                    <Bell size={20} />
                    <span className="badge">5</span>
                </button>

                <div className="user-profile">
                    <img
                        src="https://ui-avatars.com/api/?name=Admin+User&background=3b82f6&color=fff"
                        alt="Admin User"
                        className="user-avatar"
                    />
                    <div className="user-info">
                        <span className="user-name">Admin User</span>
                        <span className="user-role">Super Admin</span>
                    </div>
                    <ChevronDown size={16} color="var(--text-secondary)" />
                </div>
            </div>
        </header>
    );
};

export default Header;
